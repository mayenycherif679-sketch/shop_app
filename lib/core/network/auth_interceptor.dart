import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

/// 1) Injecte `Authorization: Bearer <token>` dans chaque requête.
/// 2) Sur 401 : refresh token, puis rejeu de la requête.
///    Si le refresh échoue : tokens effacés + notification -> écran login.
/// 3) Les autres codes (403, 404, 5xx...) ne déclenchent PAS de refresh :
///    ils sont transmis tels quels et convertis en `Failure` plus haut.
///
/// QueuedInterceptor : les erreurs sont traitées une par une, donc un seul
/// refresh à la fois même si plusieurs requêtes reçoivent un 401 en parallèle.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.storage,
    required this.onSessionExpired,
    required BaseOptions options,
  }) : _plain = Dio(options); // mêmes options que le client principal

  final TokenStorage storage;
  final void Function() onSessionExpired;

  /// Client SANS intercepteur, uniquement pour le refresh et le rejeu.
  /// Obligatoire : réutiliser le client principal dans un QueuedInterceptor
  /// provoque un deadlock (la requête rejouée attendrait la file en cours).
  final Dio _plain;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final isAuthCall = path.contains('/auth/login') || path.contains('/auth/refresh-token');
    if (err.response?.statusCode != 401 || isAuthCall) {
      return handler.next(err);
    }

    final refresh = await storage.refreshToken;
    if (refresh == null) {
      onSessionExpired();
      return handler.next(err);
    }

    try {
      final res = await _plain.post('/auth/refresh-token', data: {'refreshToken': refresh});
      final newAccess = res.data['access_token'] as String;
      await storage.save(access: newAccess, refresh: res.data['refresh_token'] as String);

      final opts = err.requestOptions..headers['Authorization'] = 'Bearer $newAccess';
      handler.resolve(await _plain.fetch(opts));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      // Refresh refusé => session perdue. Erreur réseau => on garde les tokens.
      if (code == 401 || code == 400) {
        await storage.clear();
        onSessionExpired();
      }
      handler.next(err);
    }
  }
}

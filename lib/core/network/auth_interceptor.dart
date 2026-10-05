import 'package:dio/dio.dart';
import '../config.dart';
import '../storage/token_storage.dart';

/// 1) Injecte `Authorization: Bearer <token>` dans chaque requête.
/// 2) Sur 401 : tente un refresh token, puis rejoue la requête.
///    Si le refresh échoue : vide les tokens et notifie l'app (-> écran login).
///
/// QueuedInterceptor : si plusieurs requêtes échouent en 401 en même temps,
/// elles sont traitées une par une (un seul refresh à la fois).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this.storage, required this.onSessionExpired});

  final TokenStorage storage;
  final void Function() onSessionExpired;

  // Dio "nu" (sans intercepteur) pour le refresh et le rejeu : évite les boucles/deadlocks.
  final Dio _plain = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

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
      final retry = await _plain.fetch(opts);
      handler.resolve(retry);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 400) {
        await storage.clear();
        onSessionExpired();
      }
      handler.next(err);
    }
  }
}

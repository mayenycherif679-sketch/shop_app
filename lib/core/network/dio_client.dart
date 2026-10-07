import 'package:dio/dio.dart';
import '../config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// Appelée UNE SEULE FOIS dans le composition root (main.dart) :
/// l'instance Dio est ensuite partagée (injectée) par tous les data sources.
Dio buildDio(TokenStorage storage, void Function() onSessionExpired) {
  final options = BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json'},
  );
  return Dio(options)
    ..interceptors.add(AuthInterceptor(
      storage: storage,
      onSessionExpired: onSessionExpired,
      options: options, // même config (baseUrl, timeouts) pour le refresh
    ));
}

import 'package:dio/dio.dart';
import '../config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

Dio buildDio(TokenStorage storage, void Function() onSessionExpired) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json'},
  ));
  dio.interceptors.add(AuthInterceptor(
    storage: storage,
    onSessionExpired: onSessionExpired,
  ));
  return dio;
}

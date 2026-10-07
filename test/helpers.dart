import 'package:dio/dio.dart';
import 'package:shop_app/core/storage/cache_store.dart';
import 'package:shop_app/core/storage/token_storage.dart';

class FakeCache implements CacheStore {
  final store = <String, dynamic>{};
  @override
  Future<void> write(String key, dynamic json) async => store[key] = json;
  @override
  dynamic read(String key) => store[key];
  @override
  Future<void> clear() async => store.clear();
}

class FakeTokens implements TokenStorage {
  String? access, refresh;
  @override
  Future<String?> get accessToken async => access;
  @override
  Future<String?> get refreshToken async => refresh;
  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async => access = refresh = null;
}

DioException dioError(DioExceptionType type, {int? status, String path = '/x'}) {
  final req = RequestOptions(path: path);
  return DioException(
    requestOptions: req,
    type: type,
    response: status == null ? null : Response(requestOptions: req, statusCode: status),
  );
}

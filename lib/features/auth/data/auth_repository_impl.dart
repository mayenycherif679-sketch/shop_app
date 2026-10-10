import 'package:dio/dio.dart';
import '../../../core/storage/cache_store.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/cached.dart';
import '../../../core/utils/failure.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import 'auth_remote_data_source.dart';
import 'user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokens, this._cache);
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokens;
  final CacheStore _cache;

  static const _profileKey = 'profile';

  @override
  Future<User> login(String email, String password) async {
    try {
      final t = await _remote.login(email, password);
      await _tokens.save(
        access: t['access_token'] as String,
        refresh: t['refresh_token'] as String,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const Failure('Invalid credentials', type: FailureType.invalidCredentials);
      }
      throw Failure.from(e);
    }
    return (await getProfile()).data;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _remote.register(name, email, password);
    } catch (e) {
      throw Failure.from(e);
    }
    return login(email, password);
  }

  @override
  Future<Cached<User>> getProfile() => cachedFetch<User>(
        cache: _cache,
        key: _profileKey,
        remote: _remote.profile,
        parse: (j) => UserModel.fromJson(Map<String, dynamic>.from(j as Map)),
      );

  @override
  Future<User?> restoreSession() async {
    if (await _tokens.accessToken == null) return null;
    try {
      return (await getProfile()).data; // fonctionne aussi hors-ligne via le cache
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _tokens.clear();
    await _cache.clear(); // on ne garde pas les données d'un autre utilisateur
  }
}

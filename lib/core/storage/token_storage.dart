import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> get accessToken;
  Future<String?> get refreshToken;
  Future<void> save({required String access, required String refresh});
  Future<void> clear();
}

/// Tokens stockés dans le Keychain (iOS) / Keystore (Android).
class SecureTokenStorage implements TokenStorage {
  final _s = const FlutterSecureStorage();

  @override
  Future<String?> get accessToken => _s.read(key: 'access_token');
  @override
  Future<String?> get refreshToken => _s.read(key: 'refresh_token');

  @override
  Future<void> save({required String access, required String refresh}) async {
    await _s.write(key: 'access_token', value: access);
    await _s.write(key: 'refresh_token', value: refresh);
  }

  @override
  Future<void> clear() async {
    await _s.delete(key: 'access_token');
    await _s.delete(key: 'refresh_token');
  }
}

import '../../../core/utils/cached.dart';
import 'user.dart';

abstract class AuthRepository {
  /// Restaure la session au démarrage (null si pas connecté).
  Future<User?> restoreSession();
  Future<User> login(String email, String password);
  Future<User> register({required String name, required String email, required String password});
  Future<Cached<User>> getProfile();
  Future<void> logout();
}

import 'package:flutter/foundation.dart';
import '../../../core/utils/failure.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._repo);
  final AuthRepository _repo;

  AuthStatus status = AuthStatus.unknown;
  User? user;
  String? error;
  bool busy = false;

  Future<void> restore() async {
    user = await _repo.restoreSession();
    status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) =>
      _run(() => _repo.login(email, password));

  Future<void> register(String name, String email, String password) =>
      _run(() => _repo.register(name: name, email: email, password: password));

  Future<void> logout() async {
    await _repo.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Appelé par l'intercepteur quand le refresh token est refusé.
  void sessionExpired() {
    user = null;
    status = AuthStatus.unauthenticated;
    error = 'Ta session a expiré, reconnecte-toi.';
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<void> _run(Future<User> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      user = await action();
      status = AuthStatus.authenticated;
    } catch (e) {
      error = Failure.from(e).message;
    }
    busy = false;
    notifyListeners();
  }
}

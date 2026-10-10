import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/features/auth/presentation/auth_controller.dart';

import 'fakes.dart';

void main() {
  test('restore : session existante => authenticated', () async {
    final controller = AuthController(FakeAuthRepository(loggedIn: true));

    await controller.restore();

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.user?.email, 'john@mail.com');
  });

  test('restore : pas de session => unauthenticated', () async {
    final controller = AuthController(FakeAuthRepository());

    await controller.restore();

    expect(controller.status, AuthStatus.unauthenticated);
  });

  test('login réussi => authenticated, pas d\'erreur', () async {
    final controller = AuthController(FakeAuthRepository());

    await controller.login('john@mail.com', 'pw');

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.errorType, isNull);
    expect(controller.busy, false);
  });

  test('login refusé => reste unauthenticated avec errorType', () async {
    final controller = AuthController(FakeAuthRepository(
      loginError: const Failure('x', type: FailureType.invalidCredentials),
    ));
    await controller.restore();

    await controller.login('john@mail.com', 'bad');

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.errorType, FailureType.invalidCredentials);
    expect(controller.busy, false);
  });

  test('logout => unauthenticated et utilisateur effacé', () async {
    final controller = AuthController(FakeAuthRepository(loggedIn: true));
    await controller.restore();

    await controller.logout();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
  });

  test('sessionExpired (refresh refusé) => unauthenticated + unauthorized', () async {
    final controller = AuthController(FakeAuthRepository(loggedIn: true));
    await controller.restore();

    controller.sessionExpired();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.errorType, FailureType.unauthorized);
  });
}

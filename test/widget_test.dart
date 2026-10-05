import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/utils/cached.dart';
import 'package:shop_app/features/auth/domain/auth_repository.dart';
import 'package:shop_app/features/auth/domain/user.dart';
import 'package:shop_app/features/auth/presentation/auth_controller.dart';
import 'package:shop_app/main.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User?> restoreSession() async => null;

  @override
  Future<User> login(String email, String password) async => User(
        id: 1,
        name: 'Demo',
        email: email,
        avatar: '',
        role: 'user',
      );

  @override
  Future<User> register({required String name, required String email, required String password}) async =>
      User(id: 2, name: name, email: email, avatar: '', role: 'user');

  @override
  Future<Cached<User>> getProfile() async => const Cached(User(
        id: 1,
        name: 'Demo',
        email: 'demo@test.com',
        avatar: '',
        role: 'user',
      ));

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('L’application affiche l’écran de connexion quand l’utilisateur est déconnecté',
      (WidgetTester tester) async {
    final auth = AuthController(FakeAuthRepository());
    auth.status = AuthStatus.unauthenticated;

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: const App(),
      ),
    );

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}

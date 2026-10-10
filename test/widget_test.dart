import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/app.dart';
import 'package:shop_app/features/favorites/data/favorites_repository_impl.dart';
import 'package:shop_app/features/favorites/presentation/favorites_controller.dart';
import 'package:shop_app/features/settings/settings_controller.dart';
import 'package:shop_app/features/auth/presentation/auth_controller.dart';

import 'fakes.dart';

void main() {
  testWidgets('L’application affiche l’écran de connexion quand l’utilisateur est déconnecté',
      (WidgetTester tester) async {
    final authRepository = FakeAuthRepository();
    final auth = AuthController(authRepository)..restore();

    await tester.pumpWidget(ShopApp(
      auth: auth,
      authRepository: authRepository,
      catalogRepository: FakeCatalogRepository(),
      favorites: FavoritesController(FavoritesRepositoryImpl(InMemoryPrefs())),
      settings: SettingsController(InMemoryPrefs({'locale': 'en'})),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}

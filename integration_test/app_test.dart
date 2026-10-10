import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shop_app/app.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/features/auth/presentation/auth_controller.dart';
import 'package:shop_app/features/favorites/data/favorites_repository_impl.dart';
import 'package:shop_app/features/favorites/presentation/favorites_controller.dart';
import 'package:shop_app/features/settings/settings_controller.dart';

import '../test/fakes.dart';

/// Parcours utilisateur de bout en bout. Seuls les accès réseau / stockage
/// sont remplacés par des fakes : toute l'UI, la navigation et les
/// controllers sont ceux de la vraie application.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> launch(WidgetTester tester, FakeAuthRepository authRepo) async {
    final auth = AuthController(authRepo)..restore();
    await tester.pumpWidget(ShopApp(
      auth: auth,
      authRepository: authRepo,
      catalogRepository: FakeCatalogRepository(),
      favorites: FavoritesController(FavoritesRepositoryImpl(InMemoryPrefs())),
      settings: SettingsController(InMemoryPrefs({'locale': 'en'})),
    ));
    await tester.pumpAndSettle();
  }

  Finder navItem(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('email')), 'john@mail.com');
    await tester.enterText(find.byKey(const Key('password')), 'secret123');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('connexion -> produit -> favori -> onglet Favoris', (tester) async {
    await launch(tester, FakeAuthRepository());
    expect(find.text('Welcome back'), findsOneWidget);

    await signIn(tester);
    expect(find.text('Chair'), findsOneWidget);

    await tester.tap(find.text('Chair'));
    await tester.pumpAndSettle();
    expect(find.text('A comfortable chair'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(navItem('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Chair'), findsOneWidget);
    expect(find.text('No favorites yet'), findsNothing);
  });

  testWidgets('déconnexion avec confirmation -> retour à l\'écran de login', (tester) async {
    await launch(tester, FakeAuthRepository(loggedIn: true));
    expect(find.text('Chair'), findsOneWidget);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Chair'), findsNothing);
  });

  testWidgets('changement de langue FR depuis Profil > Paramètres', (tester) async {
    await launch(tester, FakeAuthRepository(loggedIn: true));

    await tester.tap(navItem('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('John Doe'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Langue'), findsOneWidget);
  });

  testWidgets('identifiants invalides : message d\'erreur, pas de navigation', (tester) async {
    await launch(
      tester,
      FakeAuthRepository(
        loginError: const Failure('x', type: FailureType.invalidCredentials),
      ),
    );

    await signIn(tester);

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/features/auth/presentation/auth_controller.dart';
import 'package:shop_app/features/auth/presentation/login_page.dart';
import 'package:shop_app/features/catalog/domain/catalog_repository.dart';
import 'package:shop_app/features/catalog/presentation/products_page.dart';
import 'package:shop_app/features/favorites/data/favorites_repository_impl.dart';
import 'package:shop_app/features/favorites/presentation/favorites_controller.dart';
import 'package:shop_app/features/settings/settings_controller.dart';
import 'package:shop_app/features/settings/settings_page.dart';

import '../fakes.dart';
import '../pump_app.dart';

void main() {
  testWidgets('accessibilité : cibles tactiles >= 48dp et éléments interactifs étiquetés',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(
      tester,
      const Scaffold(body: ProductsPage()),
      providers: [
        Provider<CatalogRepository>.value(value: FakeCatalogRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              FavoritesController(FavoritesRepositoryImpl(InMemoryPrefs())),
        ),
      ],
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('i18n : le login s\'affiche en anglais puis en français', (tester) async {
    final auth = AuthController(FakeAuthRepository());
    final providers = [ChangeNotifierProvider<AuthController>.value(value: auth)];

    await pumpApp(tester, const LoginPage(), providers: providers);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);

    await pumpApp(
      tester,
      const LoginPage(),
      providers: providers,
      locale: const Locale('fr'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bon retour'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Se connecter'), findsOneWidget);
  });

  testWidgets('réglages : choisir Français met à jour et persiste la langue', (tester) async {
    final prefs = InMemoryPrefs();
    final settings = SettingsController(prefs);
    await pumpApp(
      tester,
      const SettingsPage(),
      providers: [ChangeNotifierProvider<SettingsController>.value(value: settings)],
    );

    await tester.tap(find.text('Français'));
    await tester.pump();

    expect(settings.locale, const Locale('fr'));
    expect(prefs.map['locale'], 'fr');
  });
}

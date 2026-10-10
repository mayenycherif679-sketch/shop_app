import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/features/catalog/domain/catalog_repository.dart';
import 'package:shop_app/features/catalog/presentation/products_page.dart';
import 'package:shop_app/features/favorites/data/favorites_repository_impl.dart';
import 'package:shop_app/features/favorites/presentation/favorites_controller.dart';

import '../fakes.dart';
import '../pump_app.dart';

void main() {
  Future<void> pumpProducts(WidgetTester tester, {Locale locale = const Locale('en')}) {
    return pumpApp(
      tester,
      const Scaffold(body: ProductsPage()),
      locale: locale,
      providers: [
        Provider<CatalogRepository>.value(value: FakeCatalogRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              FavoritesController(FavoritesRepositoryImpl(InMemoryPrefs())),
        ),
      ],
    );
  }

  testWidgets('affiche les produits avec leur prix localisé', (tester) async {
    await pumpProducts(tester);
    await tester.pumpAndSettle();

    expect(find.text('Chair'), findsOneWidget);
    expect(find.text('Football'), findsOneWidget);
    expect(find.text('\$25.50'), findsOneWidget);
  });

  testWidgets('le prix suit la langue (FR)', (tester) async {
    await pumpProducts(tester, locale: const Locale('fr'));
    await tester.pumpAndSettle();

    expect(find.textContaining('25,50'), findsOneWidget);
  });

  testWidgets('toucher le cœur bascule le favori (tooltip mis à jour)', (tester) async {
    await pumpProducts(tester);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add to favorites'), findsNWidgets(3));

    await tester.tap(find.byTooltip('Add to favorites').first);
    await tester.pump();

    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    expect(find.byTooltip('Add to favorites'), findsNWidgets(2));
  });

  testWidgets('toucher un produit ouvre sa fiche détail', (tester) async {
    await pumpProducts(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chair'));
    await tester.pumpAndSettle();

    expect(find.text('A comfortable chair'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });
}

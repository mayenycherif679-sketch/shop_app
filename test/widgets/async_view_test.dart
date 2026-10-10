import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/utils/cached.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/core/widgets/async_controller.dart';

import '../pump_app.dart';

Widget _view(Future<Cached<List<String>>> Function() loader) =>
    ChangeNotifierProvider(
      create: (context) => AsyncController<List<String>>(loader)..load(),
      child: AsyncView<List<String>>(
        builder: (context, items) => ListView(
          children: [for (final item in items) Text(item)],
        ),
      ),
    );

void main() {
  testWidgets('erreur réseau : message + bouton Retry qui recharge', (tester) async {
    var calls = 0;
    await pumpApp(
      tester,
      Scaffold(
        body: _view(() async {
          calls++;
          if (calls == 1) {
            throw const Failure('x', type: FailureType.network);
          }
          return const Cached(['Hello']);
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('données du cache : bandeau hors-ligne visible', (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: _view(() async => const Cached(['Cached item'], fromCache: true))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cached item'), findsOneWidget);
    expect(
      find.text('Offline mode: showing data saved on this device.'),
      findsOneWidget,
    );
  });

  testWidgets('erreur serveur : message dédié en français', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: _view(() async => throw const Failure('x', type: FailureType.server)),
      ),
      locale: const Locale('fr'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Le serveur est indisponible. Réessaie plus tard.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}

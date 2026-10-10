import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/widgets/app_image.dart';

import '../pump_app.dart';

void main() {
  testWidgets('URL vide : placeholder, aucune requête réseau', (tester) async {
    await pumpApp(tester, const Scaffold(body: AppImage(url: '', width: 56, height: 56)));

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('l\'image est décodée à la taille d\'affichage (ResizeImage)', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: AppImage(url: 'https://img.test/a.png', width: 56, height: 56),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final expectedPixels = (56 * tester.view.devicePixelRatio).round();

    expect(image.image, isA<ResizeImage>());
    expect((image.image as ResizeImage).width, expectedPixels);
  });

  testWidgets('erreur de chargement : fallback "image cassée"', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: AppImage(url: 'https://img.test/a.png', width: 56, height: 56),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final context = tester.element(find.byType(Image));
    final fallback = image.errorBuilder!(context, Exception('boom'), StackTrace.empty);

    await pumpApp(tester, Scaffold(body: fallback));
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/features/favorites/data/favorites_repository_impl.dart';
import 'package:shop_app/features/favorites/presentation/favorites_controller.dart';

import 'fakes.dart';

void main() {
  group('FavoritesRepositoryImpl', () {
    test('est vide par défaut', () {
      expect(FavoritesRepositoryImpl(InMemoryPrefs()).load(), isEmpty);
    });

    test('save puis load restitue les produits', () async {
      final repo = FavoritesRepositoryImpl(InMemoryPrefs());
      await repo.save([sampleProducts[0], sampleProducts[1]]);

      final loaded = repo.load();

      expect(loaded.map((p) => p.title), ['Chair', 'Football']);
      expect(loaded.first.price, 25.5);
      expect(loaded.first.categoryName, 'Home');
    });

    test('données corrompues : liste vide, pas de crash', () {
      final repo = FavoritesRepositoryImpl(InMemoryPrefs({'favorites': '{not json'}));
      expect(repo.load(), isEmpty);
    });
  });

  group('FavoritesController', () {
    late InMemoryPrefs prefs;
    late FavoritesController controller;

    setUp(() {
      prefs = InMemoryPrefs();
      controller = FavoritesController(FavoritesRepositoryImpl(prefs));
    });

    test('toggle ajoute puis retire un favori', () async {
      await controller.toggle(sampleProducts[0]);
      expect(controller.isFavorite(1), true);

      await controller.toggle(sampleProducts[0]);
      expect(controller.isFavorite(1), false);
    });

    test('les favoris sont persistés et rechargés au redémarrage', () async {
      await controller.toggle(sampleProducts[2]);

      final restarted = FavoritesController(FavoritesRepositoryImpl(prefs));

      expect(restarted.items.single.title, 'Lamp');
    });

    test('notifie les listeners à chaque changement', () async {
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.toggle(sampleProducts[0]);
      await controller.toggle(sampleProducts[1]);

      expect(notified, 2);
    });
  });
}

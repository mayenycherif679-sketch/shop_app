import 'dart:convert';

import '../../../core/storage/preferences_store.dart';
import '../../catalog/data/models.dart';
import '../../catalog/domain/entities.dart';
import '../domain/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._prefs);
  final PreferencesStore _prefs;

  static const _key = 'favorites';

  @override
  List<Product> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    } catch (_) {
      return const []; // données corrompues : on repart de zéro plutôt que de planter
    }
  }

  @override
  Future<void> save(List<Product> items) =>
      _prefs.setString(_key, jsonEncode(items.map(ProductModel.encode).toList()));
}

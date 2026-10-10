import 'package:hive_flutter/hive_flutter.dart';

/// Préférences / données propres à l'appareil (langue, favoris).
/// Séparé du cache API : n'est PAS vidé à la déconnexion.
abstract class PreferencesStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class HivePreferencesStore implements PreferencesStore {
  HivePreferencesStore(this._box);
  final Box<String> _box;

  @override
  String? getString(String key) => _box.get(key);

  @override
  Future<void> setString(String key, String value) => _box.put(key, value);

  @override
  Future<void> remove(String key) => _box.delete(key);
}

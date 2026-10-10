import 'package:flutter/material.dart';

import '../../core/storage/preferences_store.dart';

/// Préférences utilisateur persistées. `locale == null` => langue du système.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    final code = _prefs.getString(_key);
    _locale = code == null ? null : Locale(code);
  }
  final PreferencesStore _prefs;

  static const _key = 'locale';

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, locale.languageCode);
    }
  }
}

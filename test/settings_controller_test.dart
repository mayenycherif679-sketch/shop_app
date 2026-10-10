import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/features/settings/settings_controller.dart';

import 'fakes.dart';

void main() {
  test('langue du système par défaut (locale null)', () {
    expect(SettingsController(InMemoryPrefs()).locale, isNull);
  });

  test('setLocale met à jour l\'état et persiste', () async {
    final prefs = InMemoryPrefs();
    final controller = SettingsController(prefs);

    await controller.setLocale(const Locale('fr'));

    expect(controller.locale, const Locale('fr'));
    expect(prefs.map['locale'], 'fr');
  });

  test('restaure la langue au démarrage', () {
    final controller = SettingsController(InMemoryPrefs({'locale': 'en'}));
    expect(controller.locale, const Locale('en'));
  });

  test('revenir à "système" supprime la préférence', () async {
    final prefs = InMemoryPrefs({'locale': 'fr'});
    final controller = SettingsController(prefs);

    await controller.setLocale(null);

    expect(controller.locale, isNull);
    expect(prefs.map.containsKey('locale'), false);
  });
}

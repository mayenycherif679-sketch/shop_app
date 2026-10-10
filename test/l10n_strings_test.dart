import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'package:shop_app/l10n/strings.dart';

void main() {
  test('FR et EN ont exactement les mêmes clés', () {
    expect(appStrings['fr']!.keys.toSet(), appStrings['en']!.keys.toSet());
  });

  test('aucune traduction vide', () {
    for (final entry in appStrings.entries) {
      for (final message in entry.value.entries) {
        expect(message.value.trim(), isNotEmpty, reason: '${entry.key}.${message.key}');
      }
    }
  });

  test('chaque FailureType a un message localisé dans chaque langue', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = AppLocalizations(locale);
      for (final type in FailureType.values) {
        expect(l10n.failureMessage(type), isNotEmpty);
      }
    }
  });

  test('le prix est formaté selon la langue', () {
    expect(AppLocalizations(const Locale('en')).price(25.5), '\$25.50');
    expect(AppLocalizations(const Locale('fr')).price(25.5), contains('25,50'));
  });
}

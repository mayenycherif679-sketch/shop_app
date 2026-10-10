import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import '../core/utils/failure.dart';
import 'strings.dart';

/// Localisation FR + EN.
///
/// Couche volontairement légère (sans génération de code) : les textes sont
/// dans `strings.dart`, `Intl` gère les formats (prix). Pour ajouter une
/// langue : ajouter une map dans `appStrings` + un `Locale` dans [supportedLocales].
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  late final NumberFormat _currency =
      NumberFormat.currency(locale: locale.toLanguageTag(), symbol: '\$');

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('en'), Locale('fr')];
  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  String _t(String key) =>
      appStrings[locale.languageCode]?[key] ?? appStrings['en']![key] ?? key;

  /// Prix formaté selon la langue (25.50 -> "$25.50" / "25,50 $").
  String price(double value) => _currency.format(value);

  /// Message utilisateur pour un type d'erreur.
  String failureMessage(FailureType? type) => switch (type) {
        FailureType.network => errNetwork,
        FailureType.invalidCredentials => errInvalidCredentials,
        FailureType.unauthorized => errUnauthorized,
        FailureType.forbidden => errForbidden,
        FailureType.notFound => errNotFound,
        FailureType.validation => errValidation,
        FailureType.server => errServer,
        _ => errUnknown,
      };

  String get appTitle => _t('appTitle');
  String get navProducts => _t('navProducts');
  String get navCategories => _t('navCategories');
  String get navFavorites => _t('navFavorites');
  String get navProfile => _t('navProfile');
  String get welcomeBack => _t('welcomeBack');
  String get createAccountTitle => _t('createAccountTitle');
  String get name => _t('name');
  String get email => _t('email');
  String get password => _t('password');
  String get nameRequired => _t('nameRequired');
  String get invalidEmail => _t('invalidEmail');
  String get passwordTooShort => _t('passwordTooShort');
  String get signIn => _t('signIn');
  String get signUp => _t('signUp');
  String get haveAccount => _t('haveAccount');
  String get noAccount => _t('noAccount');
  String get showPassword => _t('showPassword');
  String get hidePassword => _t('hidePassword');
  String get logout => _t('logout');
  String get logoutTitle => _t('logoutTitle');
  String get logoutMessage => _t('logoutMessage');
  String get cancel => _t('cancel');
  String get retry => _t('retry');
  String get refresh => _t('refresh');
  String get offlineBanner => _t('offlineBanner');
  String get addFavorite => _t('addFavorite');
  String get removeFavorite => _t('removeFavorite');
  String get favoritesEmptyTitle => _t('favoritesEmptyTitle');
  String get favoritesEmptyBody => _t('favoritesEmptyBody');
  String get settings => _t('settings');
  String get language => _t('language');
  String get languageSystem => _t('languageSystem');
  String get languageFrench => _t('languageFrench');
  String get languageEnglish => _t('languageEnglish');
  String get descriptionTitle => _t('descriptionTitle');
  String get errNetwork => _t('errNetwork');
  String get errInvalidCredentials => _t('errInvalidCredentials');
  String get errUnauthorized => _t('errUnauthorized');
  String get errForbidden => _t('errForbidden');
  String get errNotFound => _t('errNotFound');
  String get errValidation => _t('errValidation');
  String get errServer => _t('errServer');
  String get errUnknown => _t('errUnknown');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => appStrings.containsKey(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

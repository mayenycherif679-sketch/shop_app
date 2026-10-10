import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shop_app/l10n/app_localizations.dart';

/// Monte un widget dans un MaterialApp localisé (+ providers optionnels).
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<SingleChildWidget>? providers,
  Locale locale = const Locale('en'),
}) {
  final app = MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
  return tester.pumpWidget(
    providers == null ? app : MultiProvider(providers: providers, child: app),
  );
}

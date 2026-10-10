import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/catalog/domain/catalog_repository.dart';
import 'features/favorites/presentation/favorites_controller.dart';
import 'features/settings/settings_controller.dart';
import 'home_page.dart';
import 'l10n/app_localizations.dart';

/// Racine de l'application. Toutes les dépendances sont injectées :
/// la prod (main.dart) passe les vraies implémentations, les tests des fakes.
class ShopApp extends StatelessWidget {
  const ShopApp({
    super.key,
    required this.auth,
    required this.authRepository,
    required this.catalogRepository,
    required this.favorites,
    required this.settings,
  });

  final AuthController auth;
  final AuthRepository authRepository;
  final CatalogRepository catalogRepository;
  final FavoritesController favorites;
  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider<FavoritesController>.value(value: favorites),
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<CatalogRepository>.value(value: catalogRepository),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthController _auth = context.read<AuthController>();

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// Session perdue alors qu'une page est empilée (détail, réglages...) :
  /// on revient à la racine pour que l'écran de login soit bien visible.
  void _onAuthChanged() {
    if (_auth.status == AuthStatus.unauthenticated) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<SettingsController, Locale?>((s) => s.locale);
    final status = context.select<AuthController, AuthStatus>((a) => a.status);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: switch (status) {
        AuthStatus.unknown =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
        AuthStatus.authenticated => const HomePage(),
        AuthStatus.unauthenticated => const LoginPage(),
      },
    );
  }
}

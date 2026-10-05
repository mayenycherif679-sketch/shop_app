import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'core/storage/cache_store.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/catalog/data/catalog_remote_data_source.dart';
import 'features/catalog/data/catalog_repository_impl.dart';
import 'features/catalog/domain/catalog_repository.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final cache = HiveCacheStore(await Hive.openBox<String>('cache'));
  final tokens = SecureTokenStorage();

  // Composition root (injection manuelle des dépendances)
  late final AuthController auth;
  final dio = buildDio(tokens, () => auth.sessionExpired());
  final authRepo = AuthRepositoryImpl(AuthRemoteDataSource(dio), tokens, cache);
  final catalogRepo = CatalogRepositoryImpl(CatalogRemoteDataSource(dio), cache);
  auth = AuthController(authRepo)..restore();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: auth),
      Provider<AuthRepository>.value(value: authRepo),
      Provider<CatalogRepository>.value(value: catalogRepo),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthController>().status;
    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: switch (status) {
        AuthStatus.unknown => const Scaffold(body: Center(child: CircularProgressIndicator())),
        AuthStatus.authenticated => const HomePage(),
        AuthStatus.unauthenticated => const LoginPage(),
      },
    );
  }
}

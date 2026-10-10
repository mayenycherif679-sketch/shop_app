import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/storage/cache_store.dart';
import 'core/storage/preferences_store.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/catalog/data/catalog_remote_data_source.dart';
import 'features/catalog/data/catalog_repository_impl.dart';
import 'features/favorites/data/favorites_repository_impl.dart';
import 'features/favorites/presentation/favorites_controller.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final cache = HiveCacheStore(await Hive.openBox<String>('cache'));
  final prefs = HivePreferencesStore(await Hive.openBox<String>('prefs'));
  final tokens = SecureTokenStorage();

  // Composition root : une seule instance Dio, partagée par tous les data sources.
  late final AuthController auth;
  final dio = buildDio(tokens, () => auth.sessionExpired());
  final authRepo = AuthRepositoryImpl(AuthRemoteDataSource(dio), tokens, cache);
  final catalogRepo = CatalogRepositoryImpl(CatalogRemoteDataSource(dio), cache);
  auth = AuthController(authRepo)..restore();

  runApp(ShopApp(
    auth: auth,
    authRepository: authRepo,
    catalogRepository: catalogRepo,
    favorites: FavoritesController(FavoritesRepositoryImpl(prefs)),
    settings: SettingsController(prefs),
  ));
}

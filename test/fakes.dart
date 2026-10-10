import 'package:shop_app/core/storage/preferences_store.dart';
import 'package:shop_app/core/utils/cached.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/features/auth/domain/auth_repository.dart';
import 'package:shop_app/features/auth/domain/user.dart';
import 'package:shop_app/features/catalog/domain/catalog_repository.dart';
import 'package:shop_app/features/catalog/domain/entities.dart';

// Images vides => aucun appel réseau dans les tests.
const sampleProducts = [
  Product(
    id: 1,
    title: 'Chair',
    price: 25.5,
    description: 'A comfortable chair',
    images: [],
    categoryName: 'Home',
  ),
  Product(
    id: 2,
    title: 'Football',
    price: 12,
    description: 'A round ball',
    images: [],
    categoryName: 'Sports',
  ),
  Product(
    id: 3,
    title: 'Lamp',
    price: 40,
    description: 'A bright lamp',
    images: [],
    categoryName: 'Home',
  ),
];

const sampleCategories = [
  Category(id: 1, name: 'Home', image: ''),
  Category(id: 2, name: 'Sports', image: ''),
];

const sampleUser = User(
  id: 1,
  name: 'John Doe',
  email: 'john@mail.com',
  avatar: '',
  role: 'customer',
);

class InMemoryPrefs implements PreferencesStore {
  InMemoryPrefs([Map<String, String>? initial]) : map = {...?initial};
  final Map<String, String> map;

  @override
  String? getString(String key) => map[key];
  @override
  Future<void> setString(String key, String value) async => map[key] = value;
  @override
  Future<void> remove(String key) async => map.remove(key);
}

class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository({this.error, this.fromCache = false});
  final Failure? error;
  final bool fromCache;

  @override
  Future<Cached<List<Product>>> getProducts() async {
    if (error != null) throw error!;
    return Cached(sampleProducts, fromCache: fromCache);
  }

  @override
  Future<Cached<List<Category>>> getCategories() async {
    if (error != null) throw error!;
    return Cached(sampleCategories, fromCache: fromCache);
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.loggedIn = false, this.loginError});
  bool loggedIn;
  final Failure? loginError;

  @override
  Future<User?> restoreSession() async => loggedIn ? sampleUser : null;

  @override
  Future<User> login(String email, String password) async {
    if (loginError != null) throw loginError!;
    loggedIn = true;
    return sampleUser;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) =>
      login(email, password);

  @override
  Future<Cached<User>> getProfile() async => const Cached(sampleUser);

  @override
  Future<void> logout() async => loggedIn = false;
}

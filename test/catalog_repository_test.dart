import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/features/catalog/data/catalog_remote_data_source.dart';
import 'package:shop_app/features/catalog/data/catalog_repository_impl.dart';

import 'helpers.dart';

class MockRemote extends Mock implements CatalogRemoteDataSource {}

final _products = [
  {
    'id': 1,
    'title': 'Chaise',
    'price': 25,
    'description': 'Une chaise',
    'images': ['["https://img.test/1.png"]'],
    'category': {'id': 1, 'name': 'Maison', 'image': 'https://img.test/c.png'},
  }
];
final _categories = [
  {'id': 1, 'name': 'Maison', 'image': 'https://img.test/c.png'},
  {'id': 2, 'name': 'Sport', 'image': 'https://img.test/s.png'},
];

void main() {
  late MockRemote remote;
  late FakeCache cache;
  late CatalogRepositoryImpl repo;

  setUp(() {
    remote = MockRemote();
    cache = FakeCache();
    repo = CatalogRepositoryImpl(remote, cache);
  });

  test('produits : données réseau + mise en cache + nettoyage des URLs', () async {
    when(() => remote.products()).thenAnswer((_) async => _products);

    final r = await repo.getProducts();

    expect(r.fromCache, false);
    expect(r.data.single.title, 'Chaise');
    expect(r.data.single.images.single, 'https://img.test/1.png');
    expect(cache.read('products'), isNotNull);
  });

  test('catégories : données réseau + mise en cache', () async {
    when(() => remote.categories()).thenAnswer((_) async => _categories);

    final r = await repo.getCategories();

    expect(r.data.map((c) => c.name), ['Maison', 'Sport']);
    expect(cache.read('categories'), hasLength(2));
  });

  test('hors-ligne : renvoie le cache si le réseau est indisponible', () async {
    cache.store['products'] = _products;
    when(() => remote.products()).thenThrow(dioError(DioExceptionType.connectionError));

    final r = await repo.getProducts();

    expect(r.fromCache, true);
    expect(r.data.single.categoryName, 'Maison');
  });

  test('timeout : bascule aussi sur le cache', () async {
    cache.store['categories'] = _categories;
    when(() => remote.categories()).thenThrow(dioError(DioExceptionType.receiveTimeout));

    final r = await repo.getCategories();

    expect(r.fromCache, true);
    expect(r.data, hasLength(2));
  });

  test('hors-ligne sans cache : Failure réseau lisible', () async {
    when(() => remote.categories()).thenThrow(dioError(DioExceptionType.connectionTimeout));

    expect(
      repo.getCategories(),
      throwsA(isA<Failure>().having((f) => f.type, 'type', FailureType.network)),
    );
  });

  test('erreur serveur 500 : n\'est PAS masquée par le cache', () async {
    cache.store['products'] = _products;
    when(() => remote.products())
        .thenThrow(dioError(DioExceptionType.badResponse, status: 500));

    expect(
      repo.getProducts(),
      throwsA(isA<Failure>().having((f) => f.type, 'type', FailureType.server)),
    );
  });

  test('403 : Failure "forbidden", pas de fallback cache', () async {
    cache.store['products'] = _products;
    when(() => remote.products())
        .thenThrow(dioError(DioExceptionType.badResponse, status: 403));

    expect(
      repo.getProducts(),
      throwsA(isA<Failure>().having((f) => f.type, 'type', FailureType.forbidden)),
    );
  });
}

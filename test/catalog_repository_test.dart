import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/core/storage/cache_store.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/features/catalog/data/catalog_remote_data_source.dart';
import 'package:shop_app/features/catalog/data/catalog_repository_impl.dart';

class MockRemote extends Mock implements CatalogRemoteDataSource {}

class FakeCache implements CacheStore {
  final store = <String, dynamic>{};
  @override
  Future<void> write(String key, dynamic json) async => store[key] = json;
  @override
  dynamic read(String key) => store[key];
  @override
  Future<void> clear() async => store.clear();
}

final _json = [
  {
    'id': 1,
    'title': 'Chaise',
    'price': 25,
    'description': 'Une chaise',
    'images': ['["https://img.test/1.png"]'],
    'category': {'id': 1, 'name': 'Maison', 'image': 'https://img.test/c.png'},
  }
];

DioException _dioError(DioExceptionType type, {int? status}) {
  final req = RequestOptions(path: '/products');
  return DioException(
    requestOptions: req,
    type: type,
    response: status == null ? null : Response(requestOptions: req, statusCode: status),
  );
}

void main() {
  late MockRemote remote;
  late FakeCache cache;
  late CatalogRepositoryImpl repo;

  setUp(() {
    remote = MockRemote();
    cache = FakeCache();
    repo = CatalogRepositoryImpl(remote, cache);
  });

  test('retourne les données réseau et les met en cache', () async {
    when(() => remote.products()).thenAnswer((_) async => _json);

    final result = await repo.getProducts();

    expect(result.fromCache, false);
    expect(result.data.single.title, 'Chaise');
    expect(result.data.single.images.single, 'https://img.test/1.png'); // nettoyage
    expect(cache.read('products'), isNotNull);
  });

  test('hors-ligne : renvoie le cache si le réseau est indisponible', () async {
    cache.store['products'] = _json;
    when(() => remote.products())
        .thenThrow(_dioError(DioExceptionType.connectionError));

    final result = await repo.getProducts();

    expect(result.fromCache, true);
    expect(result.data.single.categoryName, 'Maison');
  });

  test('hors-ligne sans cache : lève une Failure réseau lisible', () async {
    when(() => remote.categories())
        .thenThrow(_dioError(DioExceptionType.connectionTimeout));

    expect(
      repo.getCategories(),
      throwsA(isA<Failure>().having((f) => f.isNetwork, 'isNetwork', true)),
    );
  });

  test('erreur serveur 500 : ne masque pas l\'erreur avec le cache', () async {
    cache.store['products'] = _json;
    when(() => remote.products())
        .thenThrow(_dioError(DioExceptionType.badResponse, status: 500));

    expect(
      repo.getProducts(),
      throwsA(isA<Failure>().having((f) => f.isNetwork, 'isNetwork', false)),
    );
  });
}

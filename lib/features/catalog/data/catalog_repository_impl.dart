import '../../../core/storage/cache_store.dart';
import '../../../core/utils/cached.dart';
import '../domain/catalog_repository.dart';
import '../domain/entities.dart';
import 'catalog_remote_data_source.dart';
import 'models.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote, this._cache);
  final CatalogRemoteDataSource _remote;
  final CacheStore _cache;

  @override
  Future<Cached<List<Product>>> getProducts() => cachedFetch<List<Product>>(
        cache: _cache,
        key: 'products',
        remote: _remote.products,
        parse: (j) => (j as List)
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  @override
  Future<Cached<List<Category>>> getCategories() => cachedFetch<List<Category>>(
        cache: _cache,
        key: 'categories',
        remote: _remote.categories,
        parse: (j) => (j as List)
            .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

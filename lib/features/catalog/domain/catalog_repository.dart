import '../../../core/utils/cached.dart';
import 'entities.dart';

abstract class CatalogRepository {
  Future<Cached<List<Product>>> getProducts();
  Future<Cached<List<Category>>> getCategories();
}

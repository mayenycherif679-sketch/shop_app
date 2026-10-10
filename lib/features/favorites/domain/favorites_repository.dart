import '../../catalog/domain/entities.dart';

abstract class FavoritesRepository {
  List<Product> load();
  Future<void> save(List<Product> items);
}

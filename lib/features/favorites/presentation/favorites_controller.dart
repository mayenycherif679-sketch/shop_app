import 'package:flutter/foundation.dart';

import '../../catalog/domain/entities.dart';
import '../domain/favorites_repository.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController(this._repo) : _items = _repo.load();
  final FavoritesRepository _repo;

  // Liste immuable remplacée à chaque changement : `select` compare par identité.
  List<Product> _items;
  List<Product> get items => _items;

  bool isFavorite(int productId) => _items.any((p) => p.id == productId);

  Future<void> toggle(Product product) async {
    _items = isFavorite(product.id)
        ? _items.where((p) => p.id != product.id).toList(growable: false)
        : [product, ..._items];
    notifyListeners();
    await _repo.save(_items);
  }
}

import '../domain/entities.dart';

class CategoryModel extends Category {
  const CategoryModel({required super.id, required super.name, required super.image});

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        image: _cleanImages([j['image']]).firstOrNull ?? '',
      );
}

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.images,
    required super.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        description: j['description'] as String? ?? '',
        images: _cleanImages(j['images'] as List?),
        categoryName: (j['category'] as Map?)?['name'] as String? ?? '',
      );
}

/// L'API renvoie parfois des URLs entourées de ["..."] : on nettoie.
List<String> _cleanImages(List? raw) => (raw ?? [])
    .map((e) => e.toString().replaceAll(RegExp(r'[\[\]"]'), ''))
    .where((s) => s.startsWith('http'))
    .toList();

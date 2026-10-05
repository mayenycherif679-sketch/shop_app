class Category {
  const Category({required this.id, required this.name, required this.image});
  final int id;
  final String name;
  final String image;
}

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    required this.categoryName,
  });
  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;
  final String categoryName;
}

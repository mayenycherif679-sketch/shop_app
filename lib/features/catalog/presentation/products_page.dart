import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/async_controller.dart';
import '../domain/catalog_repository.dart';
import '../domain/entities.dart';
import 'product_tile.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AsyncController<List<Product>>(
        context.read<CatalogRepository>().getProducts,
      )..load(),
      child: AsyncView<List<Product>>(
        // ListView.builder + itemExtent : construction paresseuse, mise en page O(1).
        builder: (context, items) => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemExtent: 80,
          itemCount: items.length,
          itemBuilder: (context, index) => ProductTile(product: items[index]),
        ),
      ),
    );
  }
}

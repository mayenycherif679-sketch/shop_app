import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/async_controller.dart';
import '../domain/catalog_repository.dart';
import '../domain/entities.dart';

Widget _img(String? url, {double? size}) => url == null || url.isEmpty
    ? SizedBox(width: size, height: size, child: const Icon(Icons.image_not_supported))
    : Image.network(url, width: size, height: size, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            SizedBox(width: size, height: size, child: const Icon(Icons.broken_image)));

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) =>
          AsyncController<List<Product>>(c.read<CatalogRepository>().getProducts)..load(),
      child: AsyncView<List<Product>>(
        builder: (context, items) => ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final p = items[i];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _img(p.images.firstOrNull, size: 56),
              ),
              title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(p.categoryName),
              trailing: Text('\$${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (_) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(p.description),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) =>
          AsyncController<List<Category>>(c.read<CatalogRepository>().getCategories)..load(),
      child: AsyncView<List<Category>>(
        builder: (context, items) => GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
          itemCount: items.length,
          itemBuilder: (_, i) => Card(
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: _img(items[i].image)),
              Padding(padding: const EdgeInsets.all(8), child: Text(items[i].name, textAlign: TextAlign.center)),
            ]),
          ),
        ),
      ),
    );
  }
}

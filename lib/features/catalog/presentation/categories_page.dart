import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/async_controller.dart';
import '../domain/catalog_repository.dart';
import '../domain/entities.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AsyncController<List<Category>>(
        context.read<CatalogRepository>().getCategories,
      )..load(),
      child: AsyncView<List<Category>>(
        builder: (context, items) => GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final category = items[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AppImage(url: category.image, decodeWidth: 220),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

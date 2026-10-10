import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../domain/entities.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  static const _galleryHeight = 280.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final isFavorite = context
        .select<FavoritesController, bool>((c) => c.isFavorite(product.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => context.read<FavoritesController>().toggle(product),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: _galleryHeight,
            // PageView.builder : seule la page visible (et voisine) charge son image.
            child: product.images.isEmpty
                ? AppImage(url: null, width: width, height: _galleryHeight)
                : PageView.builder(
                    itemCount: product.images.length,
                    itemBuilder: (context, index) => AppImage(
                      url: product.images[index],
                      width: width,
                      height: _galleryHeight,
                      semanticLabel: product.title,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.price(product.price), style: textTheme.headlineSmall),
                ),
                const SizedBox(height: 8),
                Chip(label: Text(product.categoryName)),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(l10n.descriptionTitle, style: textTheme.titleMedium),
                ),
                const SizedBox(height: 4),
                Text(product.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

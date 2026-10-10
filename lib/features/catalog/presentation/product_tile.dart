import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../domain/entities.dart';
import 'product_detail_page.dart';

/// Ligne produit. `select` => seule la ligne dont le statut favori change
/// est reconstruite (pas toute la liste).
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFavorite = context
        .select<FavoritesController, bool>((c) => c.isFavorite(product.id));

    return ListTile(
      leading: AppImage(
        url: product.images.firstOrNull,
        width: 56,
        height: 56,
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(product.categoryName, maxLines: 1),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.price(product.price),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => context.read<FavoritesController>().toggle(product),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ProductDetailPage(product: product),
        ),
      ),
    );
  }
}

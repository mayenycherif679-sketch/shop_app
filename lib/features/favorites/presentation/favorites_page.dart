import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../catalog/domain/entities.dart';
import '../../catalog/presentation/product_tile.dart';
import 'favorites_controller.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items =
        context.select<FavoritesController, List<Product>>((c) => c.items);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const ExcludeSemantics(child: Icon(Icons.favorite_border, size: 64)),
            const SizedBox(height: 12),
            Text(
              l10n.favoritesEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.favoritesEmptyBody, textAlign: TextAlign.center),
          ]),
        ),
      );
    }
    return ListView.builder(
      itemExtent: 80,
      itemCount: items.length,
      itemBuilder: (context, index) => ProductTile(product: items[index]),
    );
  }
}

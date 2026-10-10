import 'package:flutter/material.dart';

/// Image réseau optimisée :
/// - **décodée à la taille d'affichage** (`cacheWidth` = largeur logique × pixel ratio)
///   => beaucoup moins de mémoire qu'un décodage pleine résolution ;
/// - **lazy** : n'est construite que si le parent (ListView/GridView.builder) la montre ;
/// - fondu à l'apparition, placeholder si URL vide, fallback si erreur ;
/// - `semanticLabel` pour les lecteurs d'écran (exclue de l'arbre sinon).
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.decodeWidth,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.borderRadius = BorderRadius.zero,
  });

  final String? url;
  final double? width;
  final double? height;

  /// Largeur logique de décodage quand [width] est inconnue (ex. cellule de grille).
  final double? decodeWidth;
  final BoxFit fit;
  final String? semanticLabel;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget placeholder(IconData icon) => Container(
          width: width,
          height: height,
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(icon, color: scheme.onSurfaceVariant),
        );

    final source = url;
    final Widget child;
    if (source == null || source.isEmpty) {
      child = placeholder(Icons.image_outlined);
    } else {
      final target = decodeWidth ?? width;
      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
      child = Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: (target != null && target.isFinite)
            ? (target * pixelRatio).round()
            : null,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        frameBuilder: (context, image, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return image;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: image,
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            placeholder(Icons.broken_image_outlined),
      );
    }
    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}

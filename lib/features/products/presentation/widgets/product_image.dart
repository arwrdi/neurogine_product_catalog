import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    const fallback = Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        semanticLabel: 'Image unavailable',
      ),
    );
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child:
          url.isEmpty
              ? fallback
              : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder:
                    (_, _) => const Center(
                      child: SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                errorWidget: (_, _, _) => fallback,
              ),
    );
  }
}

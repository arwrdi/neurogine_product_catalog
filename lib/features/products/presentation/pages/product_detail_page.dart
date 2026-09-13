import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../controllers/product_detail_controller.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/product_image.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create:
        (context) => ProductDetailController(
          context.read<ProductRepository>(),
          productId,
        )..loadProduct(),
    child: Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: SafeArea(
        child: Consumer<ProductDetailController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage != null) {
              return AppErrorState(
                message: controller.errorMessage!,
                onRetry: controller.loadProduct,
              );
            }
            final product = controller.product;
            if (product == null) return const AppEmptyState();
            return _ProductDetails(product: product);
          },
        ),
      ),
    ),
  );
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images =
        product.images.isNotEmpty ? product.images : [product.thumbnail];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ProductImage(url: images[index]),
                  ),
                ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Swipe to view ${images.length} images',
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        Text(
          product.category.replaceAll('-', ' '),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Text(product.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('★ ${product.rating.toStringAsFixed(1)} / 5')),
            if (product.discountPercentage > 0)
              Chip(
                label: Text(
                  '${product.discountPercentage.toStringAsFixed(1)}% discount',
                ),
              ),
            Chip(
              label: Text(
                product.stock > 0
                    ? '${product.stock} in stock'
                    : 'Out of stock',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Brand: ${product.brand?.trim().isNotEmpty == true ? product.brand : 'Not specified'}',
        ),
        const SizedBox(height: 24),
        Text('About this product', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(product.description, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/product_controller.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadNearBottom);
  }

  void _loadNearBottom() {
    if (!mounted || !_scrollController.hasClients) return;
    final controller = context.read<ProductController>();
    if (_scrollController.position.extentAfter < 300 &&
        controller.loadMoreErrorMessage == null) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog')),
      body: SafeArea(child: _buildBody(controller)),
    );
  }

  Widget _buildBody(ProductController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage != null) {
      return AppErrorState(
        message: controller.errorMessage!,
        onRetry: controller.retry,
      );
    }
    final products = controller.products;
    if (products.isEmpty) return const AppEmptyState();
    // Also fill tall viewports where the first page may not be scrollable yet.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearBottom());
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid.builder(
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 160 + 150 * scale,
            ),
            itemBuilder:
                (context, index) => ProductCard(product: products[index]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                controller.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : controller.loadMoreErrorMessage != null
                    ? AppErrorState(
                      message: controller.loadMoreErrorMessage!,
                      onRetry: controller.retry,
                    )
                    : !controller.hasMore
                    ? const Center(child: Text('You have seen all products'))
                    : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

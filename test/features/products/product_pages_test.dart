import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:neurogine_product_catalog/features/products/data/models/product_model.dart';
import 'package:neurogine_product_catalog/features/products/data/repositories/product_repository.dart';
import 'package:neurogine_product_catalog/features/products/presentation/controllers/product_controller.dart';
import 'package:neurogine_product_catalog/features/products/presentation/pages/product_list_page.dart';
import 'product_controller_test.dart' show FakeRepository, page;

class PageRepository extends FakeRepository {
  final details = <Completer<ProductModel>>[];
  final detailIds = <int>[];

  @override
  Future<ProductModel> getProductById(int id) {
    detailIds.add(id);
    final result = Completer<ProductModel>();
    details.add(result);
    return result.future;
  }
}

void main() {
  testWidgets(
    'catalog retries error, opens fresh detail, retries and returns',
    (tester) async {
      final repository = PageRepository();
      final controller = ProductController(repository)..loadProducts();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: repository),
            ChangeNotifierProvider<ProductController>.value(value: controller),
          ],
          child: const MaterialApp(home: ProductListPage()),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.requests[0].result.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      repository.requests[1].result.complete(page([1, 2], total: 2));
      await tester.pumpAndSettle();
      expect(find.text('Product 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Product 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(repository.detailIds, [1]);
      repository.details[0].completeError(Exception('offline'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry'));
      await tester.pump();
      repository.details[1].complete(page([1]).products.single);
      await tester.pumpAndSettle();
      expect(find.text('Product details'), findsOneWidget);
      expect(find.text('Product 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Product Catalog'), findsOneWidget);
      expect(repository.requests, hasLength(2));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets('empty catalog is distinct from loading and error', (
    tester,
  ) async {
    final repository = FakeRepository();
    final controller = ProductController(repository)..loadProducts();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: ProductListPage()),
      ),
    );
    repository.requests[0].result.complete(page([], total: 0));
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Retry'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}

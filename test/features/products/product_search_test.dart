import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:neurogine_product_catalog/features/products/presentation/controllers/product_controller.dart';
import 'package:neurogine_product_catalog/features/products/presentation/pages/product_list_page.dart';
import 'package:neurogine_product_catalog/features/products/presentation/widgets/product_search_field.dart';
import 'product_controller_test.dart' show FakeRepository, page;

void main() {
  testWidgets('typing debounces and clearing cancels pending search', (
    tester,
  ) async {
    final queries = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductSearchField(onSearch: queries.add)),
      ),
    );
    await tester.enterText(find.byType(TextField), 'ph');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'phone');
    await tester.pump(const Duration(milliseconds: 449));
    expect(queries, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(queries, ['phone']);
    await tester.enterText(find.byType(TextField), 'laptop');
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(queries, ['phone', '']);
  });

  testWidgets('submit runs once and disposal cancels the timer', (
    tester,
  ) async {
    final queries = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductSearchField(onSearch: queries.add)),
      ),
    );
    await tester.enterText(find.byType(TextField), ' phone ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump(const Duration(milliseconds: 500));
    expect(queries, ['phone']);
    await tester.enterText(find.byType(TextField), 'pending');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 500));
    expect(queries, ['phone']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search resets offset and clearing returns to the catalog', (
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
    repository.requests[0].result.complete(page([1, 2], total: 2));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'phone');
    await tester.pump(const Duration(milliseconds: 450));
    expect(repository.requests[1].query, 'phone');
    expect(repository.requests[1].skip, 0);
    expect(controller.products, isEmpty);
    repository.requests[1].result.complete(page([], total: 0));
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(repository.requests[2].query, '');
    expect(repository.requests[2].skip, 0);
    repository.requests[2].result.complete(page([1], total: 1));
    await tester.pumpAndSettle();
    expect(find.text('Product 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}

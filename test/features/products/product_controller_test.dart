import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:neurogine_product_catalog/features/products/data/models/product_model.dart';
import 'package:neurogine_product_catalog/features/products/data/models/product_response_model.dart';
import 'package:neurogine_product_catalog/features/products/data/repositories/product_repository.dart';
import 'package:neurogine_product_catalog/features/products/presentation/controllers/product_controller.dart';

class PendingPage {
  PendingPage(this.skip, this.query);
  final int skip;
  final String query;
  final result = Completer<ProductResponseModel>();
}

class FakeRepository implements ProductRepository {
  final requests = <PendingPage>[];

  @override
  Future<ProductResponseModel> getProducts({
    int skip = 0,
    int limit = 20,
    String query = '',
  }) {
    final request = PendingPage(skip, query);
    requests.add(request);
    return request.result.future;
  }

  @override
  Future<ProductModel> getProductById(int id) => throw UnimplementedError();
}

ProductResponseModel page(List<int> ids, {int skip = 0, int total = 4}) {
  return ProductResponseModel(
    products:
        ids
            .map(
              (id) => ProductModel.fromJson({
                'id': id,
                'title': 'Product $id',
                'description': 'Description',
                'price': 10,
                'discountPercentage': 0,
                'rating': 4,
                'stock': 1,
                'category': 'test',
              }),
            )
            .toList(),
    total: total,
    skip: skip,
    limit: 20,
  );
}

void main() {
  late FakeRepository repository;
  late ProductController controller;

  setUp(() {
    repository = FakeRepository();
    controller = ProductController(repository);
  });
  tearDown(() => controller.dispose());

  test('guards load more, deduplicates IDs, and stops at total', () async {
    final initial = controller.loadProducts();
    expect(controller.isLoading, isTrue);
    await controller.loadMore();
    expect(repository.requests, hasLength(1));
    repository.requests[0].result.complete(page([1, 2]));
    await initial;
    final more = controller.loadMore();
    await controller.loadMore();
    expect(repository.requests, hasLength(2));
    expect(repository.requests[1].skip, 2);
    repository.requests[1].result.complete(page([2, 3], skip: 2));
    await more;
    expect(controller.products.map((p) => p.id), [1, 2, 3]);
    expect(controller.skip, 4);
    expect(controller.hasMore, isFalse);
    await controller.loadMore();
    expect(repository.requests, hasLength(2));
  });

  test(
    'pagination failure preserves data and retry uses the same skip',
    () async {
      final initial = controller.loadProducts();
      repository.requests[0].result.complete(page([1, 2]));
      await initial;
      final more = controller.loadMore();
      repository.requests[1].result.completeError(Exception('offline'));
      await more;
      expect(controller.products, hasLength(2));
      expect(controller.errorMessage, isNull);
      expect(controller.loadMoreErrorMessage, isNotNull);
      final retry = controller.retry();
      expect(repository.requests[2].skip, 2);
      repository.requests[2].result.complete(page([3, 4], skip: 2));
      await retry;
      expect(controller.loadMoreErrorMessage, isNull);
      expect(controller.products, hasLength(4));
    },
  );

  test(
    'new search ignores stale responses and refresh retains query',
    () async {
      final old = controller.loadProducts();
      final search = controller.searchProducts(' phone ');
      expect(repository.requests[1].query, 'phone');
      repository.requests[1].result.complete(page([3], total: 1));
      await search;
      repository.requests[0].result.completeError(Exception('stale failure'));
      await old;
      expect(controller.products.single.id, 3);
      expect(controller.errorMessage, isNull);
      final refresh = controller.refreshProducts();
      expect(controller.products, isEmpty);
      expect(repository.requests[2].query, 'phone');
      expect(repository.requests[2].skip, 0);
      repository.requests[2].result.complete(page([], total: 0));
      await refresh;
      expect(controller.hasMore, isFalse);
      final cleared = controller.searchProducts('');
      expect(repository.requests[3].query, '');
      repository.requests[3].result.complete(page([1]));
      await cleared;
    },
  );

  test('initial error can be retried', () async {
    final initial = controller.loadProducts();
    repository.requests[0].result.completeError(Exception('offline'));
    await initial;
    expect(controller.errorMessage, isNotNull);
    expect(controller.isLoading, isFalse);
    final retry = controller.retry();
    repository.requests[1].result.complete(page([1]));
    await retry;
    expect(controller.errorMessage, isNull);
    expect(controller.products, hasLength(1));
  });

  test('completion after dispose does not notify listeners', () async {
    final disposable = ProductController(repository);
    var notifications = 0;
    disposable.addListener(() => notifications++);
    final initial = disposable.loadProducts();
    disposable.dispose();
    repository.requests[0].result.complete(page([1]));
    await initial;
    expect(notifications, 1);
  });
}

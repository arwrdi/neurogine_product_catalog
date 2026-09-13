import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/models/product_response_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  ProductController(this._repository);

  final ProductRepository _repository;
  final List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String? _loadMoreErrorMessage;
  String _query = '';
  int _skip = 0;
  int _requestVersion = 0;
  bool _disposed = false;

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String? get loadMoreErrorMessage => _loadMoreErrorMessage;
  String get query => _query;
  int get skip => _skip;

  Future<void> loadProducts() async {
    if (_disposed) return;
    // A refresh or new query makes all earlier responses obsolete.
    final version = ++_requestVersion;
    _products.clear();
    _skip = 0;
    _hasMore = true;
    _isLoading = true;
    _isLoadingMore = false;
    _errorMessage = null;
    _loadMoreErrorMessage = null;
    notifyListeners();

    try {
      final page = await _repository.getProducts(query: _query);
      if (!_isCurrent(version)) return;
      _appendPage(page);
    } catch (error) {
      if (!_isCurrent(version)) return;
      _errorMessage = _messageFor(error);
    } finally {
      if (_isCurrent(version)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_disposed ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _errorMessage != null ||
        _products.isEmpty) {
      return;
    }
    final version = _requestVersion;
    _isLoadingMore = true;
    _loadMoreErrorMessage = null;
    notifyListeners();

    try {
      final page = await _repository.getProducts(skip: _skip, query: _query);
      if (!_isCurrent(version)) return;
      _appendPage(page);
    } catch (error) {
      if (!_isCurrent(version)) return;
      _loadMoreErrorMessage = _messageFor(error);
    } finally {
      if (_isCurrent(version)) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshProducts() => loadProducts();

  // The search field debounces typing before calling this method.
  Future<void> searchProducts(String query) async {
    if (_disposed || query.trim() == _query) return;
    _query = query.trim();
    await loadProducts();
  }

  Future<void> retry() async {
    if (_disposed || _isLoading || _isLoadingMore) return;
    if (_loadMoreErrorMessage != null) {
      await loadMore();
    } else if (_errorMessage != null) {
      await loadProducts();
    }
  }

  void _appendPage(ProductResponseModel page) {
    final existingIds = _products.map((product) => product.id).toSet();
    _products.addAll(
      page.products.where((product) => existingIds.add(product.id)),
    );
    // Advance by the server's page size, not the deduplicated item count.
    _skip = page.skip + page.products.length;
    _hasMore = page.products.isNotEmpty && _skip < page.total;
  }

  bool _isCurrent(int version) => !_disposed && version == _requestVersion;

  String _messageFor(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The request timed out. Please try again.';
        case DioExceptionType.connectionError:
          return 'Unable to connect. Check your internet connection and retry.';
        default:
          return 'Unable to load products. Please try again.';
      }
    }
    return 'Unable to load products. Please try again.';
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}

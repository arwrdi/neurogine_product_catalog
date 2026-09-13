import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductDetailController extends ChangeNotifier {
  ProductDetailController(this._repository, this.productId);
  final ProductRepository _repository;
  final int productId;
  ProductModel? _product;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  ProductModel? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProduct() async {
    if (_disposed || _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final product = await _repository.getProductById(productId);
      if (!_disposed) _product = product;
    } catch (_) {
      if (!_disposed) {
        _errorMessage = 'Unable to load this product. Please try again.';
      }
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import '../../../../core/constants/api_constants.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';
import '../models/product_response_model.dart';

/// Entry point for product data used by presentation controllers.
class ProductRepository {
  ProductRepository(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  Future<ProductResponseModel> getProducts({
    int skip = 0,
    int limit = ApiConstants.pageSize,
    String query = '',
  }) {
    return _remoteDataSource.getProducts(
      skip: skip,
      limit: limit,
      query: query,
    );
  }

  Future<ProductModel> getProductById(int id) {
    return _remoteDataSource.getProductById(id);
  }
}

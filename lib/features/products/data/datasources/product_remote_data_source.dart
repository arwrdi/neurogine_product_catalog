import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../models/product_response_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProductResponseModel> getProducts({
    int skip = 0,
    int limit = ApiConstants.pageSize,
    String query = '',
  }) async {
    if (skip < 0) {
      throw ArgumentError.value(skip, 'skip', 'Must not be negative');
    }
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be positive');
    }

    final searchQuery = query.trim();
    final response = await _dio.get<Map<String, dynamic>>(
      searchQuery.isEmpty ? ApiConstants.products : ApiConstants.productSearch,
      queryParameters: {
        'limit': limit,
        'skip': skip,
        if (searchQuery.isNotEmpty) 'q': searchQuery,
      },
    );

    return ProductResponseModel.fromJson(_requireData(response));
  }

  Future<ProductModel> getProductById(int id) async {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'Must be positive');
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.products}/$id',
    );
    return ProductModel.fromJson(_requireData(response));
  }

  Map<String, dynamic> _requireData(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) {
      throw const FormatException('The product API returned an empty body.');
    }
    return data;
  }
}

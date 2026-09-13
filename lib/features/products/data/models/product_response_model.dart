import 'product_model.dart';

class ProductResponseModel {
  const ProductResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      products: List<ProductModel>.unmodifiable(
        (json['products'] as List<dynamic>).map(
          (item) => ProductModel.fromJson(item as Map<String, dynamic>),
        ),
      ),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }
}

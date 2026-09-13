import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

Dio createDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      headers: {'Accept': 'application/json'},
    ),
  );
}

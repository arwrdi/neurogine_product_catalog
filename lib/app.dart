import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository.dart';
import 'features/products/presentation/controllers/product_controller.dart';
import 'features/products/presentation/pages/product_list_page.dart';

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>(
          create: (_) => createDioClient(),
          dispose: (_, dio) => dio.close(),
        ),
        Provider<ProductRepository>(
          create:
              (context) => ProductRepository(
                ProductRemoteDataSource(context.read<Dio>()),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) =>
                  ProductController(context.read<ProductRepository>())
                    ..loadProducts(),
        ),
      ],
      child: MaterialApp(
        title: 'Neurogine Product Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
        ),
        home: const ProductListPage(),
      ),
    );
  }
}

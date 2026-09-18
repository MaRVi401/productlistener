import 'package:dio/dio.dart';
import '../models/product.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://pos.cicd.web.id',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // GET: Fetch List Products
  static Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/items/products');
      final List data = response.data['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST: Create Product
  static Future<Product> createProduct(Product product) async {
    try {
      final response = await _dio.post(
        '/items/products',
        data: product.toJson(),
      );
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH: Update Product
  static Future<Product> updateProduct(String id, Product product) async {
    try {
      final response = await _dio.patch(
        '/items/products/$id',
        data: product.toJson(),
      );
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE: Delete Product
  static Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/items/products/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handling Status Error Code HTTP
  static String _handleError(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return '400: Permintaan tidak valid (Bad Request).';
      case 401:
        return '401: Sesi habis, silakan login kembali.';
      case 403:
        return '403: Anda tidak memiliki akses.';
      case 404:
        return '404: Data produk tidak ditemukan.';
      case 500:
        return '500: Terjadi kesalahan pada server.';
      default:
        return 'Terjadi masalah jaringan. Periksa koneksi internet Anda.';
    }
  }
}
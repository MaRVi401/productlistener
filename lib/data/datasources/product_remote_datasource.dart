import '../../../core/network/api_service.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final ApiService apiService;

  ProductRemoteDataSource({required this.apiService});

  Future<List<ProductModel>> getProducts() async {
    final dynamic responseData = await apiService.get('items/products');

    List<dynamic> jsonList = [];
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      jsonList = responseData['data'] ?? [];
    } else if (responseData is List) {
      jsonList = responseData;
    }

    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<bool> addProduct(ProductModel product) async {
    // Pastikan price benar-benar dikirim sebagai number (double/int)
    final body = {
      'name': product.name,
      'price': product.price.toDouble(), 
    };

    final response = await apiService.post('items/products', body);
    return response != null;
  }
}
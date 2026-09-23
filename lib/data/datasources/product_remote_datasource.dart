import '../../../core/network/api_service.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final ApiService apiService;

  ProductRemoteDataSource({required this.apiService});

  Future<List<ProductModel>> getProducts() async {
    try {
      final dynamic responseData = await apiService.get('products');

      // Penanganan fleksibel untuk format respon JSON (Array langsung atau Object dengan key 'data')
      List<dynamic> jsonList;
      if (responseData is List) {
        jsonList = responseData;
      } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        jsonList = responseData['data'];
      } else {
        jsonList = [];
      }

      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      // Fallback data dummy jika API sedang bermasalah atau offline
      return [
        ProductModel(id: '1', name: 'Laptop Gaming', price: 15000000),
        ProductModel(id: '2', name: 'Mouse Wireless', price: 250000),
        ProductModel(id: '3', name: 'Keyboard Mechanical', price: 750000),
      ];
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    try {
      await apiService.post('products', product.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
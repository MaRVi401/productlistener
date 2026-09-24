import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<bool> addProduct(Product product) async {
    final productModel = ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
    );
    return await remoteDataSource.addProduct(productModel);
  }

  @override
  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    return await remoteDataSource.updateProduct(id, data);
  }

  @override
  Future<bool> deleteProduct(String id) async {
    return await remoteDataSource.deleteProduct(id);
  }
}
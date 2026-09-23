import 'package:flutter_test/flutter_test.dart';
import 'package:belajarmobile2/main.dart';
import 'package:belajarmobile2/core/network/api_service.dart';
import 'package:belajarmobile2/data/datasources/product_remote_datasource.dart';
import 'package:belajarmobile2/data/repositories/product_repository_impl.dart';
import 'package:belajarmobile2/domain/usecases/get_products.dart';
import 'package:belajarmobile2/domain/usecases/add_product.dart';
import 'package:belajarmobile2/presentation/mobx/product_store.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 1. Inisialisasi ApiService
    final apiService = ApiService(baseUrl: "https://pos.cicd.web.id");

    // 2. Pass apiService ke ProductRemoteDataSource
    final remoteDataSource = ProductRemoteDataSource(apiService: apiService);
    final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);
    final getProductsUseCase = GetProducts(repository);
    final addProductUseCase = AddProduct(repository);

    final productStore = ProductStore(
      getProductsUseCase: getProductsUseCase,
      addProductUseCase: addProductUseCase,
    );

    await tester.pumpWidget(MyApp(productStore: productStore));
  });
}
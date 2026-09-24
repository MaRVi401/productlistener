import 'package:flutter/material.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/add_product.dart';
import 'domain/usecases/get_products.dart';
import 'presentation/mobx/product_store.dart';
import 'presentation/pages/add_product_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/product_list_page.dart';
import 'presentation/pages/tantangan_page.dart';
import 'core/network/api_service.dart';
import 'domain/usecases/update_product.dart';
import 'domain/usecases/delete_product.dart';
import 'package:belajarmobile2/domain/usecases/upload_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final remoteDataSource = ProductRemoteDataSource(apiService: apiService);
  final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);

  final getProductsUseCase = GetProducts(repository);
  final addProductUseCase = AddProduct(repository);
  final updateProductUseCase = UpdateProduct(repository);
  final deleteProductUseCase = DeleteProduct(repository);
  final uploadImageUseCase = UploadImage(repository);

  final productStore = ProductStore(
    getProductsUseCase: getProductsUseCase,
    addProductUseCase: addProductUseCase,
    updateProductUseCase: updateProductUseCase,
    deleteProductUseCase: deleteProductUseCase,
    uploadImageUseCase: uploadImageUseCase,
  );

  runApp(MyApp(productStore: productStore));
}

class MyApp extends StatelessWidget {
  final ProductStore productStore;

  const MyApp({super.key, required this.productStore});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Listener MobX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MainNavigation(productStore: productStore),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final ProductStore productStore;

  const MainNavigation({super.key, required this.productStore});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.productStore.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(productStore: widget.productStore),
      ProductListPage(productStore: widget.productStore),
      AddProductPage(productStore: widget.productStore),
      TantanganPage(productStore: widget.productStore),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: 'Tantangan',
          ),
        ],
      ),
    );
  }
}

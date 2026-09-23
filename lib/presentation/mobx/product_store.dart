import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/get_products.dart';

part 'product_store.g.dart';

// ignore: library_private_types_in_public_api
class ProductStore = _ProductStore with _$ProductStore;

abstract class _ProductStore with Store {
  final GetProducts getProductsUseCase;
  final AddProduct addProductUseCase;

  _ProductStore({
    required this.getProductsUseCase,
    required this.addProductUseCase,
  }) {
    // REACTION: Log otomatis ketika timbul errorMessage
    _disposers = [
      reaction((_) => errorMessage, (String? message) {
        if (message != null && message.isNotEmpty) {
          debugPrint("[REACTION LOG]: Exception/Error terjadi - $message");
        }
      })
    ];
  }

  late List<ReactionDisposer> _disposers;

  // 1. OBSERVABLE
  @observable
  ObservableList<Product> products = ObservableList<Product>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  // 2. COMPUTED
  @computed
  int get totalProducts => products.length;

  @computed
  double get totalPrice => products.fold(0, (sum, item) => sum + item.price);

  // 3. ACTION
  @action
  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    try {
      final result = await getProductsUseCase.execute();
      products.clear();
      products.addAll(result);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> addNewProduct(String name, double price) async {
    isLoading = true;
    errorMessage = null;
    try {
      final newProduct = Product(
        id: '', // ID dikosongkan karena dibuat otomatis oleh server
        name: name,
        price: price,
      );

      final success = await addProductUseCase.execute(newProduct);

      if (success) {
        // Fetch ulang data dari API untuk sinkronisasi resmi dengan server
        await fetchProducts();
        return true;
      } else {
        errorMessage = "Gagal menyimpan data ke API server";
        return false;
      }
    } catch (e) {
      errorMessage = "Error API: ${e.toString()}";
      return false;
    } finally {
      isLoading = false;
    }
  }

  void dispose() {
    for (var disposer in _disposers) {
      disposer();
    }
  }
}
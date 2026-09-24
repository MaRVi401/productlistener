import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';

part 'product_store.g.dart';

// ignore: library_private_types_in_public_api
class ProductStore = _ProductStore with _$ProductStore;

abstract class _ProductStore with Store {
  final GetProducts getProductsUseCase;
  final AddProduct addProductUseCase;
  final UpdateProduct updateProductUseCase;
  final DeleteProduct deleteProductUseCase;

  _ProductStore({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) {
    _disposers = [
      reaction((_) => errorMessage, (String? message) {
        if (message != null && message.isNotEmpty) {
          debugPrint("[REACTION LOG]: Exception/Error terjadi - $message");
        }
      })
    ];
  }

  late List<ReactionDisposer> _disposers;

  @observable
  ObservableList<Product> products = ObservableList<Product>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  int get totalProducts => products.length;

  @computed
  double get totalPrice => products.fold(0, (sum, item) => sum + item.price);

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
        id: '', 
        name: name,
        price: price,
      );

      final success = await addProductUseCase.execute(newProduct);
      if (success) {
        await fetchProducts(); 
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = "Error API (Add): ${e.toString()}";
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> editProduct(String id, String newName, double newPrice) async {
    isLoading = true;
    errorMessage = null;
    try {
      final success = await updateProductUseCase.execute(
        id, 
        {'name': newName, 'price': newPrice}
      );

      if (success) {
        await fetchProducts(); 
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = "Error API (Update): ${e.toString()}";
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> removeProduct(String id) async {
    // Optimistic Update: Hapus dari UI secara instan agar Dismissible tidak crash
    final targetProduct = products.firstWhere((p) => p.id == id);
    products.remove(targetProduct);

    isLoading = true;
    errorMessage = null;
    try {
      final success = await deleteProductUseCase.execute(id);

      if (success) {
        return true; // Tidak perlu fetch ulang karena data sudah hilang dari UI
      } else {
        // Jika server gagal menghapus, kembalikan data ke UI
        products.add(targetProduct);
        errorMessage = "Gagal menghapus produk di server";
        return false;
      }
    } catch (e) {
      // Jika error, kembalikan data ke UI
      products.add(targetProduct);
      errorMessage = "Error API (Delete): ${e.toString()}";
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
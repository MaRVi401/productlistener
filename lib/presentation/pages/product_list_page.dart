import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../mobx/product_store.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatelessWidget {
  final ProductStore productStore;

  const ProductListPage({super.key, required this.productStore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
      ),
      body: Column(
        children: [
          // COMPUTED DEMO
          Observer(
            builder: (_) => Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Produk: ${productStore.totalProducts}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Price: Rp ${productStore.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (productStore.isLoading && productStore.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productStore.errorMessage != null && productStore.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${productStore.errorMessage}'),
                        ElevatedButton(
                          onPressed: () => productStore.fetchProducts(),
                          child: const Text('Coba Lagi'),
                        )
                      ],
                    ),
                  );
                }

                if (productStore.products.isEmpty) {
                  return const Center(child: Text("Belum ada data produk."));
                }

                return ListView.builder(
                  itemCount: productStore.products.length,
                  itemBuilder: (context, index) {
                    final item = productStore.products[index];
                    return ProductCard(product: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => productStore.fetchProducts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
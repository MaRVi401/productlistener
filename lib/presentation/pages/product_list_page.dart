import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../domain/entities/product.dart';
import '../mobx/product_store.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatelessWidget {
  final ProductStore productStore;

  const ProductListPage({super.key, required this.productStore});

  void _showEditDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Harga Produk'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || double.tryParse(value) == null ? 'Harga tidak valid' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newName = nameController.text;
                  final newPrice = double.parse(priceController.text);
                  
                  final success = await productStore.editProduct(product.id, newName, newPrice);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'Produk berhasil diupdate!' : 'Gagal update produk')),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
      ),
      body: Column(
        children: [
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
                    
                    return Dismissible(
                      key: Key(item.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) => _confirmDelete(context),
                      // Perbaikan: tidak menggunakan async/await agar sinkron dan tidak error
                      onDismissed: (direction) {
                        productStore.removeProduct(item.id).then((success) {
                          if (context.mounted && !success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(productStore.errorMessage ?? 'Gagal menghapus produk'),
                              ),
                            );
                          }
                        });
                      },
                      child: InkWell(
                        onTap: () => _showEditDialog(context, item),
                        child: ProductCard(product: item),
                      ),
                    );
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
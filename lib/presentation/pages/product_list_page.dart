import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../domain/entities/product.dart';
import '../mobx/product_store.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatelessWidget {
  final ProductStore productStore;

  const ProductListPage({super.key, required this.productStore});

  // 1. DIALOG EDIT (Mengembalikan Map data jika disave, null jika batal)
  Future<Map<String, dynamic>?> _showEditDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toStringAsFixed(0));
    final descController = TextEditingController(text: product.description);
    final catController = TextEditingController(text: product.category);
    final stockController = TextEditingController(text: product.stock?.toString());
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Produk*'),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Harga*'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Harga tidak valid' : null,
                  ),
                  TextFormField(
                    controller: catController,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stok'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Kembalikan data yang sudah diisi ke pemanggil
                  Navigator.pop(dialogContext, {
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'category': catController.text,
                    'stock': int.tryParse(stockController.text),
                    'description': descController.text,
                  });
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // 2. DIALOG HAPUS (Mengembalikan true jika Hapus, false jika Batal)
  Future<bool?> _confirmDelete(BuildContext context, Product product) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Hapus "${product.name}" secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 3. BOTTOM SHEET DETAIL
  void _showProductDetail(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(150),
                          )
                        : _buildPlaceholder(150),
                  ),
                ),
                const SizedBox(height: 20),
                Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.w600),
                ),
                const Divider(height: 30),
                _buildDetailRow(Icons.category, 'Kategori', product.category ?? '-'),
                _buildDetailRow(Icons.inventory, 'Stok', product.stock?.toString() ?? 'Kosong'),
                _buildDetailRow(Icons.info, 'Status', product.status ?? 'Draft'),
                const SizedBox(height: 16),
                const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'Tidak ada deskripsi produk.',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () async {
                        // Tutup Bottom Sheet dulu
                        Navigator.pop(sheetContext); 
                        
                        // Munculkan konfirmasi hapus
                        final confirm = await _confirmDelete(context, product);
                        if (confirm == true) {
                          // Lakukan penghapusan jika dikonfirmasi
                          final success = await productStore.removeProduct(product.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(success ? 'Berhasil dihapus' : productStore.errorMessage ?? 'Gagal menghapus')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Tutup Bottom Sheet dulu
                        Navigator.pop(sheetContext);

                        // Munculkan dialog edit
                        final updatedData = await _showEditDialog(context, product);
                        if (updatedData != null) {
                          // Lakukan penyimpanan jika data diisi (tidak dibatalkan)
                          final success = await productStore.editProduct(product.id, updatedData);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(success ? 'Berhasil diupdate!' : 'Gagal update')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Produk'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // 4. MAIN BUILDER
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Produk')),
      body: Column(
        children: [
          Observer(
            builder: (_) => Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: ${productStore.totalProducts}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rp ${productStore.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (productStore.isLoading && productStore.products.isEmpty) return const Center(child: CircularProgressIndicator());
                if (productStore.errorMessage != null && productStore.products.isEmpty) return Center(child: Text('Error: ${productStore.errorMessage}'));
                if (productStore.products.isEmpty) return const Center(child: Text("Belum ada data produk."));

                return ListView.builder(
                  itemCount: productStore.products.length,
                  itemBuilder: (listContext, index) {
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
                      // Konfirmasi swipe otomatis terhubung ke _confirmDelete
                      confirmDismiss: (direction) => _confirmDelete(context, item),
                      onDismissed: (direction) {
                        productStore.removeProduct(item.id).then((success) {
                          if (context.mounted && !success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(productStore.errorMessage ?? 'Gagal menghapus produk')),
                            );
                          }
                        });
                      },
                      child: InkWell(
                        onTap: () => _showProductDetail(context, item),
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
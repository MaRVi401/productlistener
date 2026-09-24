import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../mobx/product_store.dart';
import 'product_list_page.dart'; // Import halaman Product List

class AddProductPage extends StatefulWidget {
  final ProductStore productStore;

  const AddProductPage({super.key, required this.productStore});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _catController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _catController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 1. Tutup keyboard
      FocusScope.of(context).unfocus();

      final name = _nameController.text;
      final price = double.parse(_priceController.text);
      final desc = _descController.text.isNotEmpty ? _descController.text : null;
      final cat = _catController.text.isNotEmpty ? _catController.text : null;
      final stock = _stockController.text.isNotEmpty ? int.parse(_stockController.text) : null;

      // 2. Jalankan API
      widget.productStore.addNewProduct(
        name, 
        price, 
        description: desc, 
        category: cat, 
        stock: stock
      ).then((success) {
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil ditambahkan!')),
            );
            
            // 3. REDIRECT: Ganti halaman saat ini dengan ProductListPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProductListPage(productStore: widget.productStore),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.productStore.errorMessage ?? 'Gagal menambah produk')),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk*'),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Harga Produk*'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || double.tryParse(v) == null ? 'Harga tidak valid' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _catController,
                  decoration: const InputDecoration(labelText: 'Kategori (Opsional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stok (Opsional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Observer(
                  builder: (_) {
                    return widget.productStore.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('Simpan Produk', style: TextStyle(fontSize: 16)),
                            ),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
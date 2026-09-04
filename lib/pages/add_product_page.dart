import 'package:flutter/material.dart';
import '../models/product.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  // Variabel untuk menyimpan kategori yang dipilih
  String? _selectedCategory;

  // Daftar opsi kategori sesuai permintaan
  final List<String> _categories = [
    'Sembako',
    'Cleaning Supplies',
    'Personal Care',
    'Laundry',
    'Kitchen Essentials',
    'Health Care',
  ];

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      double price = double.parse(_priceController.text);
      if (price <= 0) {
        throw Exception('Harga harus lebih dari 0!');
      }

      final newProduct = Product(
        name: _nameController.text,
        price: price,
        description: _descController.text,
        category: _selectedCategory!,
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTVTP6tvXxiu18qVLQ5Dh-2cuu6AuqMF04gNfRHkcCXyk2qNWx4uVAdiUk&s=10',
      );

      if (mounted) {
        Navigator.pop(context, newProduct);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menyimpan produk...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // 1. Nama Produk
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Produk'),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    // 2. Harga Produk
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Harga wajib diisi';
                        if (double.tryParse(value) == null) return 'Masukkan angka valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // 3. Dropdown Kategori
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      hint: const Text('Pilih Kategori'),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Pilih salah satu kategori' : null,
                    ),
                    const SizedBox(height: 12),

                    // 4. Deskripsi Produk
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Deskripsi wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),

                    // 5. Tombol Simpan
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan Produk'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import '../mobx/product_store.dart';
import 'product_list_page.dart';

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

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _catController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Fungsi membuka Galeri Foto dengan penanganan Error & Izin
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompresi ringan agar upload ke server lebih cepat
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("[ERROR PICK IMAGE]: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka galeri: ${e.toString()}')),
        );
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Tutup keyboard agar tidak mengganggu context
      FocusScope.of(context).unfocus();

      final name = _nameController.text;
      final price = double.parse(_priceController.text);
      final desc = _descController.text.isNotEmpty ? _descController.text : null;
      final cat = _catController.text.isNotEmpty ? _catController.text : null;
      final stock = _stockController.text.isNotEmpty ? int.parse(_stockController.text) : null;

      // Jalankan proses simpan data + upload gambar
      widget.productStore.addNewProduct(
        name,
        price,
        description: desc,
        category: cat,
        stock: stock,
        imageFile: _selectedImage,
      ).then((success) {
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk beserta gambar berhasil ditambahkan!')),
            );

            // Redirect ke halaman daftar produk
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
                // --- AREA TAP PILIH GAMBAR (MATERIAL & INKWELL) ---
                Material(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickImage, // Memanggil galeri
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Tap untuk tambah gambar',
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- INPUT TEKS ---
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

                // --- TOMBOL SIMPAN ---
                Observer(
                  builder: (_) {
                    return widget.productStore.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
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
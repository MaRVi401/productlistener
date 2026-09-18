import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class AddProductPage extends StatefulWidget {
  final Product? productToEdit;

  const AddProductPage({super.key, this.productToEdit});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;

  bool _isSubmitting = false;

  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _isEditing ? widget.productToEdit!.name : '',
    );
    _priceController = TextEditingController(
      text: _isEditing ? widget.productToEdit!.price.toString() : '',
    );
    _quantityController = TextEditingController(
      text: _isEditing ? widget.productToEdit!.quantity.toString() : '',
    );
    _imageUrlController = TextEditingController(
      text: _isEditing ? widget.productToEdit!.imageUrl ?? '' : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final quantity = int.parse(_quantityController.text.trim());
    final imageUrl = _imageUrlController.text.trim().isEmpty
        ? null
        : _imageUrlController.text.trim();

    final productData = Product(
      id: widget.productToEdit?.id,
      name: name,
      price: price,
      quantity: quantity,
      imageUrl: imageUrl,
    );

    try {
      Product savedProduct;
      if (_isEditing) {
        // Panggil HTTP PATCH
        savedProduct = await ApiService.updateProduct(
          widget.productToEdit!.id!,
          productData,
        );
      } else {
        // Panggil HTTP POST
        savedProduct = await ApiService.createProduct(productData);
      }

      if (mounted) {
        // Kirim hasil kembali ke Halaman Utama
        Navigator.pop(context, savedProduct);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Masukkan jumlah angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image ID / Asset UUID (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Misal: 7e82272d-9218-41ee-8733-9b6326854a39',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update Product' : 'Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // State Variables
  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load Data dari Local Storage
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loadedData = await StorageService.loadProducts();
      setState(() {
        _allProducts = loadedData;
        _filteredProducts = List.from(loadedData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data produk: $e';
        _isLoading = false;
      });
    }
  }

  // Fitur Pencarian
  void _searchProduct(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts = _allProducts
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Fitur Tambah Produk (Add)
  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _allProducts.add(result);
        _searchProduct(_searchController.text);
      });
      await StorageService.saveProducts(_allProducts);
    }
  }

  // Fitur Edit Produk
  Future<void> _navigateToEditProduct(int index, Product product) async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(productToEdit: product),
      ),
    );

    if (result != null) {
      setState(() {
        // Cari index aktual di list utama berdasarkan ID/referensi
        final mainIndex =
            _allProducts.indexWhere((p) => p.id == product.id || p == product);
        if (mainIndex != -1) {
          _allProducts[mainIndex] = result;
        }
        _searchProduct(_searchController.text);
      });
      await StorageService.saveProducts(_allProducts);
    }
  }

  // Fitur Hapus Produk (Delete)
  Future<void> _deleteProduct(Product product) async {
    setState(() {
      _allProducts.removeWhere((p) => p.id == product.id || p == product);
      _searchProduct(_searchController.text);
    });
    await StorageService.saveProducts(_allProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Inventory'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Input Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Product',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchProduct('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchProduct,
            ),
          ),
          // Handling State: Loading, Error, Empty, Success
          Expanded(
            child: _buildBodyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyState() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 2. Error State
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // 3. Empty State
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _allProducts.isEmpty
                  ? 'Belum ada produk. Klik tombol + untuk menambahkan.'
                  : 'Produk tidak ditemukan.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 4. Success State (Tampilan List Data)
    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return CardProduct(
          product: product,
          onEdit: () => _navigateToEditProduct(index, product),
          onTap: () => _deleteProduct(product),
        );
      },
    );
  }
}
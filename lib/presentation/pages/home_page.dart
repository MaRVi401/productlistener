import 'package:flutter/material.dart';
import '../mobx/product_store.dart';

class HomePage extends StatelessWidget {
  final ProductStore productStore;

  const HomePage({super.key, required this.productStore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Product Listener'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang di App Product Listener',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Diimplementasikan menggunakan Clean Architecture & MobX State Management',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Muat Data Produk'),
                onPressed: () => productStore.fetchProducts(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
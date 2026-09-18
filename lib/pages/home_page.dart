import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onNavigateToCatalog;

  const HomePage({super.key, required this.onNavigateToCatalog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Selamat Datang
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.store, size: 50, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Selamat Datang di Toko Online',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Temukan berbagai produk berkualitas dengan harga terbaik.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informasi Umum
            const Text(
              'Informasi Toko',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.local_shipping, color: Colors.blueAccent),
                    title: Text('Pengiriman Cepat'),
                    subtitle: Text('Dukungan pengiriman ke seluruh Indonesia'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.verified, color: Colors.blueAccent),
                    title: Text('Produk Original'),
                    subtitle: Text('Garansi 100% barang asli'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Buka Katalog (Berpindah Tab)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onNavigateToCatalog,
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Lihat Katalog Produk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
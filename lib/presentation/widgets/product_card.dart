import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        // --- BAGIAN MENAMPILKAN GAMBAR ---
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.imageUrl != null
              ? Image.network(
                  product.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Jika URL valid tapi gambar gagal dimuat dari server
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                )
              : Container(
                  // Jika produk memang tidak memiliki gambar
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
        ),
        // ---------------------------------
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Rp ${product.price.toStringAsFixed(0)}',
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
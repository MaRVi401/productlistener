import 'package:flutter/material.dart';
import '../models/product.dart';

class CardProduct extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap; // Digunakan untuk fungsi Delete
  final VoidCallback? onEdit; // Digunakan untuk fungsi Edit

  const CardProduct({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
  });

  // Modal Bottom Sheet untuk Preview Detail Produk
  void _showPreviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Gambar Produk dari Server / Assets API
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.fullImageUrl != null
                    ? Image.network(
                        product.fullImageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      )
                    : Container(
                        height: 150,
                        color: Colors.grey[200],
                        width: double.infinity,
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: Rp ${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Quantity: ${product.quantity}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (product.category != null && product.category!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Category: ${product.category}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
              if (product.description != null &&
                  product.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Description:\n${product.description}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showPreviewModal(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Gambar Kecil pada Card
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.fullImageUrl != null
                    ? Image.network(
                        product.fullImageUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : Container(
                        height: 100,
                        color: Colors.grey[200],
                        width: double.infinity,
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Price: Rp ${product.price.toStringAsFixed(0)}'),
              const SizedBox(height: 4),
              Text('Quantity: ${product.quantity}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _showPreviewModal(context),
                    child: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  if (onEdit != null)
                    ElevatedButton(
                      onPressed: onEdit,
                      child: const Text('Edit'),
                    ),
                  if (onEdit != null) const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
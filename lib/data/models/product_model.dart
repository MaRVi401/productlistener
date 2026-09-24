import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        parsedPrice = double.tryParse(json['price']) ?? 0.0;
      }
    }

    String? finalImageUrl;
    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      // Gabungkan Base URL BaaS Anda dengan endpoint /assets/ dan ID gambar
      finalImageUrl = 'https://pos.cicd.web.id/assets/${json['image_url']}';
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? 'Tanpa Nama',
      price: parsedPrice,
      imageUrl: finalImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
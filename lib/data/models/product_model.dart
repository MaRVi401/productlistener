import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handling fleksibel untuk konversi tipe data price dari JSON (num / string)
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        parsedPrice = double.tryParse(json['price']) ?? 0.0;
      }
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? 'Tanpa Nama',
      price: parsedPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
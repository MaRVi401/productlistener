class Product {
  final String? id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? category;
  final String? description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.category,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String?,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] != null
          ? int.tryParse(json['quantity'].toString()) ?? 0
          : 0,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price.toString(),
      'quantity': quantity,
      if (imageUrl != null) 'image_url': imageUrl,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
    };
  }

  // Getter pembantu untuk memformat URL lengkap gambar dari BaaS
  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    return 'https://pos.cicd.web.id/assets/$imageUrl';
  }
}
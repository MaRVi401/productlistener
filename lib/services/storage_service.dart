import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class StorageService {
  static const String _key = 'products_data';

  // Simpan list produk ke local storage
  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        products.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  // Ambil list produk dari local storage
  static Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_key);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    return jsonList
        .map((item) => Product.fromJson(jsonDecode(item)))
        .toList();
  }
}
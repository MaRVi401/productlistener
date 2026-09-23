import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({
    http.Client? client,
    this.baseUrl = "https://pos.cicd.web.id",
  }) : client = client ?? http.Client();

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat data (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengirim data (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }
}
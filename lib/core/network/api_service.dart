import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;
  final String baseUrl;
  String? _accessToken; // Menyimpan token login sementara

  ApiService({
    http.Client? client,
    this.baseUrl = "https://pos.cicd.web.id",
  }) : client = client ?? http.Client();

  // 1. Fungsi Login untuk mendapatkan Access Token otomatis
  Future<void> _ensureAuthenticated() async {
    if (_accessToken != null) return;

    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': 'praktikum@gmail.com',
        'password': '12345678'
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['data']['access_token'];
    } else {
      throw Exception('Gagal Autentikasi API: ${response.body}');
    }
  }

  // Helper untuk mendapatkan header beserta Token Authorization
  Future<Map<String, String>> _getHeaders() async {
    await _ensureAuthenticated();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
  }

  // --- HTTP METHODS ---

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('GET Error (${response.statusCode}): ${response.body}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('POST Error (${response.statusCode}): ${response.body}');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await client.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('PATCH Error (${response.statusCode}): ${response.body}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );

    // Directus biasa mengembalikan status 204 (No Content) untuk sukses hapus
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('DELETE Error (${response.statusCode}): ${response.body}');
    }
  }
}
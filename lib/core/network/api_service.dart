import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({
    http.Client? client,
    this.baseUrl = "https://pos.cicd.web.id",
  }) : client = client ?? http.Client();

  Future<dynamic> get(String endpoint) async {
    final response = await client.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('GET Error (${response.statusCode}): ${response.body}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await client.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(data),
    );

    debugPrint("[POST RESPONSE CODE]: ${response.statusCode}");
    debugPrint("[POST RESPONSE BODY]: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      // Melempar error lengkap dari server Directus
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
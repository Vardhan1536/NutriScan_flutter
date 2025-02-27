import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.223.154:8000';

  static Future<String> registerUser(String username, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return "User created successfully";
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['detail'] ?? 'Failed to register');
    }
  }
}

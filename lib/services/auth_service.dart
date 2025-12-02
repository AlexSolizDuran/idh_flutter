import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl =
      'https://idh-back.onrender.com'; // Reemplaza con la URL de tu backend

  Future<String?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      // Considera manejar los errores de forma más específica
      print('Error en el login: ${response.body}');
      return null;
    }
  }
}

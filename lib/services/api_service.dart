import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:restauran/services/unauthorized_exception.dart';

class ApiService {
  final String _baseUrl =
      'http://10.0.2.2:8000/api'; // Reemplaza con la URL de tu backend
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnauthorizedException('No autorizado: ${response.statusCode}');
    } else {
      // Considera un manejo de errores más robusto
      print('Error en la petición: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');
      throw Exception('Error en la petición: ${response.statusCode}');
    }
  }
}

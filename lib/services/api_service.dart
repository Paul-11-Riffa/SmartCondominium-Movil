import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.0.100:8000/api';

  // Método para obtener el token de autenticación
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Método genérico para hacer solicitudes GET autenticadas
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error GET: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción GET: $e');
      return null;
    }
  }

  // Método genérico para hacer solicitudes POST autenticadas
  static Future<Map<String, dynamic>?> post(String endpoint, Map<String, dynamic> data) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Error POST: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción POST: $e');
      return null;
    }
  }

  // Método genérico para hacer solicitudes PUT autenticadas
  static Future<Map<String, dynamic>?> put(String endpoint, Map<String, dynamic> data) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error PUT: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción PUT: $e');
      return null;
    }
  }

  // Método genérico para hacer solicitudes DELETE autenticadas
  static Future<bool> delete(String endpoint) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Excepción DELETE: $e');
      return false;
    }
  }
  
  // Método para subir imágenes u otros archivos
  static Future<Map<String, dynamic>?> uploadFile(String endpoint, String filePath, String fieldName) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/$endpoint'));
      request.headers['Authorization'] = 'Token $token';
      
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseString);
      } else {
        print('Error UPLOAD: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      print('Excepción UPLOAD: $e');
      return null;
    }
  }
}
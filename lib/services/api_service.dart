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
  static Future<dynamic> get(String endpoint) async {
    try {
      String? token = await _getToken();
      if (token == null) {
        print('DEBUG: No hay token de autenticación');
        return null;
      }

      print('DEBUG: Token obtenido: ${token.substring(0, 10)}...');
      
      // Construir URL correctamente - asegurar que no haya doble barra
      final String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final String fullUrl = '$_baseUrl$cleanEndpoint';
      
      print('DEBUG: Haciendo GET a: $fullUrl');
      
      final headers = <String, String>{
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };
      
      print('DEBUG: Headers enviados: $headers');
      
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: headers,
      );

      print('DEBUG: Status code: ${response.statusCode}');
      print('DEBUG: Response headers: ${response.headers}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        print('DEBUG: Error 401 - Token inválido o expirado');
        return null;
      } else if (response.statusCode == 403) {
        print('DEBUG: Error 403 - Sin permisos de administrador');
        return null;
      } else if (response.statusCode == 404) {
        print('DEBUG: Error 404 - Endpoint no encontrado: $fullUrl');
        return null;
      } else {
        print('DEBUG: Error ${response.statusCode} - ${response.body}');
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
      if (token == null) {
        print('DEBUG POST: No hay token de autenticación');
        return null;
      }

      // Construir URL correctamente - asegurar que no haya doble barra
      final String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final String fullUrl = '$_baseUrl$cleanEndpoint';
      
      print('DEBUG POST: Enviando a: $fullUrl');
      print('DEBUG POST: Datos: $data');
      print('DEBUG POST: Token: ${token.substring(0, 10)}...');
      
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('DEBUG POST: Status code: ${response.statusCode}');
      print('DEBUG POST: Response body: ${response.body}');

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

      // Construir URL correctamente
      final String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final String fullUrl = '$_baseUrl$cleanEndpoint';
      
      final response = await http.put(
        Uri.parse(fullUrl),
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

      // Construir URL correctamente
      final String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final String fullUrl = '$_baseUrl$cleanEndpoint';
      
      final response = await http.delete(
        Uri.parse(fullUrl),
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

      // Construir URL correctamente
      final String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final String fullUrl = '$_baseUrl$cleanEndpoint';
      
      var request = http.MultipartRequest('POST', Uri.parse(fullUrl));
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
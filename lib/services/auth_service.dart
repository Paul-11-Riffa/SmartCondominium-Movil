import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.0.100:8000/api';

  // Método para login
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar token y datos del usuario en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', data['token']);
        await prefs.setString('smartCondoUser', jsonEncode(data['user']));
        
        return {
          'success': true,
          'token': data['token'],
          'user': Usuario.fromJson(data['user'])
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Error de autenticación'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  // Método para registro
  static Future<Map<String, dynamic>?> register(
    String nombre,
    String apellido,
    String correo,
    String contrasena,
    String sexo,
    String telefono,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'contrasena': contrasena,
          'sexo': sexo,
          'telefono': telefono,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Guardar token y datos del usuario en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', data['token']);
        await prefs.setString('smartCondoUser', jsonEncode(data['user']));
        
        return {
          'success': true,
          'token': data['token'],
          'user': Usuario.fromJson(data['user'])
        };
      } else {
        final errorData = jsonDecode(response.body);
        String message = 'Error en el registro';
        
        if (errorData is Map) {
          if (errorData['detail'] != null) {
            message = errorData['detail'];
          } else if (errorData['correo'] != null) {
            message = errorData['correo'].join(', ');
          } else if (errorData['non_field_errors'] != null) {
            message = errorData['non_field_errors'].join(', ');
          }
        }
        
        return {
          'success': false,
          'message': message
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  // Método para logout
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('smartCondoUser');
  }

  // Método para obtener el token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Método para obtener el usuario actual
  static Future<Usuario?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('smartCondoUser');
    
    if (userJson != null) {
      Map<String, dynamic> userData = jsonDecode(userJson);
      return Usuario.fromJson(userData);
    }
    
    return null;
  }

  // Método para verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
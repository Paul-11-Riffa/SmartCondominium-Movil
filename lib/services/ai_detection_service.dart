import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reconocimiento_facial.dart';
import '../models/deteccion_placa.dart';
import '../models/perfil_facial.dart';
import '../models/reporte_seguridad.dart';

class AIDetectionService {
  static const String _baseUrl = 'http://192.168.0.100:8000/api';

  // Método para obtener el token de autenticación
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Método para reconocimiento facial
  static Future<Map<String, dynamic>?> recognizeFace(String imagePath, String cameraLocation) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/ai-detection/recognize_face/'));
      request.headers['Authorization'] = 'Token $token';
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.fields['camera_location'] = cameraLocation;
      
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseString);
      } else {
        print('Error reconocimiento facial: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      print('Excepción reconocimiento facial: $e');
      return null;
    }
  }

  // Método para registrar un perfil facial
  static Future<Map<String, dynamic>?> registerFace(int userId, String imagePath) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/ai-detection/register_profile/'));
      request.headers['Authorization'] = 'Token $token';
      
      request.fields['user_id'] = userId.toString();
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseString);
      } else {
        print('Error registro facial: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      print('Excepción registro facial: $e');
      return null;
    }
  }

  // Método para registrar un perfil facial del usuario actual
  static Future<Map<String, dynamic>?> registerCurrentUserFace(String imagePath) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/ai-detection/register_current_user/'));
      request.headers['Authorization'] = 'Token $token';
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseString);
      } else {
        print('Error registro facial usuario actual: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      print('Excepción registro facial usuario actual: $e');
      return null;
    }
  }

  // Método para listar perfiles faciales
  static Future<List<PerfilFacial>?> listFaceProfiles() async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/ai-detection/list_profiles/'),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['profiles'] != null) {
          List<dynamic> profilesJson = data['profiles'];
          return profilesJson.map((json) => PerfilFacial.fromJson(json)).toList();
        }
      }
      return null;
    } catch (e) {
      print('Excepción listar perfiles faciales: $e');
      return null;
    }
  }

  // Método para eliminar un perfil facial
  static Future<bool> deleteFaceProfile(int profileId) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/ai-detection/${profileId}/delete_profile/'),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Excepción eliminar perfil facial: $e');
      return false;
    }
  }

  // Método para detección de placas
  static Future<Map<String, dynamic>?> detectPlate(String imagePath, String cameraLocation, String accessType) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/ai-detection/detect_plate/'));
      request.headers['Authorization'] = 'Token $token';
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.fields['camera_location'] = cameraLocation;
      request.fields['access_type'] = accessType;
      
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseString);
      } else {
        print('Error detección placa: ${response.statusCode} - $responseString');
        return null;
      }
    } catch (e) {
      print('Excepción detección placa: $e');
      return null;
    }
  }

  // Método para obtener estadísticas de detección
  static Future<Map<String, dynamic>?> getDetectionStats() async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/ai-detection/detection_stats/'),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Excepción estadísticas detección: $e');
      return null;
    }
  }
}
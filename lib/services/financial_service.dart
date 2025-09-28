import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FinancialService {
  static const String _baseUrl = 'http://192.168.0.100:8000/api';

  // Método para obtener el token de autenticación
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Método para obtener el estado de cuenta
  static Future<Map<String, dynamic>?> getEstadoCuenta({String? mes}) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      String url = '$_baseUrl/estado-cuenta/';
      if (mes != null) {
        url += '?mes=$mes';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error estado de cuenta: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción estado de cuenta: $e');
      return null;
    }
  }

  // Método para descargar comprobante de pago en PDF
  static Future<Uint8List?> downloadComprobante(int facturaId) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/comprobante_pdf/$facturaId/'),
        headers: <String, String>{
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error descarga comprobante: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción descarga comprobante: $e');
      return null;
    }
  }

  // Método para obtener todas las facturas de un usuario
  static Future<List<dynamic>> getFacturas() async {
    try {
      String? token = await _getToken();
      if (token == null) return [];

      // final currentUser = await AuthService.getCurrentUser();
      // if (currentUser == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/facturas/'),
        headers: <String, String>{
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body; // Temporalmente devolver datos sin procesar
      } else {
        print('Error getFacturas: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Excepción getFacturas: $e');
      return [];
    }
  }
}
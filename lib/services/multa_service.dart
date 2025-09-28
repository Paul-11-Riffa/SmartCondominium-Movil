import 'dart:convert';
import 'package:movil/models/detalle_multa.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/services/auth_service.dart';

class MultaService {
  static Future<List<DetalleMulta>> getMisMultas() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      print('Obteniendo multas para usuario: ${currentUser.codigo}');
      
      // Intentar primero con detalle-multa
      var response = await ApiService.get('detalle-multa/');
      
      if (response == null) {
        // Si no funciona, intentar con multas
        print('Intentando endpoint multas...');
        response = await ApiService.get('multas/');
      }

      if (response != null) {
        print('Respuesta recibida: $response');
        
        if (response is List) {
          if (response.isEmpty) {
            print('No hay multas para este usuario');
            return [];
          }
          return (response as List).map<DetalleMulta>((data) => DetalleMulta.fromJson(data)).toList();
        } else if (response is Map<String, dynamic>) {
          if (response.containsKey('results')) {
            List<dynamic> data = response['results'];
            return data.map<DetalleMulta>((data) => DetalleMulta.fromJson(data)).toList();
          } else if (response.containsKey('data')) {
            List<dynamic> data = response['data'];
            return data.map<DetalleMulta>((data) => DetalleMulta.fromJson(data)).toList();
          } else {
            print('Estructura de respuesta: ${response.keys}');
            return [];
          }
        } else {
          print('Tipo de respuesta inesperado: ${response.runtimeType}');
          return [];
        }
      } else {
        print('Respuesta nula del servidor');
        return [];
      }
    } catch (e) {
      print('Error detallado en getMisMultas: $e');
      throw Exception('Error al cargar multas: $e');
    }
  }
}

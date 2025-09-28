import 'dart:convert';
import 'package:movil/models/solicitud_mantenimiento.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/services/auth_service.dart';

class MantenimientoService {
  static Future<List<SolicitudMantenimiento>> getMisSolicitudes() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await ApiService.get('solicitudes-mantenimiento/?codigo_usuario=${currentUser.codigo}');

      if (response != null) {
        if (response is List) {
          return response.map((data) => SolicitudMantenimiento.fromJson(data)).toList();
        } else if (response is Map<String, dynamic> && response.containsKey('results')) {
          List<dynamic> data = response['results'];
          return data.map((data) => SolicitudMantenimiento.fromJson(data)).toList();
        } else {
          throw Exception('Formato de respuesta inesperado para Solicitudes');
        }
      } else {
        throw Exception('Fallo al cargar las solicitudes');
      }
    } catch (e) {
      print('Error en getMisSolicitudes: $e');
      rethrow;
    }
  }

  static Future<SolicitudMantenimiento> addSolicitud(Map<String, dynamic> solicitudData) async {
     try {
      // This currently doesn't handle file uploads.
      // The backend would need to support creating the object and then uploading a photo separately,
      // or the ApiService needs a more complex multipart request method.
      final response = await ApiService.post('solicitudes-mantenimiento/', solicitudData);
      if (response != null) {
        return SolicitudMantenimiento.fromJson(response);
      } else {
        throw Exception('Fallo al agregar la solicitud');
      }
    } catch (e) {
      print('Error en addSolicitud: $e');
      rethrow;
    }
  }
}

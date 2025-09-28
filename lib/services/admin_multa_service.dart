import 'package:movil/models/multa.dart';
import 'package:movil/services/api_service.dart';

class AdminMultaService {
  // Obtener todas las multas (tipos de multa) como administrador
  static Future<List<Multa>> getAllMultas() async {
    try {
      print('Obteniendo todas las multas como administrador...');
      final response = await ApiService.get('multas/');

      if (response != null) {
        print('Respuesta recibida: $response');
        
        if (response is List) {
          return response.map((data) => Multa.fromJson(data)).toList();
        } else if (response is Map<String, dynamic>) {
          if (response.containsKey('results')) {
            List<dynamic> data = response['results'];
            return data.map((data) => Multa.fromJson(data)).toList();
          } else {
            throw Exception('Formato de respuesta inesperado para Multas');
          }
        } else {
          throw Exception('Formato de respuesta inesperado para Multas');
        }
      } else {
        throw Exception('No se pudieron cargar las multas - respuesta nula');
      }
    } catch (e) {
      print('Error en getAllMultas: $e');
      rethrow;
    }
  }

  // Crear una nueva multa (tipo de multa)
  static Future<Multa?> createMulta(Map<String, dynamic> multaData) async {
    try {
      print('Creando nueva multa: $multaData');
      final response = await ApiService.post('multas/', multaData);

      if (response != null) {
        print('Multa creada exitosamente: $response');
        return Multa.fromJson(response);
      } else {
        throw Exception('Error al crear la multa');
      }
    } catch (e) {
      print('Error en createMulta: $e');
      rethrow;
    }
  }

  // Actualizar una multa existente
  static Future<Multa?> updateMulta(int id, Map<String, dynamic> multaData) async {
    try {
      print('Actualizando multa $id: $multaData');
      final response = await ApiService.put('multas/$id/', multaData);

      if (response != null) {
        print('Multa actualizada exitosamente: $response');
        return Multa.fromJson(response);
      } else {
        throw Exception('Error al actualizar la multa');
      }
    } catch (e) {
      print('Error en updateMulta: $e');
      rethrow;
    }
  }

  // Eliminar una multa
  static Future<bool> deleteMulta(int id) async {
    try {
      print('Eliminando multa $id');
      final response = await ApiService.delete('multas/$id/');
      
      if (response == true) {
        print('Multa eliminada exitosamente');
        return true;
      } else {
        throw Exception('Error al eliminar la multa');
      }
    } catch (e) {
      print('Error en deleteMulta: $e');
      rethrow;
    }
  }
}
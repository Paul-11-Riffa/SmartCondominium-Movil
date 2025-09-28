import 'package:movil/models/propiedad.dart';
import 'package:movil/services/api_service.dart';

class AdminPropiedadService {
  // Obtener todas las propiedades como administrador
  static Future<List<Propiedad>> getAllPropiedades() async {
    try {
      print('Obteniendo todas las propiedades como administrador...');
      final response = await ApiService.get('propiedades/?include_residents=true');

      if (response != null) {
        print('Respuesta recibida: $response');
        
        if (response is List) {
          return response.map((data) => Propiedad.fromJson(data)).toList();
        } else if (response is Map<String, dynamic>) {
          if (response.containsKey('results')) {
            List<dynamic> data = response['results'];
            return data.map((data) => Propiedad.fromJson(data)).toList();
          } else {
            // Si no hay 'results', puede ser una respuesta directa
            throw Exception('Formato de respuesta inesperado para Propiedades');
          }
        } else {
          throw Exception('Formato de respuesta inesperado para Propiedades');
        }
      } else {
        throw Exception('No se pudieron cargar las propiedades - respuesta nula');
      }
    } catch (e) {
      print('Error en getAllPropiedades: $e');
      rethrow;
    }
  }

  // Crear una nueva propiedad
  static Future<Propiedad?> createPropiedad(Map<String, dynamic> propiedadData) async {
    try {
      print('Creando nueva propiedad: $propiedadData');
      final response = await ApiService.post('propiedades/', propiedadData);

      if (response != null) {
        print('Propiedad creada exitosamente: $response');
        return Propiedad.fromJson(response);
      } else {
        throw Exception('Error al crear la propiedad');
      }
    } catch (e) {
      print('Error en createPropiedad: $e');
      rethrow;
    }
  }

  // Actualizar una propiedad existente
  static Future<Propiedad?> updatePropiedad(int codigo, Map<String, dynamic> propiedadData) async {
    try {
      print('Actualizando propiedad $codigo: $propiedadData');
      final response = await ApiService.put('propiedades/$codigo/', propiedadData);

      if (response != null) {
        print('Propiedad actualizada exitosamente: $response');
        return Propiedad.fromJson(response);
      } else {
        throw Exception('Error al actualizar la propiedad');
      }
    } catch (e) {
      print('Error en updatePropiedad: $e');
      rethrow;
    }
  }

  // Eliminar una propiedad
  static Future<bool> deletePropiedad(int codigo) async {
    try {
      print('Eliminando propiedad $codigo');
      final response = await ApiService.delete('propiedades/$codigo/');
      
      if (response == true) {
        print('Propiedad eliminada exitosamente');
        return true;
      } else {
        throw Exception('Error al eliminar la propiedad');
      }
    } catch (e) {
      print('Error en deletePropiedad: $e');
      rethrow;
    }
  }
}
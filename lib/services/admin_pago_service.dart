import 'package:movil/models/pago.dart';
import 'package:movil/services/api_service.dart';

class AdminPagoService {
  // Obtener todos los pagos/servicios como administrador
  static Future<List<Pago>> getAllPagos() async {
    try {
      print('Obteniendo todos los pagos/servicios como administrador...');
      final response = await ApiService.get('pagos/');

      if (response != null) {
        print('Respuesta recibida: $response');
        
        if (response is List) {
          return response.map((data) => Pago.fromJson(data)).toList();
        } else if (response is Map<String, dynamic>) {
          if (response.containsKey('results')) {
            List<dynamic> data = response['results'];
            return data.map((data) => Pago.fromJson(data)).toList();
          } else {
            throw Exception('Formato de respuesta inesperado para Pagos');
          }
        } else {
          throw Exception('Formato de respuesta inesperado para Pagos');
        }
      } else {
        throw Exception('No se pudieron cargar los pagos/servicios - respuesta nula');
      }
    } catch (e) {
      print('Error en getAllPagos: $e');
      rethrow;
    }
  }

  // Crear un nuevo pago/servicio
  static Future<Pago?> createPago(Map<String, dynamic> pagoData) async {
    try {
      print('Creando nuevo pago/servicio: $pagoData');
      final response = await ApiService.post('pagos/', pagoData);

      if (response != null) {
        print('Pago/servicio creado exitosamente: $response');
        return Pago.fromJson(response);
      } else {
        throw Exception('Error al crear el pago/servicio');
      }
    } catch (e) {
      print('Error en createPago: $e');
      rethrow;
    }
  }

  // Actualizar un pago/servicio existente
  static Future<Pago?> updatePago(int id, Map<String, dynamic> pagoData) async {
    try {
      print('Actualizando pago/servicio $id: $pagoData');
      final response = await ApiService.put('pagos/$id/', pagoData);

      if (response != null) {
        print('Pago/servicio actualizado exitosamente: $response');
        return Pago.fromJson(response);
      } else {
        throw Exception('Error al actualizar el pago/servicio');
      }
    } catch (e) {
      print('Error en updatePago: $e');
      rethrow;
    }
  }

  // Eliminar un pago/servicio
  static Future<bool> deletePago(int id) async {
    try {
      print('Eliminando pago/servicio $id');
      final response = await ApiService.delete('pagos/$id/');
      
      if (response == true) {
        print('Pago/servicio eliminado exitosamente');
        return true;
      } else {
        throw Exception('Error al eliminar el pago/servicio');
      }
    } catch (e) {
      print('Error en deletePago: $e');
      rethrow;
    }
  }
}
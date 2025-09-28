import 'package:movil/models/vehiculo.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/services/auth_service.dart';

class VehiculoService {
  static Future<List<Vehiculo>> getVehiculos() async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await ApiService.get('vehiculos/?codigo_usuario=${currentUser.codigo}');
    print('🚗 [DEBUG] Respuesta completa getVehiculos: $response');
    print('🚗 [DEBUG] Tipo de respuesta: ${response.runtimeType}');
    
    if (response != null) {
      List<dynamic> data = (response is Map && response.containsKey('results')) 
          ? response['results'] 
          : response;
      print('🚗 [DEBUG] Datos de vehículos extraídos: $data');
      print('🚗 [DEBUG] Cantidad de vehículos: ${data.length}');
      
      final vehiculos = data.map((json) {
        print('🚗 [DEBUG] ===== Procesando vehículo =====');
        print('🚗 [DEBUG] JSON completo: $json');
        print('🚗 [DEBUG] Campo nroplaca: ${json['nroplaca']}');
        print('🚗 [DEBUG] Campo descripcion: ${json['descripcion']}');
        print('🚗 [DEBUG] Campo estado: ${json['estado']}');
        print('🚗 [DEBUG] Todos los campos: ${json.keys.toList()}');
        
        final vehiculo = Vehiculo.fromJson(json);
        print('🚗 [DEBUG] Vehículo creado - nroplaca: "${vehiculo.nroplaca}", descripcion: "${vehiculo.descripcion}", estado: "${vehiculo.estado}"');
        print('🚗 [DEBUG] ===== Fin procesamiento =====');
        return vehiculo;
      }).toList();
      
      print('🚗 [DEBUG] RESUMEN FINAL: ${vehiculos.length} vehículos procesados');
      for (int i = 0; i < vehiculos.length; i++) {
        final v = vehiculos[i];
        print('🚗 [DEBUG] Vehículo $i: nroplaca="${v.nroplaca}" descripcion="${v.descripcion}" estado="${v.estado}"');
      }
      
      return vehiculos;
    } else {
      throw Exception('Fallo al cargar los vehículos');
    }
  }

  static Future<Vehiculo> createVehiculo(Map<String, dynamic> vehiculoData) async {
    print('DEBUG: Enviando datos de vehículo: $vehiculoData');
    final response = await ApiService.post('vehiculos/', vehiculoData);
    print('DEBUG: Respuesta del servidor: $response');
    if (response != null) {
      final vehiculo = Vehiculo.fromJson(response);
      print('DEBUG: Vehículo creado: ${vehiculo.toJson()}');
      return vehiculo;
    } else {
      throw Exception('Fallo al crear el vehículo');
    }
  }

  static Future<Vehiculo> updateVehiculo(int id, Map<String, dynamic> vehiculoData) async {
    final response = await ApiService.put('vehiculos/$id/', vehiculoData);
    if (response != null) {
      return Vehiculo.fromJson(response);
    } else {
      throw Exception('Fallo al actualizar el vehículo');
    }
  }

  static Future<bool> deleteVehiculo(int id) async {
    try {
      await ApiService.delete('vehiculos/$id/');
      return true;
    } catch (e) {
      return false;
    }
  }
}
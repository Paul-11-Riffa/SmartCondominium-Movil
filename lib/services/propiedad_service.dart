import 'package:movil/models/propiedad.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/services/auth_service.dart';

class PropiedadService {
  static Future<int?> getMiPropiedadActiva() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener la propiedad activa del usuario usando el mismo endpoint que la web
      final response = await ApiService.get('pertenece/?codigo_usuario=${currentUser.codigo}&activas=true');

      if (response != null) {
        if (response is Map<String, dynamic> && response.containsKey('results')) {
          List<dynamic> data = response['results'];
          if (data.isNotEmpty) {
            return data[0]['codigo_propiedad'];
          }
        }
      }
      return null;
    } catch (e) {
      print('Error en getMiPropiedadActiva: $e');
      return null;
    }
  }

  static Future<List<Propiedad>> getMisPropiedades() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // This assumes the /api/propiedades endpoint can be filtered by user.
      // A more complex scenario might involve going through the 'Pertenece' table.
      // For now, we'll assume a direct or indirect filter is available.
      final response = await ApiService.get('propiedades/?codigo_usuario=${currentUser.codigo}');

      if (response != null) {
        if (response is List) {
          return response.map((data) => Propiedad.fromJson(data)).toList();
        } else if (response is Map<String, dynamic> && response.containsKey('results')) {
          List<dynamic> data = response['results'];
          return data.map((data) => Propiedad.fromJson(data)).toList();
        } else {
          throw Exception('Formato de respuesta inesperado para Propiedades');
        }
      } else {
        throw Exception('Fallo al cargar las propiedades');
      }
    } catch (e) {
      print('Error en getMisPropiedades: $e');
      rethrow;
    }
  }
}

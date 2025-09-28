import 'package:movil/models/detalle_multa.dart';
import 'package:movil/models/multa.dart';
import 'package:movil/models/propiedad.dart';
import 'package:movil/services/api_service.dart';

class AdminDetalleMultaService {
  static Future<List<DetalleMulta>> getAllDetallesMulta() async {
    try {
      print('DEBUG: Intentando obtener todas las multas aplicadas...');
      final response = await ApiService.get('/detalle-multa/');
      print('DEBUG: Respuesta de detalle-multa: $response');
      
      if (response is List) {
        return response.map<DetalleMulta>((data) => DetalleMulta.fromJson(data)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        // Manejar respuesta paginada de Django REST Framework
        print('DEBUG: Respuesta paginada de multas aplicadas detectada');
        final results = response['results'] as List;
        print('DEBUG: ${results.length} multas aplicadas en results');
        
        if (results.isNotEmpty) {
          final detallesMulta = results.map<DetalleMulta>((data) => DetalleMulta.fromJson(data)).toList();
          print('DEBUG: ${detallesMulta.length} multas aplicadas procesadas del servidor');
          return detallesMulta;
        } else {
          print('DEBUG: Lista results de multas aplicadas vacía');
          return [];
        }
      }
      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      print('DEBUG: Error al obtener detalles de multas: $e');
      throw Exception('Error al obtener detalles de multas: $e');
    }
  }

  static Future<List<Multa>> getTiposMulta() async {
    try {
      print('DEBUG: Intentando obtener tipos de multa...');
      final response = await ApiService.get('/multas/');
      print('DEBUG: Respuesta de multas: $response');
      print('DEBUG: Tipo de respuesta: ${response.runtimeType}');
      print('DEBUG: Es null: ${response == null}');
      
      if (response != null) {
        if (response is List) {
          print('DEBUG: Respuesta es lista con ${response.length} elementos');
          if (response.isNotEmpty) {
            print('DEBUG: Primer elemento: ${response.first}');
            final multas = response.map<Multa>((data) => Multa.fromJson(data)).toList();
            print('DEBUG: ${multas.length} tipos de multa obtenidos del servidor');
            return multas;
          } else {
            print('DEBUG: Lista vacía del servidor');
            return [];
          }
        } else if (response is Map<String, dynamic> && response.containsKey('results')) {
          // Manejar respuesta paginada de Django REST Framework
          print('DEBUG: Respuesta paginada detectada');
          final results = response['results'] as List;
          print('DEBUG: ${results.length} multas en results');
          
          if (results.isNotEmpty) {
            final multas = results.map<Multa>((data) => Multa.fromJson(data)).toList();
            print('DEBUG: ${multas.length} tipos de multa procesados del servidor');
            return multas;
          } else {
            print('DEBUG: Lista results vacía del servidor');
            return [];
          }
        } else {
          print('DEBUG: Respuesta no es lista ni paginada: $response');
        }
      }
      
      // Si llegamos aquí, hubo un problema
      print('DEBUG: FALLBACK - Usando datos de ejemplo para tipos de multa');
      return _getTiposMultaEjemplo();
    } catch (e) {
      print('DEBUG: Error al obtener tipos de multa: $e');
      print('DEBUG: Tipo de error: ${e.runtimeType}');
      print('DEBUG: FALLBACK - Usando datos de ejemplo por error');
      return _getTiposMultaEjemplo();
    }
  }

  static List<Multa> _getTiposMultaEjemplo() {
    return [
      Multa(
        id: 1,
        descripcion: 'Multa por mal estacionamiento',
        monto: 150.0,
        estado: 'activo',
      ),
      Multa(
        id: 2,
        descripcion: 'Multa por ruidos molestos',
        monto: 200.0,
        estado: 'activo',
      ),
      Multa(
        id: 3,
        descripcion: 'Multa por mascotas sin correa',
        monto: 100.0,
        estado: 'activo',
      ),
      Multa(
        id: 4,
        descripcion: 'Multa por basura fuera de horario',
        monto: 75.0,
        estado: 'activo',
      ),
      Multa(
        id: 5,
        descripcion: 'Multa por uso indebido de áreas comunes',
        monto: 250.0,
        estado: 'activo',
      ),
    ];
  }

  static Future<List<Propiedad>> getPropiedades() async {
    try {
      print('DEBUG: Intentando obtener propiedades...');
      final response = await ApiService.get('/propiedades/');
      print('DEBUG: Respuesta de propiedades: $response');
      
      if (response is List && response.isNotEmpty) {
        final propiedades = response.map<Propiedad>((data) => Propiedad.fromJson(data)).toList();
        print('DEBUG: ${propiedades.length} propiedades obtenidas del servidor');
        return propiedades;
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        // Manejar respuesta paginada de Django REST Framework
        print('DEBUG: Respuesta paginada de propiedades detectada');
        final results = response['results'] as List;
        print('DEBUG: ${results.length} propiedades en results');
        
        if (results.isNotEmpty) {
          final propiedades = results.map<Propiedad>((data) => Propiedad.fromJson(data)).toList();
          print('DEBUG: ${propiedades.length} propiedades procesadas del servidor');
          return propiedades;
        } else {
          print('DEBUG: Lista results de propiedades vacía del servidor');
          return [];
        }
      }
      
      // Si no hay respuesta del servidor, usar datos de ejemplo
      print('DEBUG: Usando datos de ejemplo para propiedades');
      return _getPropiedadesEjemplo();
    } catch (e) {
      print('DEBUG: Error al obtener propiedades: $e');
      print('DEBUG: Tipo de error: ${e.runtimeType}');
      print('DEBUG: Usando datos de ejemplo por error');
      return _getPropiedadesEjemplo();
    }
  }

  static List<Propiedad> _getPropiedadesEjemplo() {
    return [
      Propiedad(
        codigo: 101,
        nroCasa: 101,
        piso: 1,
        descripcion: 'Departamento moderno de 85 metros cuadrados',
        tamanoM2: 85.0,
      ),
      Propiedad(
        codigo: 102,
        nroCasa: 102,
        piso: 1,
        descripcion: 'Departamento familiar de 95 metros cuadrados',
        tamanoM2: 95.0,
      ),
      Propiedad(
        codigo: 103,
        nroCasa: 103,
        piso: 1,
        descripcion: 'Departamento grande 200 metros cuadrados con 4 habitaciones',
        tamanoM2: 200.0,
      ),
      Propiedad(
        codigo: 201,
        nroCasa: 201,
        piso: 2,
        descripcion: 'Departamento de lujo con vista panorámica',
        tamanoM2: 120.0,
      ),
      Propiedad(
        codigo: 202,
        nroCasa: 202,
        piso: 2,
        descripcion: 'Departamento ejecutivo de 90 metros cuadrados',
        tamanoM2: 90.0,
      ),
      Propiedad(
        codigo: 301,
        nroCasa: 301,
        piso: 3,
        descripcion: 'Penthouse de 150 metros cuadrados',
        tamanoM2: 150.0,
      ),
    ];
  }

  static Future<DetalleMulta> createDetalleMulta(Map<String, dynamic> detalleData) async {
    try {
      print('DEBUG: Enviando datos para crear multa: $detalleData');
      final response = await ApiService.post('/detalle-multa/', detalleData);
      print('DEBUG: Respuesta del servidor: $response');
      
      if (response != null) {
        return DetalleMulta.fromJson(response);
      } else {
        print('DEBUG: Respuesta nula o formato incorrecto, creando DetalleMulta básico');
        // Si el servidor no devuelve el objeto creado, crear uno básico
        return DetalleMulta(
          id: DateTime.now().millisecondsSinceEpoch, // ID temporal
          codigoPropiedad: detalleData['codigo_propiedad'],
          idMulta: detalleData['id_multa'],
          fechaEmi: detalleData['fecha_emi'],
          fechaLim: detalleData['fecha_lim'],
        );
      }
    } catch (e) {
      print('DEBUG: Error completo al aplicar multa: $e');
      throw Exception('Error al aplicar multa: $e');
    }
  }

  static Future<DetalleMulta> updateDetalleMulta(int id, Map<String, dynamic> detalleData) async {
    try {
      final response = await ApiService.put('/detalle-multa/$id/', detalleData);
      return DetalleMulta.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar multa aplicada: $e');
    }
  }

  static Future<void> deleteDetalleMulta(int id) async {
    try {
      await ApiService.delete('/detalle-multa/$id/');
    } catch (e) {
      throw Exception('Error al eliminar multa aplicada: $e');
    }
  }

  static Future<DetalleMulta> getDetalleMulta(int id) async {
    try {
      final response = await ApiService.get('/detalle-multa/$id/');
      return DetalleMulta.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener detalle de multa: $e');
    }
  }

  // Obtener multas aplicadas por propiedad
  static Future<List<DetalleMulta>> getDetallesMultaPorPropiedad(int codigoPropiedad) async {
    try {
      final response = await ApiService.get('/detalle-multa/?codigo_propiedad=$codigoPropiedad');
      
      if (response is List) {
        return response.map<DetalleMulta>((data) => DetalleMulta.fromJson(data)).toList();
      }
      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      throw Exception('Error al obtener multas de la propiedad: $e');
    }
  }

  // Obtener multas aplicadas por tipo de multa
  static Future<List<DetalleMulta>> getDetallesMultaPorTipo(int idMulta) async {
    try {
      final response = await ApiService.get('/detalle-multa/?id_multa=$idMulta');
      
      if (response is List) {
        return response.map<DetalleMulta>((data) => DetalleMulta.fromJson(data)).toList();
      }
      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      throw Exception('Error al obtener multas del tipo: $e');
    }
  }
}
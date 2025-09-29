import 'package:intl/intl.dart';
import 'package:movil/services/api_service.dart';

class ReportService {
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  /// Obtiene el reporte de uso de áreas comunes en formato JSON.
  static Future<Map<String, dynamic>?> getAreasComunesReport({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final fechaInicioStr = _formatter.format(fechaInicio);
      final fechaFinStr = _formatter.format(fechaFin);

      // Construimos la URL con los parámetros de consulta a mano.
      final endpoint =
          'reporte/areas-comunes/?fecha_inicio=$fechaInicioStr&fecha_fin=$fechaFinStr';

      print('DEBUG: Solicitando reporte de áreas comunes a: $endpoint');

      final response = await ApiService.get(endpoint);

      if (response != null) {
        print('DEBUG: Reporte de áreas comunes recibido.');
        return response;
      } else {
        print('DEBUG: Error al obtener el reporte de áreas comunes.');
        return null;
      }
    } catch (e) {
      print('Excepción en getAreasComunesReport: $e');
      return null;
    }
  }

  /// Obtiene el reporte de bitácora en formato JSON.
  static Future<Map<String, dynamic>?> getBitacoraReport({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final fechaInicioStr = _formatter.format(fechaInicio);
      final fechaFinStr = _formatter.format(fechaFin);

      // Construimos la URL con los parámetros de consulta.
      final endpoint =
          'reporte/bitacora/?fecha_inicio=$fechaInicioStr&fecha_fin=$fechaFinStr';
      
      print('DEBUG: Solicitando reporte de bitácora a: $endpoint');

      final response = await ApiService.get(endpoint);

      if (response != null) {
        print('DEBUG: Reporte de bitácora recibido.');
        return response;
      } else {
        print('DEBUG: Error al obtener el reporte de bitácora.');
        return null;
      }
    } catch (e) {
      print('Excepción en getBitacoraReport: $e');
      return null;
    }
  }
}

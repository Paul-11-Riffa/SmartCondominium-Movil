
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil/models/area_comun.dart';
import 'package:movil/models/horario.dart';
import 'package:movil/models/reserva.dart';
import 'package:movil/services/api_service.dart';

import 'package:movil/services/auth_service.dart';

class ReservaService {
  // --- Areas Comunes ---
  static Future<List<AreaComun>> getAreasComunes() async {
    final response = await ApiService.get('areas-comunes/');
    if (response != null) {
      if (response is List) {
        return response.map((data) => AreaComun.fromJson(data)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        List<dynamic> data = response['results'];
        return data.map((data) => AreaComun.fromJson(data)).toList();
      } else {
         throw Exception('Formato de respuesta inesperado para Areas Comunes');
      }
    } else {
      throw Exception('Fallo al cargar las areas comunes');
    }
  }

  // --- Horarios ---
  static Future<List<Horario>> getHorariosPorArea(int idArea) async {
    try {
      print('⏰ [DEBUG] ===== OBTENIENDO HORARIOS =====');
      print('⏰ [DEBUG] Solicitando horarios para área ID: $idArea');
      print('⏰ [DEBUG] URL construida: horarios/?id_area_c=$idArea');
      
      final response = await ApiService.get('horarios/?id_area_c=$idArea');
      
      print('⏰ [DEBUG] ===== RESPUESTA DEL SERVIDOR =====');
      print('⏰ [DEBUG] Respuesta completa: $response');
      print('⏰ [DEBUG] Tipo de respuesta: ${response.runtimeType}');
      print('⏰ [DEBUG] Es null: ${response == null}');
      
      if (response != null) {
        if (response is List) {
          print('⏰ [DEBUG] ✅ Respuesta es una lista directa con ${response.length} elementos');
          print('⏰ [DEBUG] Primer elemento (si existe): ${response.isNotEmpty ? response[0] : 'Lista vacía'}');
          
          final horarios = response.map((data) {
            print('⏰ [DEBUG] Procesando horario: $data');
            return Horario.fromJson(data);
          }).toList();
          
          print('⏰ [DEBUG] ✅ ${horarios.length} horarios procesados exitosamente');
          return horarios;
          
        } else if (response is Map<String, dynamic>) {
          print('⏰ [DEBUG] Respuesta es un Map, keys disponibles: ${response.keys.toList()}');
          
          if (response.containsKey('results')) {
            List<dynamic> data = response['results'];
            print('⏰ [DEBUG] ✅ Respuesta contiene results con ${data.length} horarios');
            print('⏰ [DEBUG] Primer elemento de results: ${data.isNotEmpty ? data[0] : 'Array vacío'}');
            
            final horarios = data.map((item) {
              print('⏰ [DEBUG] Procesando horario desde results: $item');
              return Horario.fromJson(item);
            }).toList();
            
            print('⏰ [DEBUG] ✅ ${horarios.length} horarios procesados desde results');
            return horarios;
          } else {
            print('⏰ [DEBUG] ❌ Map no contiene key "results"');
            print('⏰ [DEBUG] Intentando procesar como horario único...');
            return [Horario.fromJson(response)];
          }
        } else {
          print('⏰ [DEBUG] ❌ Formato de respuesta no reconocido: ${response.runtimeType}');
          throw Exception('Formato de respuesta inesperado para Horarios: ${response.runtimeType}');
        }
      } else {
        print('⏰ [DEBUG] ❌ Respuesta es null');
        throw Exception('Fallo al cargar los horarios - respuesta nula del servidor');
      }
    } catch (e, stackTrace) {
      print('⏰ [DEBUG] ❌ ERROR CAPTURADO en getHorariosPorArea:');
      print('⏰ [DEBUG] Error: $e');
      print('⏰ [DEBUG] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // --- Reservas ---
  static Future<Reserva> crearReserva(Map<String, dynamic> reservaData) async {
    try {
      print('🏊 [DEBUG] ===== CREANDO RESERVA =====');
      print('🏊 [DEBUG] Datos enviados: $reservaData');
      print('🏊 [DEBUG] Campos enviados verificados:');
      print('🏊 [DEBUG] - id_area_c: ${reservaData['id_area_c']}');
      print('🏊 [DEBUG] - fecha: ${reservaData['fecha']}');
      print('🏊 [DEBUG] - estado: ${reservaData['estado']}');
      print('🏊 [DEBUG] NOTA: codigo_usuario se asigna automáticamente en el backend');
      
      final response = await ApiService.post('reservas/', reservaData);
      
      print('🏊 [DEBUG] ===== RESPUESTA DEL SERVIDOR =====');
      print('🏊 [DEBUG] Respuesta completa: $response');
      print('🏊 [DEBUG] Tipo de respuesta: ${response.runtimeType}');
      
      if (response != null) {
        final reserva = Reserva.fromJson(response);
        print('🏊 [DEBUG] ✅ Reserva creada exitosamente con ID: ${reserva.id}');
        return reserva;
      } else {
        print('🏊 [DEBUG] ❌ Respuesta nula del servidor');
        throw Exception('Fallo al crear la reserva - respuesta nula');
      }
    } catch (e, stackTrace) {
      print('🏊 [DEBUG] ❌ ERROR en crearReserva:');
      print('🏊 [DEBUG] Error: $e');
      print('🏊 [DEBUG] Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<Reserva>> getMisReservas() async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await ApiService.get('reservas/?codigo_usuario=${currentUser.codigo}');
    if (response != null) {
      List<dynamic> data = (response is Map && response.containsKey('results')) ? response['results'] : response;
      return data.map((json) => Reserva.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar las reservas');
    }
  }

  static Future<void> deleteReserva(int reservaId) async {
    try {
      await ApiService.delete('reservas/$reservaId/');
    } catch (e) {
      print('Error al eliminar reserva: $e');
      rethrow;
    }
  }
}

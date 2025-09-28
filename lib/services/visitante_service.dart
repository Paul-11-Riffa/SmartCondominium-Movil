import 'dart:convert';
import 'package:movil/models/visitante.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/services/auth_service.dart';

class VisitanteService {
  static Future<List<Visitante>> getVisitantes() async {
    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await ApiService.get('lista-visitantes/?codigo_usuario=${currentUser.codigo}');

      if (response != null) {
        if (response is List) {
          return response.map((data) => Visitante.fromJson(data)).toList();
        } else if (response is Map<String, dynamic> && response.containsKey('results')) {
          List<dynamic> data = response['results'];
          return data.map((data) => Visitante.fromJson(data)).toList();
        } else {
          throw Exception('Formato de respuesta inesperado para Visitantes');
        }
      } else {
        throw Exception('Fallo al cargar los visitantes');
      }
    } catch (e) {
      print('Error en getVisitantes: $e');
      rethrow;
    }
  }

  static Future<Visitante> addVisitante(Map<String, dynamic> visitanteData) async {
    try {
      final response = await ApiService.post('lista-visitantes/', visitanteData);
      if (response != null) {
        return Visitante.fromJson(response);
      } else {
        throw Exception('Fallo al agregar el visitante');
      }
    } catch (e) {
      print('Error en addVisitante: $e');
      rethrow;
    }
  }
}

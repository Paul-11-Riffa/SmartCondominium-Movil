
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil/models/comunicado.dart';
import 'package:movil/services/api_service.dart';

class ComunicadoService {
  static Future<List<Comunicado>> getComunicados() async {
    final response = await ApiService.get('comunicados/');
    if (response != null) {
      // The API returns a list directly
      if (response is List) {
        return (response as List).map<Comunicado>((data) => Comunicado.fromJson(data)).toList();
      }
      // Handle cases where the list is nested under a key like 'results'
      else if (response is Map<String, dynamic> && response.containsKey('results')) {
         List<dynamic> data = response['results'];
         return data.map<Comunicado>((data) => Comunicado.fromJson(data)).toList();
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      throw Exception('Fallo al cargar los comunicados');
    }
  }

  static Future<bool> createComunicado({
    required String titulo,
    required String contenido,
  }) async {
    final data = {
      'titulo': titulo,
      'contenido': contenido,
      'tipo': 'General', // O el tipo que corresponda
      'estado': 'Activo',
    };

    final response = await ApiService.post('comunicados/', data);

    // La solicitud es exitosa si la respuesta no es nula
    return response != null;
  }
}

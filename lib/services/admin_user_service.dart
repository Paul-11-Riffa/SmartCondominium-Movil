import 'package:movil/services/api_service.dart';

class AdminUserService {
  /// Crear un nuevo usuario
  static Future<Map<String, dynamic>?> createUser({
    required String nombre,
    required String apellido,
    required String correo,
    required String password,
    required int tipoRol,
    String estado = 'activo',
  }) async {
    try {
      print('DEBUG: Creando usuario...');
      print('DEBUG: Datos: {nombre: $nombre, apellido: $apellido, correo: $correo, tipoRol: $tipoRol, estado: $estado}');
      
      final response = await ApiService.post('usuarios/', {
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'password': password,
        'tipo_rol': tipoRol,
        'estado': estado,
      });
      
      if (response != null) {
        print('DEBUG: Usuario creado exitosamente: $response');
        return response;
      } else {
        print('DEBUG: Error al crear usuario - respuesta nula');
        return null;
      }
    } catch (e) {
      print('DEBUG: Error al crear usuario: $e');
      return null;
    }
  }

  /// Actualizar un usuario existente
  static Future<Map<String, dynamic>?> updateUser({
    required int userId,
    required String nombre,
    required String apellido,
    required String correo,
    required int tipoRol,
    required String estado,
    String? password, // Opcional al actualizar
  }) async {
    try {
      print('DEBUG: Actualizando usuario ID: $userId');
      
      Map<String, dynamic> data = {
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'tipo_rol': tipoRol,
        'estado': estado,
      };
      
      // Solo incluir password si se proporcionó
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      
      print('DEBUG: Datos a actualizar: $data');
      
      final response = await ApiService.put('usuarios/$userId/', data);
      
      if (response != null) {
        print('DEBUG: Usuario actualizado exitosamente: $response');
        return response;
      } else {
        print('DEBUG: Error al actualizar usuario - respuesta nula');
        return null;
      }
    } catch (e) {
      print('DEBUG: Error al actualizar usuario: $e');
      return null;
    }
  }

  /// Eliminar un usuario
  static Future<bool> deleteUser(int userId) async {
    try {
      print('DEBUG: Eliminando usuario ID: $userId');
      
      final success = await ApiService.delete('usuarios/$userId/');
      
      if (success) {
        print('DEBUG: Usuario eliminado exitosamente');
        return true;
      } else {
        print('DEBUG: Error al eliminar usuario');
        return false;
      }
    } catch (e) {
      print('DEBUG: Error al eliminar usuario: $e');
      return false;
    }
  }

  /// Obtener roles disponibles
  static Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await ApiService.get('roles/');
      
      if (response != null) {
        // Verificar si la respuesta tiene 'results' (paginada) o es una lista directa
        List<dynamic> rolesList;
        if (response['results'] != null) {
          rolesList = response['results'];
        } else if (response is List) {
          rolesList = response;
        } else {
          rolesList = [];
        }
        
        final roles = List<Map<String, dynamic>>.from(rolesList);
        
        if (roles.isNotEmpty) {
          return roles;
        }
      }
      
      // Roles por defecto si no se pueden obtener del servidor
      return [
        {'id': 1, 'descripcion': 'Administrador', 'tipo': 'Administrador'},
        {'id': 2, 'descripcion': 'Residente', 'tipo': 'Residente'},
      ];
    } catch (e) {
      print('Error al obtener roles: $e');
      // Roles por defecto en caso de error
      return [
        {'id': 1, 'descripcion': 'Administrador', 'tipo': 'Administrador'},
        {'id': 2, 'descripcion': 'Residente', 'tipo': 'Residente'},
      ];
    }
  }
}
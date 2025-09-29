class Usuario {
  final int? codigo;
  final String nombre;
  final String apellido;
  final String correo;
  final String? sexo;
  final String? telefono;
  final String? estado;
  final int? idrol;
  final dynamic rol; // Puede ser null o un objeto rol

  // Getter para compatibilidad con el servicio
  int? get tipoRol => idrol;

  Usuario({
    this.codigo,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.sexo,
    this.telefono,
    this.estado,
    this.idrol,
    this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Función helper para convertir valores a String de manera segura
    String safeString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }
    
    // Función helper para convertir a int de manera segura
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return int.tryParse(value.toString());
    }
    
    try {
      final usuario = Usuario(
        codigo: safeInt(json['codigo']),
        nombre: safeString(json['nombre']),
        apellido: safeString(json['apellido']),
        correo: safeString(json['correo']),
        sexo: json['sexo']?.toString(),
        telefono: json['telefono']?.toString(),
        estado: safeString(json['estado'], 'activo'),
        idrol: safeInt(json['idrol'] ?? json['tipo_rol']),
        rol: json['rol'],
      );
      
      return usuario;
    } catch (e) {
      print('Error creando Usuario desde JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'sexo': sexo,
      'telefono': telefono,
      'estado': estado,
      'idrol': idrol,
      'rol': rol,
    };
  }
}
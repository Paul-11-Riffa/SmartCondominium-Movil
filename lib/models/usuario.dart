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
    return Usuario(
      codigo: json['codigo'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      sexo: json['sexo'],
      telefono: json['telefono']?.toString(),
      estado: json['estado'],
      idrol: json['idrol'],
      rol: json['rol'],
    );
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
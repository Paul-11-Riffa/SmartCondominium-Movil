class Rol {
  final int? id;
  final String? descripcion;
  final String? tipo;
  final String? estado;

  Rol({
    this.id,
    this.descripcion,
    this.tipo,
    this.estado,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'],
      descripcion: json['descripcion'],
      tipo: json['tipo'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'tipo': tipo,
      'estado': estado,
    };
  }
}
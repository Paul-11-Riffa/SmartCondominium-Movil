class SolicitudMantenimiento {
  final int? id;
  final int codigoUsuario;
  final int codigoPropiedad;
  final String titulo;
  final String descripcion;
  final String? fechaSolicitud;
  final String? estado;
  final String? fotoUrl;

  SolicitudMantenimiento({
    this.id,
    required this.codigoUsuario,
    required this.codigoPropiedad,
    required this.titulo,
    required this.descripcion,
    this.fechaSolicitud,
    this.estado,
    this.fotoUrl,
  });

  factory SolicitudMantenimiento.fromJson(Map<String, dynamic> json) {
    return SolicitudMantenimiento(
      id: json['id'],
      codigoUsuario: json['codigo_usuario'],
      codigoPropiedad: json['codigo_propiedad'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaSolicitud: json['fecha_solicitud'],
      estado: json['estado'],
      fotoUrl: json['foto_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_usuario': codigoUsuario,
      'codigo_propiedad': codigoPropiedad,
      'titulo': titulo,
      'descripcion': descripcion,
      'foto_url': fotoUrl,
    };
  }
}

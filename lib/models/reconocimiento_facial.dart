class ReconocimientoFacial {
  final int? id;
  final int? codigoUsuario;
  final String? nombreUsuario;
  final bool? esResidente;
  final String? ubicacionCamara;
  final double? confianza;
  final String? estado;
  final String? fechaDeteccion;
  final String? horaDeteccion;

  ReconocimientoFacial({
    this.id,
    this.codigoUsuario,
    this.nombreUsuario,
    this.esResidente,
    this.ubicacionCamara,
    this.confianza,
    this.estado,
    this.fechaDeteccion,
    this.horaDeteccion,
  });

  factory ReconocimientoFacial.fromJson(Map<String, dynamic> json) {
    return ReconocimientoFacial(
      id: json['id'],
      codigoUsuario: json['codigo_usuario'],
      nombreUsuario: json['nombre_usuario'],
      esResidente: json['es_residente'],
      ubicacionCamara: json['ubicacion_camara'],
      confianza: json['confianza']?.toDouble(),
      estado: json['estado'],
      fechaDeteccion: json['fecha_deteccion'],
      horaDeteccion: json['hora_deteccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_usuario': codigoUsuario,
      'nombre_usuario': nombreUsuario,
      'es_residente': esResidente,
      'ubicacion_camara': ubicacionCamara,
      'confianza': confianza,
      'estado': estado,
      'fecha_deteccion': fechaDeteccion,
      'hora_deteccion': horaDeteccion,
    };
  }
}
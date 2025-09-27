class DeteccionPlaca {
  final int? id;
  final String? placaDetectada;
  final int? vehiculoId;
  final bool? esAutorizado;
  final String? ubicacionCamara;
  final String? tipoAcceso;
  final double? confianza;
  final String? fechaDeteccion;
  final String? horaDeteccion;

  DeteccionPlaca({
    this.id,
    this.placaDetectada,
    this.vehiculoId,
    this.esAutorizado,
    this.ubicacionCamara,
    this.tipoAcceso,
    this.confianza,
    this.fechaDeteccion,
    this.horaDeteccion,
  });

  factory DeteccionPlaca.fromJson(Map<String, dynamic> json) {
    return DeteccionPlaca(
      id: json['id'],
      placaDetectada: json['placa_detectada'],
      vehiculoId: json['vehiculo'],
      esAutorizado: json['es_autorizado'],
      ubicacionCamara: json['ubicacion_camara'],
      tipoAcceso: json['tipo_acceso'],
      confianza: json['confianza']?.toDouble(),
      fechaDeteccion: json['fecha_deteccion'],
      horaDeteccion: json['hora_deteccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placa_detectada': placaDetectada,
      'vehiculo': vehiculoId,
      'es_autorizado': esAutorizado,
      'ubicacion_camara': ubicacionCamara,
      'tipo_acceso': tipoAcceso,
      'confianza': confianza,
      'fecha_deteccion': fechaDeteccion,
      'hora_deteccion': horaDeteccion,
    };
  }
}
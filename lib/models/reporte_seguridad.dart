class ReporteSeguridad {
  final int? id;
  final String? tipoEvento;
  final String? descripcion;
  final String? nivelAlerta;
  final bool? revisado;
  final int? revisor;
  final String? fechaEvento;
  final String? horaEvento;
  final int? reconocimientoFacialId;
  final int? deteccionPlacaId;

  ReporteSeguridad({
    this.id,
    this.tipoEvento,
    this.descripcion,
    this.nivelAlerta,
    this.revisado,
    this.revisor,
    this.fechaEvento,
    this.horaEvento,
    this.reconocimientoFacialId,
    this.deteccionPlacaId,
  });

  factory ReporteSeguridad.fromJson(Map<String, dynamic> json) {
    return ReporteSeguridad(
      id: json['id'],
      tipoEvento: json['tipo_evento'],
      descripcion: json['descripcion'],
      nivelAlerta: json['nivel_alerta'],
      revisado: json['revisado'],
      revisor: json['revisor'],
      fechaEvento: json['fecha_evento'],
      horaEvento: json['hora_evento'],
      reconocimientoFacialId: json['reconocimiento_facial'],
      deteccionPlacaId: json['deteccion_placa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo_evento': tipoEvento,
      'descripcion': descripcion,
      'nivel_alerta': nivelAlerta,
      'revisado': revisado,
      'revisor': revisor,
      'fecha_evento': fechaEvento,
      'hora_evento': horaEvento,
      'reconocimiento_facial': reconocimientoFacialId,
      'deteccion_placa': deteccionPlacaId,
    };
  }
}
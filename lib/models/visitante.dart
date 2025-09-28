class Visitante {
  final int? id;
  final String nombre;
  final String apellido;
  final String carnet;
  final String motivoVisita;
  final String fechaIni;
  final String fechaFin;
  final int? codigoPropiedad;

  Visitante({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.carnet,
    required this.motivoVisita,
    required this.fechaIni,
    required this.fechaFin,
    this.codigoPropiedad,
  });

  factory Visitante.fromJson(Map<String, dynamic> json) {
    return Visitante(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      carnet: json['carnet'],
      motivoVisita: json['motivo_visita'],
      fechaIni: json['fecha_ini'],
      fechaFin: json['fecha_fin'],
      codigoPropiedad: json['codigo_propiedad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'carnet': carnet,
      'motivo_visita': motivoVisita,
      'fecha_ini': fechaIni,
      'fecha_fin': fechaFin,
      'codigo_propiedad': codigoPropiedad,
    };
  }
}

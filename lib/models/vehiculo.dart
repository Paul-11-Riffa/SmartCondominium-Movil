class Vehiculo {
  final int? id;
  final String? nroplaca;
  final String? descripcion;
  final String? estado;

  Vehiculo({
    this.id,
    this.nroplaca,
    this.descripcion,
    this.estado,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      nroplaca: json['nro_placa'],  // Corregido: usar el nombre correcto del campo del backend
      descripcion: json['descripcion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nro_placa': nroplaca,  // Corregido: usar el nombre correcto del campo del backend
      'descripcion': descripcion,
      'estado': estado,
    };
  }
}
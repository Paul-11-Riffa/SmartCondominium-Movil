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
      nroplaca: json['nroplaca'],
      descripcion: json['descripcion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nroplaca': nroplaca,
      'descripcion': descripcion,
      'estado': estado,
    };
  }
}
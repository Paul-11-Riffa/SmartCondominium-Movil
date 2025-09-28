class Reserva {
  final int id;
  final int? codigoUsuario;
  final int? idAreaC;
  final String? fecha;
  final String? estado;

  Reserva({
    required this.id,
    this.codigoUsuario,
    this.idAreaC,
    this.fecha,
    this.estado,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      codigoUsuario: json['codigo_usuario'],
      idAreaC: json['id_area_c'],
      fecha: json['fecha'],
      estado: json['estado'],
    );
  }
}

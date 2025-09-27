class Factura {
  final int? id;
  final int? codigoUsuario;
  final int? idPago;
  final String? fecha;
  final String? hora;
  final String? estado;
  final String? tipoPago;
  final String? descripcionPago;

  Factura({
    this.id,
    this.codigoUsuario,
    this.idPago,
    this.fecha,
    this.hora,
    this.estado,
    this.tipoPago,
    this.descripcionPago,
  });

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json['id'],
      codigoUsuario: json['codigousuario'],
      idPago: json['idpago'],
      fecha: json['fecha'],
      hora: json['hora'],
      estado: json['estado'],
      tipoPago: json['tipopago'],
      descripcionPago: json['descripcion_pago'], // Esta información puede venir separada
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigousuario': codigoUsuario,
      'idpago': idPago,
      'fecha': fecha,
      'hora': hora,
      'estado': estado,
      'tipopago': tipoPago,
      'descripcion_pago': descripcionPago,
    };
  }
}
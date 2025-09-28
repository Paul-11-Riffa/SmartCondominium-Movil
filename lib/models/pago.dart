class Pago {
  final int? id;
  final String? tipo;
  final String? descripcion;
  final double? monto;
  final String? estado;

  Pago({
    this.id,
    this.tipo,
    this.descripcion,
    this.monto,
    this.estado,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      monto: json['monto']?.toDouble(),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'descripcion': descripcion,
      'monto': monto,
      'estado': estado,
    };
  }

  // Método auxiliar para mostrar el monto formateado
  String get montoDisplay => monto != null ? 'Bs. ${monto!.toStringAsFixed(2)}' : 'N/A';
  
  // Método auxiliar para obtener el tipo formateado
  String get tipoDisplay => tipo ?? 'N/A';
}
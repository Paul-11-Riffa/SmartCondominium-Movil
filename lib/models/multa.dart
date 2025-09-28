class Multa {
  final int? id;
  final String? descripcion;
  final double? monto;
  final String? estado;

  Multa({
    this.id,
    this.descripcion,
    this.monto,
    this.estado,
  });

  factory Multa.fromJson(Map<String, dynamic> json) {
    return Multa(
      id: json['id'],
      descripcion: json['descripcion'],
      monto: json['monto']?.toDouble(),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'monto': monto,
      'estado': estado,
    };
  }

  // Método auxiliar para mostrar el monto formateado
  String get montoDisplay => monto != null ? 'Bs. ${monto!.toStringAsFixed(2)}' : 'N/A';
}
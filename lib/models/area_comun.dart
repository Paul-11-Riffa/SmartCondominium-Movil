class AreaComun {
  final int id;
  final String? descripcion;
  final double? costo;
  final int? capacidadMax;
  final String? estado;

  AreaComun({
    required this.id,
    this.descripcion,
    this.costo,
    this.capacidadMax,
    this.estado,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) {
    return AreaComun(
      id: json['id'],
      descripcion: json['descripcion'],
      costo: json['costo'] != null ? double.tryParse(json['costo'].toString()) : null,
      capacidadMax: json['capacidad_max'],
      estado: json['estado'],
    );
  }
}

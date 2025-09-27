class Propiedad {
  final int? codigo;
  final String? nroCasa;
  final int? piso;
  final String? descripcion;
  final double? tamanoM2;
  final String? estado;
  final dynamic propietarioActual; // Información del residente actual

  Propiedad({
    this.codigo,
    this.nroCasa,
    this.piso,
    this.descripcion,
    this.tamanoM2,
    this.estado,
    this.propietarioActual,
  });

  factory Propiedad.fromJson(Map<String, dynamic> json) {
    return Propiedad(
      codigo: json['codigo'],
      nroCasa: json['nro_casa'],
      piso: json['piso'],
      descripcion: json['descripcion'],
      tamanoM2: json['tamano_m2']?.toDouble(),
      estado: json['estado'],
      propietarioActual: json['propietario_actual'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nro_casa': nroCasa,
      'piso': piso,
      'descripcion': descripcion,
      'tamano_m2': tamanoM2,
      'estado': estado,
      'propietario_actual': propietarioActual,
    };
  }
}
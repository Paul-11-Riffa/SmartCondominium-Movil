class Horario {
  final int id;
  final String? horaIni;
  final String? horaFin;
  final int? idAreaC;

  Horario({
    required this.id,
    this.horaIni,
    this.horaFin,
    this.idAreaC,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'],
      horaIni: json['hora_ini'],
      horaFin: json['hora_fin'],
      idAreaC: json['id_area_c'],
    );
  }
}

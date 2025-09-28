
class Comunicado {
  final int id;
  final String? tipo;
  final String? fecha;
  final String? hora;
  final String? titulo;
  final String? contenido;
  final String? url;
  final String? estado;
  final int? codigoUsuario;

  Comunicado({
    required this.id,
    this.tipo,
    this.fecha,
    this.hora,
    this.titulo,
    this.contenido,
    this.url,
    this.estado,
    this.codigoUsuario,
  });

  factory Comunicado.fromJson(Map<String, dynamic> json) {
    return Comunicado(
      id: json['id'],
      tipo: json['tipo'],
      fecha: json['fecha'],
      hora: json['hora'],
      titulo: json['titulo'],
      contenido: json['contenido'],
      url: json['url'],
      estado: json['estado'],
      codigoUsuario: json['codigo_usuario'],
    );
  }
}

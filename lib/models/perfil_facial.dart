class PerfilFacial {
  final int? id;
  final int? userId;
  final String? userName;
  final String? userEmail;
  final String? imageUrl;
  final String? fechaRegistro;
  final bool? activo;

  PerfilFacial({
    this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.imageUrl,
    this.fechaRegistro,
    this.activo,
  });

  factory PerfilFacial.fromJson(Map<String, dynamic> json) {
    return PerfilFacial(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      imageUrl: json['image_url'],
      fechaRegistro: json['fecha_registro'],
      activo: json['activo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'image_url': imageUrl,
      'fecha_registro': fechaRegistro,
      'activo': activo,
    };
  }
}
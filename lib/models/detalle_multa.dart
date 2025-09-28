import 'package:movil/models/multa.dart';
import 'package:movil/models/propiedad.dart';

class DetalleMulta {
  final int? id;
  final int? codigoPropiedad;
  final int? idMulta;
  final String? fechaEmi;
  final String? fechaLim;
  final Multa? multaInfo;
  final Propiedad? propiedadInfo;

  DetalleMulta({
    this.id,
    this.codigoPropiedad,
    this.idMulta,
    this.fechaEmi,
    this.fechaLim,
    this.multaInfo,
    this.propiedadInfo,
  });

  factory DetalleMulta.fromJson(Map<String, dynamic> json) {
    return DetalleMulta(
      id: json['id'],
      codigoPropiedad: json['codigo_propiedad'],
      idMulta: json['id_multa'],
      fechaEmi: json['fecha_emi'],
      fechaLim: json['fecha_lim'],
      multaInfo: json['multa_info'] != null ? Multa.fromJson(json['multa_info']) : null,
      propiedadInfo: json['propiedad_info'] != null ? Propiedad.fromJson(json['propiedad_info']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo_propiedad': codigoPropiedad,
      'id_multa': idMulta,
      'fecha_emi': fechaEmi,
      'fecha_lim': fechaLim,
    };
  }

  // Helpers para mostrar información formateada
  String get fechaEmisionDisplay {
    if (fechaEmi == null) return 'Sin fecha';
    try {
      final date = DateTime.parse(fechaEmi!);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return fechaEmi ?? 'Sin fecha';
    }
  }

  String get fechaLimiteDisplay {
    if (fechaLim == null) return 'Sin fecha límite';
    try {
      final date = DateTime.parse(fechaLim!);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return fechaLim ?? 'Sin fecha límite';
    }
  }

  String get propiedadDisplay {
    if (propiedadInfo != null) {
      return propiedadInfo!.nroCasaDisplay;
    }
    return 'Casa ${codigoPropiedad ?? 'N/A'}';
  }

  String get multaDisplay {
    return multaInfo?.descripcion ?? 'Multa #${idMulta ?? 'N/A'}';
  }

  String get montoDisplay {
    final monto = multaInfo?.monto ?? 0.0;
    return 'Bs. ${monto.toStringAsFixed(2)}';
  }

  bool get isVencida {
    if (fechaLim == null) return false;
    try {
      final limite = DateTime.parse(fechaLim!);
      return DateTime.now().isAfter(limite);
    } catch (e) {
      return false;
    }
  }
}

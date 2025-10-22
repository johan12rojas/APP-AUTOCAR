import 'package:flutter/material.dart';

class LicenciaConductor {
  final int? id;
  final String numeroLicencia;
  final String categoria; // A1, A2, B1, B2, C1, C2, etc.
  final String fechaExpedicion;
  final String fechaVencimiento;
  final String organismoExpedidor; // Ej: "Ministerio de Transporte"
  final String? restricciones;
  final String? notas;
  final String? rutaFotoLicencia; // Ruta de la foto de la licencia
  final DateTime fechaCreacion;

  LicenciaConductor({
    this.id,
    required this.numeroLicencia,
    required this.categoria,
    required this.fechaExpedicion,
    required this.fechaVencimiento,
    required this.organismoExpedidor,
    this.restricciones,
    this.notas,
    this.rutaFotoLicencia,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroLicencia': numeroLicencia,
      'categoria': categoria,
      'fechaExpedicion': fechaExpedicion,
      'fechaVencimiento': fechaVencimiento,
      'organismoExpedidor': organismoExpedidor,
      'restricciones': restricciones,
      'notas': notas,
      'rutaFotoLicencia': rutaFotoLicencia,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory LicenciaConductor.fromMap(Map<String, dynamic> map) {
    return LicenciaConductor(
      id: map['id'],
      numeroLicencia: map['numeroLicencia'],
      categoria: map['categoria'],
      fechaExpedicion: map['fechaExpedicion'],
      fechaVencimiento: map['fechaVencimiento'],
      organismoExpedidor: map['organismoExpedidor'],
      restricciones: map['restricciones'],
      notas: map['notas'],
      rutaFotoLicencia: map['rutaFotoLicencia'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }

  LicenciaConductor copyWith({
    int? id,
    String? numeroLicencia,
    String? categoria,
    String? fechaExpedicion,
    String? fechaVencimiento,
    String? organismoExpedidor,
    String? restricciones,
    String? notas,
    String? rutaFotoLicencia,
    DateTime? fechaCreacion,
  }) {
    return LicenciaConductor(
      id: id ?? this.id,
      numeroLicencia: numeroLicencia ?? this.numeroLicencia,
      categoria: categoria ?? this.categoria,
      fechaExpedicion: fechaExpedicion ?? this.fechaExpedicion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      organismoExpedidor: organismoExpedidor ?? this.organismoExpedidor,
      restricciones: restricciones ?? this.restricciones,
      notas: notas ?? this.notas,
      rutaFotoLicencia: rutaFotoLicencia ?? this.rutaFotoLicencia,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  // Verificar si la licencia está próxima a vencer (30 días)
  bool get proximoAVencer {
    final fechaVenc = DateTime.parse(fechaVencimiento);
    final diasRestantes = fechaVenc.difference(DateTime.now()).inDays;
    return diasRestantes <= 30 && diasRestantes > 0;
  }

  // Verificar si la licencia está vencida
  bool get vencida {
    final fechaVenc = DateTime.parse(fechaVencimiento);
    return fechaVenc.isBefore(DateTime.now());
  }

  // Obtener días restantes para vencimiento
  int get diasRestantes {
    final fechaVenc = DateTime.parse(fechaVencimiento);
    return fechaVenc.difference(DateTime.now()).inDays;
  }

  // Obtener el estado de la licencia
  String get estado {
    if (vencida) return 'Vencida';
    if (proximoAVencer) return 'Por vencer';
    return 'Vigente';
  }

  // Obtener el nombre de visualización de la categoría
  String get categoriaDisplayName {
    switch (categoria.toUpperCase()) {
      case 'A1':
        return 'A1 - Motocicletas hasta 125cc';
      case 'A2':
        return 'A2 - Motocicletas hasta 250cc';
      case 'B1':
        return 'B1 - Automóviles particulares';
      case 'B2':
        return 'B2 - Automóviles comerciales';
      case 'C1':
        return 'C1 - Vehículos de carga hasta 7.5 ton';
      case 'C2':
        return 'C2 - Vehículos de carga hasta 15 ton';
      case 'C3':
        return 'C3 - Vehículos de carga mayores a 15 ton';
      default:
        return 'Categoría $categoria';
    }
  }

  // Obtener el icono según la categoría
  IconData get icon {
    switch (categoria.toUpperCase()) {
      case 'A1':
      case 'A2':
        return Icons.motorcycle;
      case 'B1':
      case 'B2':
        return Icons.directions_car;
      case 'C1':
      case 'C2':
      case 'C3':
        return Icons.local_shipping;
      default:
        return Icons.card_membership;
    }
  }

  // Obtener el color según la categoría
  Color get color {
    switch (categoria.toUpperCase()) {
      case 'A1':
      case 'A2':
        return Colors.orange;
      case 'B1':
      case 'B2':
        return Colors.blue;
      case 'C1':
      case 'C2':
      case 'C3':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

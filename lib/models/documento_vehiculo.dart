class DocumentoVehiculo {
  final int? id;
  final int vehiculoId;
  final String tipo; // 'tecnomecanica', 'seguro' o 'propiedad'
  final String nombreArchivo;
  final String rutaArchivo;
  final String? rutaArchivoAdicional; // Para documentos de propiedad (frontal/trasera)
  final String fechaEmision;
  final String fechaVencimiento;
  final String? notas;
  final DateTime fechaCreacion;

  DocumentoVehiculo({
    this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.nombreArchivo,
    required this.rutaArchivo,
    this.rutaArchivoAdicional,
    required this.fechaEmision,
    required this.fechaVencimiento,
    this.notas,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehiculoId': vehiculoId,
      'tipo': tipo,
      'nombreArchivo': nombreArchivo,
      'rutaArchivo': rutaArchivo,
      'rutaArchivoAdicional': rutaArchivoAdicional,
      'fechaEmision': fechaEmision,
      'fechaVencimiento': fechaVencimiento,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory DocumentoVehiculo.fromMap(Map<String, dynamic> map) {
    return DocumentoVehiculo(
      id: map['id'],
      vehiculoId: map['vehiculoId'],
      tipo: map['tipo'],
      nombreArchivo: map['nombreArchivo'],
      rutaArchivo: map['rutaArchivo'],
      rutaArchivoAdicional: map['rutaArchivoAdicional'],
      fechaEmision: map['fechaEmision'],
      fechaVencimiento: map['fechaVencimiento'],
      notas: map['notas'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }

  DocumentoVehiculo copyWith({
    int? id,
    int? vehiculoId,
    String? tipo,
    String? nombreArchivo,
    String? rutaArchivo,
    String? rutaArchivoAdicional,
    String? fechaEmision,
    String? fechaVencimiento,
    String? notas,
    DateTime? fechaCreacion,
  }) {
    return DocumentoVehiculo(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      tipo: tipo ?? this.tipo,
      nombreArchivo: nombreArchivo ?? this.nombreArchivo,
      rutaArchivo: rutaArchivo ?? this.rutaArchivo,
      rutaArchivoAdicional: rutaArchivoAdicional ?? this.rutaArchivoAdicional,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  // Verificar si el documento está próximo a vencer (30 días)
  bool get proximoAVencer {
    final fechaVenc = DateTime.parse(fechaVencimiento);
    final diasRestantes = fechaVenc.difference(DateTime.now()).inDays;
    return diasRestantes <= 30 && diasRestantes > 0;
  }

  // Verificar si el documento está vencido
  bool get vencido {
    final fechaVenc = DateTime.parse(fechaVencimiento);
    return fechaVenc.isBefore(DateTime.now());
  }

  // Obtener días restantes para vencimiento
  int get diasRestantes {
    final fechaVenc = DateTime.parse(fechaVencimiento);
    return fechaVenc.difference(DateTime.now()).inDays;
  }

  // Obtener el estado del documento
  String get estado {
    if (vencido) return 'Vencido';
    if (proximoAVencer) return 'Por vencer';
    return 'Al día';
  }

  // Obtener el nombre de visualización del tipo
  String get tipoDisplayName {
    switch (tipo) {
      case 'tecnomecanica':
        return 'Tecnomecánica';
      case 'seguro':
        return 'Seguro';
      case 'propiedad':
        return 'Propiedad';
      default:
        return tipo;
    }
  }

  // Obtener el icono según el tipo
  String get icono {
    switch (tipo) {
      case 'tecnomecanica':
        return '🔧';
      case 'seguro':
        return '🛡️';
      case 'propiedad':
        return '📋';
      default:
        return '📄';
    }
  }
}

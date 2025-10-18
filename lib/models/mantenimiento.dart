class Mantenimiento {
  final int? id;
  final int vehiculoId;
  final String tipo; // 'oil', 'tires', 'brakes', etc.
  final DateTime fecha;
  final int kilometraje;
  final String notas;
  final double costo;
  final String ubicacion;
  final String status; // 'pending', 'urgent', 'completed'

  Mantenimiento({
    this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.fecha,
    required this.kilometraje,
    required this.notas,
    required this.costo,
    required this.ubicacion,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehiculoId': vehiculoId,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'kilometraje': kilometraje,
      'notas': notas,
      'costo': costo,
      'ubicacion': ubicacion,
      'status': status,
    };
  }

  factory Mantenimiento.fromMap(Map<String, dynamic> map) {
    return Mantenimiento(
      id: map['id'],
      vehiculoId: map['vehiculoId'],
      tipo: map['tipo'],
      fecha: DateTime.parse(map['fecha']),
      kilometraje: map['kilometraje'],
      notas: map['notas'],
      costo: map['costo']?.toDouble() ?? 0.0,
      ubicacion: map['ubicacion'],
      status: map['status'],
    );
  }

  Mantenimiento copyWith({
    int? id,
    int? vehiculoId,
    String? tipo,
    DateTime? fecha,
    int? kilometraje,
    String? notas,
    double? costo,
    String? ubicacion,
    String? status,
  }) {
    return Mantenimiento(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      kilometraje: kilometraje ?? this.kilometraje,
      notas: notas ?? this.notas,
      costo: costo ?? this.costo,
      ubicacion: ubicacion ?? this.ubicacion,
      status: status ?? this.status,
    );
  }

  // Método para crear mantenimiento programado
  static Mantenimiento schedule({
    required int vehiculoId,
    required String tipo,
    required DateTime fechaProgramada,
    required int kilometrajeProgramado,
    String notas = '',
    double costoEstimado = 0.0,
    String ubicacion = '',
  }) {
    return Mantenimiento(
      vehiculoId: vehiculoId,
      tipo: tipo,
      fecha: fechaProgramada,
      kilometraje: kilometrajeProgramado,
      notas: notas,
      costo: costoEstimado,
      ubicacion: ubicacion,
      status: 'pending',
    );
  }

  // Método para completar mantenimiento
  Mantenimiento complete({
    required int kilometrajeReal,
    required DateTime fechaReal,
    double? costoReal,
    String? notasReales,
    String? ubicacionReal,
  }) {
    return copyWith(
      fecha: fechaReal,
      kilometraje: kilometrajeReal,
      costo: costoReal ?? costo,
      notas: notasReales ?? notas,
      ubicacion: ubicacionReal ?? ubicacion,
      status: 'completed',
    );
  }

  // Verificar si está vencido
  bool get isOverdue {
    final now = DateTime.now();
    return (now.isAfter(fecha) || now.isAtSameMomentAs(fecha)) && status != 'completed';
  }

  // Verificar si es urgente
  bool get isUrgent {
    return status == 'urgent' || isOverdue;
  }

  // Obtener días hasta vencimiento
  int get daysUntilDue {
    final now = DateTime.now();
    return fecha.difference(now).inDays;
  }

  // Obtener nombre legible del tipo
  String get tipoDisplayName {
    const typeNames = {
      'oil': 'Aceite de Motor',
      'tires': 'Llantas',
      'brakes': 'Frenos',
      'battery': 'Batería',
      'coolant': 'Refrigerante',
      'airFilter': 'Filtro de Aire',
      'alignment': 'Alineación y Balanceo',
      'chain': 'Cadena/Kit de Arrastre',
      'sparkPlug': 'Bujía',
    };
    return typeNames[tipo] ?? tipo;
  }

  // Obtener color del estado
  String get statusColor {
    switch (status) {
      case 'completed':
        return 'green';
      case 'urgent':
        return 'red';
      case 'pending':
        return 'orange';
      default:
        return 'gray';
    }
  }
}
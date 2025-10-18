class Mantenimiento {
  final int? id;
  final int vehiculoId;
  final DateTime fecha;
  final String tipo;
  final String descripcion;
  final double costo;
  final int kilometraje;
  final String taller;
  final String? notas;

  Mantenimiento({
    this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.costo,
    required this.kilometraje,
    required this.taller,
    this.notas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehiculo_id': vehiculoId,
      'fecha': fecha.millisecondsSinceEpoch,
      'tipo': tipo,
      'descripcion': descripcion,
      'costo': costo,
      'kilometraje': kilometraje,
      'taller': taller,
      'notas': notas,
    };
  }

  factory Mantenimiento.fromMap(Map<String, dynamic> map) {
    return Mantenimiento(
      id: map['id'],
      vehiculoId: map['vehiculo_id'],
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha']),
      tipo: map['tipo'],
      descripcion: map['descripcion'],
      costo: map['costo'],
      kilometraje: map['kilometraje'],
      taller: map['taller'],
      notas: map['notas'],
    );
  }

  Mantenimiento copyWith({
    int? id,
    int? vehiculoId,
    DateTime? fecha,
    String? tipo,
    String? descripcion,
    double? costo,
    int? kilometraje,
    String? taller,
    String? notas,
  }) {
    return Mantenimiento(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      costo: costo ?? this.costo,
      kilometraje: kilometraje ?? this.kilometraje,
      taller: taller ?? this.taller,
      notas: notas ?? this.notas,
    );
  }
}


class Vehiculo {
  final int? id;
  final String marca;
  final String modelo;
  final String ano;
  final String placa;
  final String color;
  final int kilometraje;
  final String tipo; // 'auto' o 'moto'
  final int estadoAceite; // Porcentaje de estado del aceite (0-100)
  final int estadoLlantas; // Porcentaje de estado de las llantas (0-100)
  final int estadoFrenos; // Porcentaje de estado de los frenos (0-100)
  final int estadoBateria; // Porcentaje de estado de la batería (0-100)
  final String proximoMantenimiento; // Descripción del próximo mantenimiento
  final int kmProximoMantenimiento; // Kilometraje para próximo mantenimiento

  Vehiculo({
    this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.color,
    required this.kilometraje,
    this.tipo = 'auto',
    this.estadoAceite = 100,
    this.estadoLlantas = 100,
    this.estadoFrenos = 100,
    this.estadoBateria = 100,
    this.proximoMantenimiento = 'Sin mantenimientos programados',
    this.kmProximoMantenimiento = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'placa': placa,
      'color': color,
      'kilometraje': kilometraje,
      'tipo': tipo,
      'estadoAceite': estadoAceite,
      'estadoLlantas': estadoLlantas,
      'estadoFrenos': estadoFrenos,
      'estadoBateria': estadoBateria,
      'proximoMantenimiento': proximoMantenimiento,
      'kmProximoMantenimiento': kmProximoMantenimiento,
    };
  }

  factory Vehiculo.fromMap(Map<String, dynamic> map) {
    return Vehiculo(
      id: map['id'],
      marca: map['marca'],
      modelo: map['modelo'],
      ano: map['ano'],
      placa: map['placa'],
      color: map['color'],
      kilometraje: map['kilometraje'],
      tipo: map['tipo'] ?? 'auto',
      estadoAceite: map['estadoAceite'] ?? 100,
      estadoLlantas: map['estadoLlantas'] ?? 100,
      estadoFrenos: map['estadoFrenos'] ?? 100,
      estadoBateria: map['estadoBateria'] ?? 100,
      proximoMantenimiento: map['proximoMantenimiento'] ?? 'Sin mantenimientos programados',
      kmProximoMantenimiento: map['kmProximoMantenimiento'] ?? 0,
    );
  }

  Vehiculo copyWith({
    int? id,
    String? marca,
    String? modelo,
    String? ano,
    String? placa,
    String? color,
    int? kilometraje,
    String? tipo,
    int? estadoAceite,
    int? estadoLlantas,
    int? estadoFrenos,
    int? estadoBateria,
    String? proximoMantenimiento,
    int? kmProximoMantenimiento,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      placa: placa ?? this.placa,
      color: color ?? this.color,
      kilometraje: kilometraje ?? this.kilometraje,
      tipo: tipo ?? this.tipo,
      estadoAceite: estadoAceite ?? this.estadoAceite,
      estadoLlantas: estadoLlantas ?? this.estadoLlantas,
      estadoFrenos: estadoFrenos ?? this.estadoFrenos,
      estadoBateria: estadoBateria ?? this.estadoBateria,
      proximoMantenimiento: proximoMantenimiento ?? this.proximoMantenimiento,
      kmProximoMantenimiento: kmProximoMantenimiento ?? this.kmProximoMantenimiento,
    );
  }
}

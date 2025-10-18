class Vehiculo {
  final int? id;
  final String marca;
  final String modelo;
  final String ano;
  final String placa;
  final String color;
  final int kilometraje;

  Vehiculo({
    this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.color,
    required this.kilometraje,
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
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      placa: placa ?? this.placa,
      color: color ?? this.color,
      kilometraje: kilometraje ?? this.kilometraje,
    );
  }
}

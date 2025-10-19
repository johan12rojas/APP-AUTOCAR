import '../services/maintenance_service.dart';

class MaintenanceData {
  final double percentage;      // Porcentaje de vida útil restante (0-100%)
  final String lastChanged;     // Fecha del último cambio/mantenimiento
  final int dueKm;             // Kilometraje en el que vence

  MaintenanceData({
    required this.percentage,
    required this.lastChanged,
    required this.dueKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'percentage': percentage,
      'lastChanged': lastChanged,
      'dueKm': dueKm,
    };
  }

  factory MaintenanceData.fromMap(Map<String, dynamic> map) {
    return MaintenanceData(
      percentage: map['percentage']?.toDouble() ?? 100.0,
      lastChanged: map['lastChanged'] ?? DateTime.now().toIso8601String(),
      dueKm: map['dueKm'] ?? 0,
    );
  }

  MaintenanceData copyWith({
    double? percentage,
    String? lastChanged,
    int? dueKm,
  }) {
    return MaintenanceData(
      percentage: percentage ?? this.percentage,
      lastChanged: lastChanged ?? this.lastChanged,
      dueKm: dueKm ?? this.dueKm,
    );
  }
}

class Vehiculo {
  final int? id;
  final String marca;
  final String modelo;
  final int ano;
  final String placa;
  final String tipo; // 'carro' o 'moto'
  final int kilometraje;
  final String? imagenPersonalizada; // Ruta de imagen personalizada del vehículo
  final Map<String, MaintenanceData> maintenance; // Estado de cada categoría
  final DateTime createdAt;

  Vehiculo({
    this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.tipo,
    required this.kilometraje,
    this.imagenPersonalizada,
    required this.maintenance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'placa': placa,
      'tipo': tipo,
      'kilometraje': kilometraje,
      'imagenPersonalizada': imagenPersonalizada,
      'maintenance': maintenance.map((key, value) => MapEntry(key, value.toMap())),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Vehiculo.fromMap(Map<String, dynamic> map) {
    final maintenanceMap = map['maintenance'] as Map<String, dynamic>? ?? {};
    final maintenance = maintenanceMap.map((key, value) => 
      MapEntry(key, MaintenanceData.fromMap(value as Map<String, dynamic>)));

    return Vehiculo(
      id: map['id'],
      marca: map['marca'],
      modelo: map['modelo'],
      ano: map['ano'],
      placa: map['placa'],
      tipo: map['tipo'],
      kilometraje: map['kilometraje'],
      imagenPersonalizada: map['imagenPersonalizada'],
      maintenance: maintenance,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Vehiculo copyWith({
    int? id,
    String? marca,
    String? modelo,
    int? ano,
    String? placa,
    String? tipo,
    int? kilometraje,
    String? imagenPersonalizada,
    Map<String, MaintenanceData>? maintenance,
    DateTime? createdAt,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      placa: placa ?? this.placa,
      tipo: tipo ?? this.tipo,
      kilometraje: kilometraje ?? this.kilometraje,
      imagenPersonalizada: imagenPersonalizada ?? this.imagenPersonalizada,
      maintenance: maintenance ?? this.maintenance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Factory method para crear un nuevo vehículo
  factory Vehiculo.nuevo({
    required String marca,
    required String modelo,
    required int ano,
    required String placa,
    required String tipo,
    required int kilometraje,
    String? imagenPersonalizada,
  }) {
    // Inicializar datos de mantenimiento usando MaintenanceService
    final maintenanceData = MaintenanceService.initializeMaintenanceData(tipo, kilometraje);
    
    return Vehiculo(
      marca: marca,
      modelo: modelo,
      ano: ano,
      placa: placa,
      tipo: tipo,
      kilometraje: kilometraje,
      imagenPersonalizada: imagenPersonalizada,
      maintenance: maintenanceData,
      createdAt: DateTime.now(),
    );
  }

  // Métodos de conveniencia para compatibilidad
  String get proximoMantenimiento {
    final criticalMaintenance = maintenance.entries
        .where((entry) => entry.value.percentage <= 30)
        .toList();
    
    if (criticalMaintenance.isEmpty) {
      return 'Todo en orden';
    }
    
    return criticalMaintenance.first.key;
  }

  int get kmProximoMantenimiento {
    final criticalMaintenance = maintenance.entries
        .where((entry) => entry.value.percentage <= 30)
        .toList();
    
    if (criticalMaintenance.isEmpty) {
      return kilometraje + 5000; // Valor por defecto
    }
    
    return criticalMaintenance.first.value.dueKm;
  }

  int get estadoAceite => maintenance['oil']?.percentage.round() ?? 100;
  int get estadoLlantas => maintenance['tires']?.percentage.round() ?? 100;
  int get estadoFrenos => maintenance['brakes']?.percentage.round() ?? 100;
  int get estadoBateria => maintenance['battery']?.percentage.round() ?? 100;

  // Método para crear un vehículo nuevo con mantenimiento inicializado
  static Vehiculo createNew({
    required String marca,
    required String modelo,
    required int ano,
    required String placa,
    required String tipo,
    required int kilometraje,
    String? imagenPersonalizada,
  }) {
    final now = DateTime.now();
    final maintenance = _initializeMaintenance(kilometraje, tipo, now);
    
    return Vehiculo(
      marca: marca,
      modelo: modelo,
      ano: ano,
      placa: placa,
      tipo: tipo,
      kilometraje: kilometraje,
      imagenPersonalizada: imagenPersonalizada,
      maintenance: maintenance,
      createdAt: now,
    );
  }

  // Inicializar mantenimiento para vehículo nuevo
  static Map<String, MaintenanceData> _initializeMaintenance(int kilometraje, String tipo, DateTime now) {
    final maintenance = <String, MaintenanceData>{};
    
    // Intervalos de mantenimiento por categoría
    const intervals = {
      'oil': 5000,
      'tires': 40000,
      'brakes': 30000,
      'battery': 50000,
      'coolant': 20000,
      'airFilter': 17500,    // Solo carros
      'alignment': 10000,    // Solo carros
      'chain': 22500,        // Solo motos
      'sparkPlug': 11000,    // Solo motos
    };

    // Categorías universales
    final universalCategories = ['oil', 'tires', 'brakes', 'battery', 'coolant'];
    
    // Categorías específicas por tipo
    final carCategories = ['airFilter', 'alignment'];
    final motoCategories = ['chain', 'sparkPlug'];
    
    final categoriesToInclude = List<String>.from(universalCategories);
    
    if (tipo == 'carro') {
      categoriesToInclude.addAll(carCategories);
    } else if (tipo == 'moto') {
      categoriesToInclude.addAll(motoCategories);
    }

    for (final category in categoriesToInclude) {
      final interval = intervals[category]!;
      maintenance[category] = MaintenanceData(
        percentage: 100.0, // Asumimos recién hecho
        lastChanged: now.toIso8601String(),
        dueKm: kilometraje + interval,
      );
    }

    return maintenance;
  }
}
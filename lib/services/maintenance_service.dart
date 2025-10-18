import '../models/vehiculo.dart';

class MaintenanceService {
  // Intervalos de mantenimiento por categoría (en kilómetros)
  static const Map<String, int> maintenanceIntervals = {
    'oil': 5000,
    'tires': 40000,
    'brakes': 30000,
    'battery': 50000,
    'coolant': 20000,
    'airFilter': 17500,    // Solo carros
    'alignment': 10000,     // Solo carros
    'chain': 22500,         // Solo motos
    'sparkPlug': 11000,     // Solo motos
  };

  // Categorías por tipo de vehículo
  static const List<String> universalCategories = ['oil', 'tires', 'brakes', 'battery', 'coolant'];
  static const List<String> carCategories = ['airFilter', 'alignment'];
  static const List<String> motoCategories = ['chain', 'sparkPlug'];

  /// Calcular porcentaje de vida útil restante para una categoría específica
  static double calculateMaintenancePercentage({
    required int currentMileage,
    required int lastMaintenanceMileage,
    required String maintenanceType,
  }) {
    final interval = maintenanceIntervals[maintenanceType] ?? 5000;
    
    // Calcular kilómetros desde el último mantenimiento
    final kmSinceLastMaintenance = currentMileage - lastMaintenanceMileage;
    
    // Calcular porcentaje de vida útil restante
    final percentage = 100 - (kmSinceLastMaintenance / interval) * 100;
    
    // Limitar entre 0 y 100
    return percentage.clamp(0.0, 100.0);
  }

  /// Obtener categorías de mantenimiento para un tipo de vehículo
  static List<String> getMaintenanceCategoriesForVehicleType(String vehicleType) {
    final categories = List<String>.from(universalCategories);
    
    if (vehicleType == 'carro') {
      categories.addAll(carCategories);
    } else if (vehicleType == 'moto') {
      categories.addAll(motoCategories);
    }
    
    return categories;
  }

  /// Inicializar datos de mantenimiento para un nuevo vehículo
  static Map<String, MaintenanceData> initializeMaintenanceData(String vehicleType, int initialMileage) {
    final categories = getMaintenanceCategoriesForVehicleType(vehicleType);
    final Map<String, MaintenanceData> data = {};
    final now = DateTime.now();

    for (var category in categories) {
      final interval = maintenanceIntervals[category] ?? 0;
      data[category] = MaintenanceData(
        percentage: 100.0,
        lastChanged: now.toIso8601String(),
        dueKm: initialMileage + interval,
      );
    }
    return data;
  }

  /// Recalcular todos los porcentajes de mantenimiento de un vehículo
  static Map<String, MaintenanceData> recalculateAllPercentages(Vehiculo vehiculo) {
    final updatedMaintenance = <String, MaintenanceData>{};
    
    for (final entry in vehiculo.maintenance.entries) {
      final maintenanceType = entry.key;
      final maintenanceData = entry.value;
      
      // Calcular nuevo porcentaje
      final newPercentage = calculateMaintenancePercentage(
        currentMileage: vehiculo.kilometraje,
        lastMaintenanceMileage: maintenanceData.dueKm - (maintenanceIntervals[maintenanceType] ?? 5000),
        maintenanceType: maintenanceType,
      );
      
      // Actualizar datos de mantenimiento
      updatedMaintenance[maintenanceType] = maintenanceData.copyWith(
        percentage: newPercentage,
      );
    }
    
    return updatedMaintenance;
  }

  /// Actualizar una categoría específica después de completar mantenimiento
  static MaintenanceData updateMaintenanceAfterCompletion({
    required String maintenanceType,
    required int completionMileage,
    required DateTime completionDate,
  }) {
    final interval = maintenanceIntervals[maintenanceType] ?? 5000;
    
    return MaintenanceData(
      percentage: 100.0, // Recién hecho
      lastChanged: completionDate.toIso8601String(),
      dueKm: completionMileage + interval,
    );
  }

  /// Obtener categorías disponibles según el tipo de vehículo
  static List<String> getAvailableCategories(String vehicleType) {
    final categories = List<String>.from(universalCategories);
    
    if (vehicleType == 'carro') {
      categories.addAll(carCategories);
    } else if (vehicleType == 'moto') {
      categories.addAll(motoCategories);
    }
    
    return categories;
  }

  /// Obtener nombre legible de la categoría
  static String getCategoryDisplayName(String category) {
    const categoryNames = {
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
    return categoryNames[category] ?? category;
  }

  /// Obtener color de la barra de progreso según el porcentaje
  static String getProgressBarColor(double percentage) {
    if (percentage <= 10) return 'red';      // Crítico
    if (percentage <= 30) return 'orange';   // Urgente
    if (percentage <= 60) return 'yellow';   // Precaución
    if (percentage <= 90) return 'blue';      // Bueno
    return 'green';                           // Excelente
  }

  /// Verificar si un mantenimiento necesita atención crítica
  static bool isCriticalMaintenance(double percentage) {
    return percentage <= 30;
  }

  /// Obtener mantenimientos críticos de un vehículo
  static List<MapEntry<String, MaintenanceData>> getCriticalMaintenances(Vehiculo vehiculo) {
    return vehiculo.maintenance.entries
        .where((entry) => isCriticalMaintenance(entry.value.percentage))
        .toList();
  }

  /// Calcular días hasta próximo mantenimiento
  static int getDaysUntilMaintenance(MaintenanceData maintenanceData, int currentMileage) {
    final kmRemaining = maintenanceData.dueKm - currentMileage;
    // Asumir un promedio de 50 km por día
    return (kmRemaining / 50).round();
  }

  /// Validar si se puede agendar mantenimiento
  static String? validateScheduledMaintenance({
    required int currentMileage,
    required int scheduledMileage,
    required DateTime scheduledDate,
  }) {
    if (scheduledMileage <= currentMileage) {
      return 'El kilometraje programado debe ser mayor al kilometraje actual';
    }
    
    if (scheduledDate.isBefore(DateTime.now())) {
      return 'La fecha programada no puede ser en el pasado';
    }
    
    return null; // Válido
  }

  /// Determinar el estado de un mantenimiento programado
  static String determineMaintenanceStatus({
    required DateTime scheduledDate,
    required int scheduledMileage,
    required int currentMileage,
  }) {
    final now = DateTime.now();
    
    // Si ya se pasó la fecha o el kilometraje, es urgente
    if (now.isAfter(scheduledDate) || currentMileage >= scheduledMileage) {
      return 'urgent';
    }
    
    return 'pending';
  }

  /// Obtener icono para cada tipo de mantenimiento
  static String getMaintenanceIcon(String category) {
    const categoryIcons = {
      'oil': 'oil_barrel',
      'tires': 'directions_car',
      'brakes': 'stop_circle',
      'battery': 'battery_charging_full',
      'coolant': 'thermostat',
      'airFilter': 'air',
      'alignment': 'settings',
      'chain': 'link',
      'sparkPlug': 'flash_on',
    };
    return categoryIcons[category] ?? 'build';
  }
}

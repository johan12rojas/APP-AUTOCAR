import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../database/database_helper.dart';

class AutoMaintenanceScheduler {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Programa automáticamente mantenimientos basados en el estado del vehículo
  static Future<void> scheduleAutoMaintenance(Vehiculo vehiculo, [DatabaseHelper? dbHelper]) async {
    final helper = dbHelper ?? _dbHelper;
    final mantenimientosExistentes = await helper.getMantenimientosByVehiculoId(vehiculo.id!);
    
    // Obtener categorías que necesitan mantenimiento
    final categoriasCriticas = _getCriticalCategories(vehiculo);
    
    for (final categoria in categoriasCriticas) {
      // Verificar si ya existe un mantenimiento pendiente para esta categoría
      final existePendiente = mantenimientosExistentes.any(
        (m) => m.tipo == categoria && (m.status == 'pending' || m.status == 'urgent')
      );
      
      if (!existePendiente) {
        await _createMaintenanceEntry(vehiculo, categoria, helper);
      }
    }
  }

  /// Obtiene las categorías que están en estado crítico o bajo
  static List<String> _getCriticalCategories(Vehiculo vehiculo) {
    final categoriasCriticas = <String>[];
    
    vehiculo.maintenance.forEach((categoria, datos) {
      if (datos.percentage <= 30) { // Crítico o bajo
        categoriasCriticas.add(categoria);
      }
    });
    
    return categoriasCriticas;
  }

  /// Crea una entrada de mantenimiento automática
  static Future<void> _createMaintenanceEntry(Vehiculo vehiculo, String categoria, DatabaseHelper dbHelper) async {
    final datos = vehiculo.maintenance[categoria]!;
    final dueKm = datos.dueKm;
    final kmRestantes = dueKm - vehiculo.kilometraje;
    final percentage = datos.percentage;
    
    // Determinar el estado basado en la urgencia
    String status = 'pending';
    if (percentage <= 10) {
      status = 'urgent';
    } else if (percentage <= 30) {
      status = 'pending';
    }

    // Calcular fecha sugerida basada en kilometraje restante
    final diasRestantes = (kmRestantes / 50).round(); // Asumiendo 50 km/día promedio
    final fechaSugerida = DateTime.now().add(Duration(days: diasRestantes.clamp(1, 30)));

    final mantenimiento = Mantenimiento(
      vehiculoId: vehiculo.id!,
      tipo: categoria,
      fecha: fechaSugerida,
      kilometraje: dueKm,
      notas: 'Mantenimiento automático programado por el sistema',
      costo: 0.0,
      ubicacion: '',
      status: status,
    );

    await dbHelper.insertMantenimiento(mantenimiento);
  }

  /// Actualiza el estado de un mantenimiento cuando se completa
  static Future<void> completeMaintenance(int mantenimientoId, Vehiculo vehiculo, [DatabaseHelper? dbHelper]) async {
    final helper = dbHelper ?? _dbHelper;
    final mantenimiento = await helper.getMantenimientoById(mantenimientoId);
    if (mantenimiento == null) return;

    // Obtener el vehículo actualizado de la base de datos para tener el kilometraje correcto
    final vehiculoActualizado = await helper.getVehiculoById(vehiculo.id!);
    if (vehiculoActualizado == null) return;

    // Actualizar el estado del mantenimiento
    final mantenimientoActualizado = mantenimiento.copyWith(
      status: 'completed',
    );

    await helper.updateMantenimiento(mantenimientoActualizado);

    // Actualizar el estado del vehículo para esa categoría usando el vehículo actualizado
    await _updateVehicleMaintenanceStatus(vehiculoActualizado, mantenimiento.tipo, helper);
  }

  /// Actualiza el estado de mantenimiento del vehículo después de completar un mantenimiento
  static Future<void> _updateVehicleMaintenanceStatus(Vehiculo vehiculo, String categoria, DatabaseHelper dbHelper) async {
    final datos = vehiculo.maintenance[categoria]!;
    
    // Resetear el estado a 100% bueno
    final nuevosDatos = datos.copyWith(
      percentage: 100.0,
      dueKm: vehiculo.kilometraje + _getNextMaintenanceInterval(categoria),
      lastChanged: vehiculo.kilometraje.toString(),
    );

    // Actualizar el vehículo con los nuevos datos
    final nuevosEstados = Map<String, MaintenanceData>.from(vehiculo.maintenance);
    nuevosEstados[categoria] = nuevosDatos;

    final vehiculoActualizado = vehiculo.copyWith(maintenance: nuevosEstados);
    await dbHelper.updateVehiculo(vehiculoActualizado);
  }

  /// Obtiene el intervalo de kilometraje para el próximo mantenimiento
  static int _getNextMaintenanceInterval(String categoria) {
    switch (categoria) {
      case 'oil':
        return 5000; // 5,000 km
      case 'brakes':
        return 30000; // 30,000 km
      case 'battery':
        return 50000; // 50,000 km
      case 'tires':
        return 40000; // 40,000 km
      case 'airFilter':
        return 17500; // 17,500 km
      case 'sparkPlug':
        return 11000; // 11,000 km
      case 'coolant':
        return 20000; // 20,000 km
      case 'alignment':
        return 10000; // 10,000 km
      case 'chain':
        return 22500; // 22,500 km
      default:
        return 10000; // 10,000 km por defecto
    }
  }

  /// Verifica y programa mantenimientos para todos los vehículos
  static Future<void> checkAndScheduleAllVehicles() async {
    final vehiculos = await _dbHelper.getAllVehiculos();
    
    for (final vehiculo in vehiculos) {
      await scheduleAutoMaintenance(vehiculo);
    }
  }
}

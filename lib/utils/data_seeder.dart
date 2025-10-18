import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../database/database_helper.dart';

class DataSeeder {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<void> seedData() async {
    // Verificar si ya hay datos
    final vehiculos = await _dbHelper.getVehiculos();
    if (vehiculos.isNotEmpty) return;

    // Crear vehículo de ejemplo usando el nuevo sistema
    final vehiculo = Vehiculo.createNew(
      marca: 'Honda',
      modelo: 'Civic Sedan',
      ano: 2022,
      placa: 'ABC-123',
      tipo: 'carro',
      kilometraje: 33000,
    );

    final vehiculoId = await _dbHelper.insertVehiculo(vehiculo);

    // Crear algunos mantenimientos de ejemplo usando el nuevo sistema
    final mantenimientos = [
      Mantenimiento.schedule(
        vehiculoId: vehiculoId,
        tipo: 'oil',
        fechaProgramada: DateTime.now().subtract(const Duration(days: 30)),
        kilometrajeProgramado: 30000,
        notas: 'Cambio de aceite de motor y filtro',
        costoEstimado: 45.00,
        ubicacion: 'Taller Automotriz Central',
      ).complete(
        kilometrajeReal: 30000,
        fechaReal: DateTime.now().subtract(const Duration(days: 30)),
        costoReal: 45.00,
        notasReales: 'Aceite sintético 5W-30',
        ubicacionReal: 'Taller Automotriz Central',
      ),
      Mantenimiento.schedule(
        vehiculoId: vehiculoId,
        tipo: 'brakes',
        fechaProgramada: DateTime.now().subtract(const Duration(days: 90)),
        kilometrajeProgramado: 25000,
        notas: 'Cambio de pastillas de freno delanteras',
        costoEstimado: 85.00,
        ubicacion: 'Taller Automotriz Central',
      ).complete(
        kilometrajeReal: 25000,
        fechaReal: DateTime.now().subtract(const Duration(days: 90)),
        costoReal: 85.00,
        notasReales: 'Pastillas originales Honda',
        ubicacionReal: 'Taller Automotriz Central',
      ),
      Mantenimiento.schedule(
        vehiculoId: vehiculoId,
        tipo: 'tires',
        fechaProgramada: DateTime.now().add(const Duration(days: 30)),
        kilometrajeProgramado: 45000,
        notas: 'Cambio de llantas',
        costoEstimado: 300.00,
        ubicacion: 'Taller Automotriz Central',
      ),
    ];

    for (final mantenimiento in mantenimientos) {
      await _dbHelper.insertMantenimiento(mantenimiento);
    }
  }
}
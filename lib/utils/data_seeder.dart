import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../database/database_helper.dart';

class DataSeeder {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<void> seedData() async {
    // Verificar si ya hay datos
    final vehiculos = await _dbHelper.getVehiculos();
    if (vehiculos.isNotEmpty) return;

    // Crear vehículo de ejemplo
    final vehiculo = Vehiculo(
      marca: 'Honda',
      modelo: 'Civic Sedan',
      ano: '2022',
      placa: 'ABC-123',
      color: 'Blanco',
      kilometraje: 33000,
      tipo: 'auto',
      estadoAceite: 56,
      estadoLlantas: 30,
      estadoFrenos: 50,
      estadoBateria: 79,
      proximoMantenimiento: 'Llantas en 12000 km',
      kmProximoMantenimiento: 45000,
    );

    final vehiculoId = await _dbHelper.insertVehiculo(vehiculo);

    // Crear algunos mantenimientos de ejemplo
    final mantenimientos = [
      Mantenimiento(
        vehiculoId: vehiculoId,
        fecha: DateTime.now().subtract(const Duration(days: 30)),
        tipo: 'Cambio de Aceite',
        descripcion: 'Cambio de aceite de motor y filtro',
        costo: 45.00,
        kilometraje: 30000,
        taller: 'Taller Automotriz Central',
        notas: 'Aceite sintético 5W-30',
      ),
      Mantenimiento(
        vehiculoId: vehiculoId,
        fecha: DateTime.now().subtract(const Duration(days: 60)),
        tipo: 'Revisión General',
        descripcion: 'Revisión completa del vehículo',
        costo: 120.00,
        kilometraje: 28000,
        taller: 'Taller Automotriz Central',
        notas: 'Todo en buen estado',
      ),
      Mantenimiento(
        vehiculoId: vehiculoId,
        fecha: DateTime.now().subtract(const Duration(days: 90)),
        tipo: 'Frenos',
        descripcion: 'Cambio de pastillas de freno delanteras',
        costo: 85.00,
        kilometraje: 25000,
        taller: 'Taller Automotriz Central',
        notas: 'Pastillas originales Honda',
      ),
    ];

    for (final mantenimiento in mantenimientos) {
      await _dbHelper.insertMantenimiento(mantenimiento);
    }
  }
}

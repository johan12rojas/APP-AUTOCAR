import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../database/database_helper.dart';
import '../services/maintenance_service.dart';
import '../services/auto_maintenance_scheduler.dart';

class VehiculoViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  List<Vehiculo> _vehiculos = [];
  Vehiculo? _vehiculoActual;
  List<Mantenimiento> _mantenimientos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Vehiculo> get vehiculos => _vehiculos;
  Vehiculo? get vehiculoActual => _vehiculoActual;
  List<Mantenimiento> get mantenimientos => _mantenimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mantenimientos por estado
  List<Mantenimiento> get mantenimientosPendientes => 
      _mantenimientos.where((m) => m.status == 'pending').toList();
  
  List<Mantenimiento> get mantenimientosUrgentes => 
      _mantenimientos.where((m) => m.status == 'urgent').toList();
  
  List<Mantenimiento> get mantenimientosCompletados => 
      _mantenimientos.where((m) => m.status == 'completed').toList();

  // Alertas críticas
  List<MapEntry<String, MaintenanceData>> get alertasCriticas {
    if (_vehiculoActual == null) return [];
    return MaintenanceService.getCriticalMaintenances(_vehiculoActual!);
  }

  // Cargar todos los vehículos
  Future<void> cargarVehiculos() async {
    _setLoading(true);
    try {
      _vehiculos = await _databaseHelper.getAllVehiculos();
      if (_vehiculos.isNotEmpty) {
        // Si no hay vehículo actual, usar el primero
        if (_vehiculoActual == null) {
          _vehiculoActual = _vehiculos.first;
        } else {
          // Actualizar el vehículo actual con los datos más recientes
          final vehiculoActualizado = _vehiculos.firstWhere(
            (v) => v.id == _vehiculoActual!.id,
            orElse: () => _vehiculos.first,
          );
          _vehiculoActual = vehiculoActualizado;
        }
        await cargarMantenimientos();
      }
      _clearError();
    } catch (e) {
      _setError('Error al cargar vehículos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar mantenimientos del vehículo actual
  Future<void> cargarMantenimientos() async {
    if (_vehiculoActual == null) return;
    
    _setLoading(true);
    try {
      _mantenimientos = await _databaseHelper.getMantenimientosByVehiculo(_vehiculoActual!.id!);
      
      // Programar mantenimientos automáticos si es necesario
      await AutoMaintenanceScheduler.scheduleAutoMaintenance(_vehiculoActual!, _databaseHelper);
      
      // Recargar mantenimientos después de la programación automática
      _mantenimientos = await _databaseHelper.getMantenimientosByVehiculo(_vehiculoActual!.id!);
      
      _clearError();
    } catch (e) {
      _setError('Error al cargar mantenimientos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cambiar vehículo actual
  Future<void> cambiarVehiculoActual(Vehiculo vehiculo) async {
    _vehiculoActual = vehiculo;
    await cargarMantenimientos();
    notifyListeners();
  }

  // Agregar nuevo vehículo (versión con objeto Vehiculo)
  Future<void> agregarVehiculo(Vehiculo nuevoVehiculo) async {
    _setLoading(true);
    try {
      final id = await _databaseHelper.insertVehiculo(nuevoVehiculo);
      final vehiculoConId = nuevoVehiculo.copyWith(id: id);
      
      _vehiculos.add(vehiculoConId);
      if (_vehiculoActual == null) {
        _vehiculoActual = vehiculoConId;
        await cargarMantenimientos();
      }
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error al agregar vehículo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Agregar nuevo vehículo (versión con parámetros individuales)
  Future<void> agregarVehiculoFromParams({
    required String marca,
    required String modelo,
    required int ano,
    required String placa,
    required String tipo,
    required int kilometraje,
    String? imagenPersonalizada,
  }) async {
    _setLoading(true);
    try {
      final nuevoVehiculo = Vehiculo.nuevo(
        marca: marca,
        modelo: modelo,
        ano: ano,
        placa: placa,
        tipo: tipo,
        kilometraje: kilometraje,
        imagenPersonalizada: imagenPersonalizada,
      );
      
      final id = await _databaseHelper.insertVehiculo(nuevoVehiculo);
      final vehiculoConId = nuevoVehiculo.copyWith(id: id);
      
      _vehiculos.add(vehiculoConId);
      if (_vehiculoActual == null) {
        _vehiculoActual = vehiculoConId;
        await cargarMantenimientos();
      }
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error al agregar vehículo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar kilometraje del vehículo
  Future<void> actualizarKilometraje(int nuevoKilometraje) async {
    if (_vehiculoActual == null) return;
    
    _setLoading(true);
    try {
      // Recalcular todos los porcentajes de mantenimiento
      final maintenanceActualizado = MaintenanceService.recalculateAllPercentages(
        _vehiculoActual!.copyWith(kilometraje: nuevoKilometraje)
      );
      
      final vehiculoActualizado = _vehiculoActual!.copyWith(
        kilometraje: nuevoKilometraje,
        maintenance: maintenanceActualizado,
      );
      
      await _databaseHelper.updateVehiculo(vehiculoActualizado);
      
      // Actualizar en la lista local
      final index = _vehiculos.indexWhere((v) => v.id == _vehiculoActual!.id);
      if (index != -1) {
        _vehiculos[index] = vehiculoActualizado;
      }
      
      _vehiculoActual = vehiculoActualizado;
      _clearError();
    } catch (e) {
      _setError('Error al actualizar kilometraje: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Agendar mantenimiento
  Future<void> agendarMantenimiento({
    required String tipo,
    required DateTime fechaProgramada,
    required int kilometrajeProgramado,
    String notas = '',
    double costoEstimado = 0.0,
    String ubicacion = '',
  }) async {
    if (_vehiculoActual == null) return;
    
    _setLoading(true);
    try {
      // Validar datos
      final validationError = MaintenanceService.validateScheduledMaintenance(
        currentMileage: _vehiculoActual!.kilometraje,
        scheduledMileage: kilometrajeProgramado,
        scheduledDate: fechaProgramada,
      );
      
      if (validationError != null) {
        _setError(validationError);
        return;
      }
      
      // Determinar estado inicial
      final status = MaintenanceService.determineMaintenanceStatus(
        scheduledDate: fechaProgramada,
        scheduledMileage: kilometrajeProgramado,
        currentMileage: _vehiculoActual!.kilometraje,
      );
      
      final mantenimiento = Mantenimiento.schedule(
        vehiculoId: _vehiculoActual!.id!,
        tipo: tipo,
        fechaProgramada: fechaProgramada,
        kilometrajeProgramado: kilometrajeProgramado,
        notas: notas,
        costoEstimado: costoEstimado,
        ubicacion: ubicacion,
      ).copyWith(status: status);
      
      await _databaseHelper.insertMantenimiento(mantenimiento);
      await cargarMantenimientos();
      _clearError();
    } catch (e) {
      _setError('Error al agendar mantenimiento: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Completar mantenimiento
  Future<void> completarMantenimiento({
    required int mantenimientoId,
    required int kilometrajeReal,
    required DateTime fechaReal,
    double? costoReal,
    String? notasReales,
    String? ubicacionReal,
    required int nuevoKilometrajeVehiculo,
  }) async {
    _setLoading(true);
    try {
      // Actualizar el kilometraje del vehículo primero
      await actualizarKilometrajeVehiculo(_vehiculoActual!.id!, nuevoKilometrajeVehiculo);
      
      // Completar el mantenimiento usando el AutoMaintenanceScheduler
      await AutoMaintenanceScheduler.completeMaintenance(
        mantenimientoId, 
        _vehiculoActual!, 
        dbHelper: _databaseHelper,
      );
      
      await cargarMantenimientos();
      _clearError();
    } catch (e) {
      _setError('Error al completar mantenimiento: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar mantenimiento
  Future<void> eliminarMantenimiento(int mantenimientoId) async {
    _setLoading(true);
    try {
      await _databaseHelper.deleteMantenimiento(mantenimientoId);
      await cargarMantenimientos();
      _clearError();
    } catch (e) {
      _setError('Error al eliminar mantenimiento: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar vehículo
  Future<void> eliminarVehiculo(int vehiculoId) async {
    _setLoading(true);
    try {
      await _databaseHelper.deleteVehiculo(vehiculoId);
      _vehiculos.removeWhere((v) => v.id == vehiculoId);
      
      if (_vehiculoActual?.id == vehiculoId) {
        _vehiculoActual = _vehiculos.isNotEmpty ? _vehiculos.first : null;
        if (_vehiculoActual != null) {
          await cargarMantenimientos();
        } else {
          _mantenimientos.clear();
        }
      }
      _clearError();
    } catch (e) {
      _setError('Error al eliminar vehículo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Obtener estadísticas
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      return await _databaseHelper.getEstadisticasGenerales();
    } catch (e) {
      _setError('Error al obtener estadísticas: $e');
      return {};
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Limpiar errores manualmente
  void limpiarError() {
    _clearError();
  }

  // Actualizar kilometraje de un vehículo específico
  Future<void> actualizarKilometrajeVehiculo(int vehiculoId, int nuevoKilometraje) async {
    try {
      await _databaseHelper.updateVehiculoKilometraje(vehiculoId, nuevoKilometraje);
      
      // Actualizar el vehículo en la lista local
      final index = _vehiculos.indexWhere((v) => v.id == vehiculoId);
      if (index != -1) {
        _vehiculos[index] = _vehiculos[index].copyWith(kilometraje: nuevoKilometraje);
        
        // Si es el vehículo actual, actualizarlo también
        if (_vehiculoActual?.id == vehiculoId) {
          _vehiculoActual = _vehiculos[index];
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al actualizar kilometraje: $e');
    }
  }

  // Recalcular estados del vehículo basado en el nuevo kilometraje
  Future<void> recalcularEstadosVehiculo(int vehiculoId) async {
    try {
      final vehiculo = _vehiculos.firstWhere((v) => v.id == vehiculoId);
      
      // Recalcular todos los estados de mantenimiento
      final nuevosEstados = <String, MaintenanceData>{};
      
      for (final categoria in vehiculo.maintenance.keys) {
        final data = vehiculo.maintenance[categoria];
        if (data != null) {
          final ultimoMantenimiento = int.tryParse(data.lastChanged) ?? 0;
          final intervalo = data.dueKm - ultimoMantenimiento;
          
          // Calcular nuevo porcentaje basado en el kilometraje actual
          final kilometrosRecorridos = vehiculo.kilometraje - ultimoMantenimiento;
          final porcentaje = ((intervalo - kilometrosRecorridos) / intervalo * 100).clamp(0.0, 100.0);
          
          nuevosEstados[categoria] = data.copyWith(
            percentage: porcentaje,
            dueKm: ultimoMantenimiento + intervalo,
          );
        }
      }
      
      // Actualizar el vehículo con los nuevos estados
      final vehiculoActualizado = vehiculo.copyWith(maintenance: nuevosEstados);
      
      // Guardar en la base de datos
      await _databaseHelper.updateVehiculo(vehiculoActualizado);
      
      // Actualizar en la lista local
      final index = _vehiculos.indexWhere((v) => v.id == vehiculoId);
      if (index != -1) {
        _vehiculos[index] = vehiculoActualizado;
        
        // Si es el vehículo actual, actualizarlo también
        if (_vehiculoActual?.id == vehiculoId) {
          _vehiculoActual = vehiculoActualizado;
        }
        
        // Programar mantenimientos automáticamente si es necesario
        await AutoMaintenanceScheduler.scheduleAutoMaintenance(vehiculoActualizado, _databaseHelper);
        
      notifyListeners();
    }
  } catch (e) {
    _setError('Error al recalcular estados: $e');
  }
}

// Actualizar un vehículo existente
Future<void> actualizarVehiculo(Vehiculo vehiculo) async {
  _setLoading(true);
  try {
    await _databaseHelper.updateVehiculo(vehiculo);
    
    // Actualizar en la lista local
    final index = _vehiculos.indexWhere((v) => v.id == vehiculo.id);
    if (index != -1) {
      _vehiculos[index] = vehiculo;
      
      // Si es el vehículo actual, actualizarlo también
      if (_vehiculoActual?.id == vehiculo.id) {
        _vehiculoActual = vehiculo;
      }
      
      notifyListeners();
    }
    
    _clearError();
  } catch (e) {
    _setError('Error al actualizar vehículo: $e');
  } finally {
    _setLoading(false);
  }
}

}

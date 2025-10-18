import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'autocar_mantenimiento.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de vehículos con nueva estructura
    await db.execute('''
      CREATE TABLE vehiculos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        ano INTEGER NOT NULL,
        placa TEXT NOT NULL UNIQUE,
        tipo TEXT NOT NULL,
        kilometraje INTEGER NOT NULL,
        maintenance TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Tabla de mantenimientos con nueva estructura
    await db.execute('''
      CREATE TABLE mantenimientos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehiculoId INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        fecha TEXT NOT NULL,
        kilometraje INTEGER NOT NULL,
        notas TEXT NOT NULL,
        costo REAL NOT NULL,
        ubicacion TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (vehiculoId) REFERENCES vehiculos (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Migrar a nueva estructura
      await db.execute('DROP TABLE IF EXISTS vehiculos');
      await db.execute('DROP TABLE IF EXISTS mantenimientos');
      await _onCreate(db, newVersion);
    }
  }

  // Métodos para vehículos
  Future<int> insertVehiculo(Vehiculo vehiculo) async {
    final db = await database;
    final map = vehiculo.toMap();
    map['maintenance'] = jsonEncode(map['maintenance']);
    return await db.insert('vehiculos', map);
  }

  Future<List<Vehiculo>> getVehiculos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vehiculos');
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['maintenance'] = jsonDecode(map['maintenance']);
      return Vehiculo.fromMap(map);
    });
  }

  Future<List<Vehiculo>> getAllVehiculos() async {
    return getVehiculos();
  }

  Future<Vehiculo?> getVehiculo(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehiculos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final map = Map<String, dynamic>.from(maps.first);
      map['maintenance'] = jsonDecode(map['maintenance']);
      return Vehiculo.fromMap(map);
    }
    return null;
  }

  Future<Vehiculo?> getVehiculoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehiculos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final map = Map<String, dynamic>.from(maps.first);
      map['maintenance'] = jsonDecode(map['maintenance']);
      return Vehiculo.fromMap(map);
    }
    return null;
  }

  Future<int> updateVehiculo(Vehiculo vehiculo) async {
    final db = await database;
    final map = vehiculo.toMap();
    map['maintenance'] = jsonEncode(map['maintenance']);
    return await db.update(
      'vehiculos',
      map,
      where: 'id = ?',
      whereArgs: [vehiculo.id],
    );
  }

  Future<int> deleteVehiculo(int id) async {
    final db = await database;
    return await db.delete(
      'vehiculos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para mantenimientos
  Future<int> insertMantenimiento(Mantenimiento mantenimiento) async {
    final db = await database;
    return await db.insert('mantenimientos', mantenimiento.toMap());
  }

  Future<List<Mantenimiento>> getMantenimientosByVehiculo(int vehiculoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mantenimientos',
      where: 'vehiculoId = ?',
      whereArgs: [vehiculoId],
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) {
      return Mantenimiento.fromMap(maps[i]);
    });
  }

  // Alias method for AutoMaintenanceScheduler
  Future<List<Mantenimiento>> getMantenimientosByVehiculoId(int vehiculoId) async {
    return getMantenimientosByVehiculo(vehiculoId);
  }

  Future<List<Mantenimiento>> getMantenimientosPorVehiculo(int vehiculoId) async {
    return getMantenimientosByVehiculo(vehiculoId);
  }

  Future<List<Mantenimiento>> getAllMantenimientos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mantenimientos',
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) {
      return Mantenimiento.fromMap(maps[i]);
    });
  }

  Future<List<Mantenimiento>> getMantenimientosByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mantenimientos',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) {
      return Mantenimiento.fromMap(maps[i]);
    });
  }

  Future<List<Mantenimiento>> getMantenimientosUrgentes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mantenimientos',
      where: 'status = ?',
      whereArgs: ['urgent'],
      orderBy: 'fecha ASC',
    );
    return List.generate(maps.length, (i) {
      return Mantenimiento.fromMap(maps[i]);
    });
  }

  Future<int> updateMantenimiento(Mantenimiento mantenimiento) async {
    final db = await database;
    return await db.update(
      'mantenimientos',
      mantenimiento.toMap(),
      where: 'id = ?',
      whereArgs: [mantenimiento.id],
    );
  }

  Future<Mantenimiento?> getMantenimientoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mantenimientos',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Mantenimiento.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteMantenimiento(int id) async {
    final db = await database;
    return await db.delete(
      'mantenimientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos específicos para el nuevo sistema
  Future<void> scheduleMaintenance({
    required int vehiculoId,
    required String tipo,
    required DateTime fechaProgramada,
    required int kilometrajeProgramado,
    String notas = '',
    double costoEstimado = 0.0,
    String ubicacion = '',
  }) async {
    final mantenimiento = Mantenimiento.schedule(
      vehiculoId: vehiculoId,
      tipo: tipo,
      fechaProgramada: fechaProgramada,
      kilometrajeProgramado: kilometrajeProgramado,
      notas: notas,
      costoEstimado: costoEstimado,
      ubicacion: ubicacion,
    );
    
    await insertMantenimiento(mantenimiento);
  }

  Future<void> completeMaintenance({
    required int mantenimientoId,
    required int kilometrajeReal,
    required DateTime fechaReal,
    double? costoReal,
    String? notasReales,
    String? ubicacionReal,
    required int nuevoKilometrajeVehiculo,
  }) async {
    final db = await database;
    
    // Obtener el mantenimiento
    final mantenimiento = await db.query(
      'mantenimientos',
      where: 'id = ?',
      whereArgs: [mantenimientoId],
    );
    
    if (mantenimiento.isEmpty) return;
    
    final mantenimientoData = Mantenimiento.fromMap(mantenimiento.first);
    
    // Actualizar el mantenimiento
    final mantenimientoCompletado = mantenimientoData.complete(
      kilometrajeReal: kilometrajeReal,
      fechaReal: fechaReal,
      costoReal: costoReal,
      notasReales: notasReales,
      ubicacionReal: ubicacionReal,
    );
    
    await updateMantenimiento(mantenimientoCompletado);
    
    // Actualizar el vehículo
    final vehiculo = await getVehiculo(mantenimientoData.vehiculoId);
    if (vehiculo != null) {
      // Actualizar kilometraje
      final vehiculoActualizado = vehiculo.copyWith(
        kilometraje: nuevoKilometrajeVehiculo,
      );
      
      await updateVehiculo(vehiculoActualizado);
    }
  }

  // Métodos de estadísticas
  Future<Map<String, dynamic>> getEstadisticasGenerales() async {
    final db = await database;
    
    // Total de vehículos
    final vehiculosResult = await db.rawQuery('SELECT COUNT(*) as total FROM vehiculos');
    final totalVehiculos = vehiculosResult.first['total'] as int;
    
    // Total de mantenimientos completados
    final mantenimientosResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM mantenimientos WHERE status = ?',
      ['completed']
    );
    final totalMantenimientos = mantenimientosResult.first['total'] as int;
    
    // Total de gastos
    final gastosResult = await db.rawQuery(
      'SELECT SUM(costo) as total FROM mantenimientos WHERE status = ?',
      ['completed']
    );
    final totalGastos = gastosResult.first['total'] as double? ?? 0.0;
    
    // Kilometraje total
    final kilometrajeResult = await db.rawQuery('SELECT SUM(kilometraje) as total FROM vehiculos');
    final kilometrajeTotal = kilometrajeResult.first['total'] as int? ?? 0;
    
    return {
      'totalVehiculos': totalVehiculos,
      'totalMantenimientos': totalMantenimientos,
      'totalGastos': totalGastos,
      'kilometrajeTotal': kilometrajeTotal,
    };
  }

  // Actualizar kilometraje de un vehículo
  Future<void> updateVehiculoKilometraje(int vehiculoId, int nuevoKilometraje) async {
    final db = await database;
    await db.update(
      'vehiculos',
      {'kilometraje': nuevoKilometraje},
      where: 'id = ?',
      whereArgs: [vehiculoId],
    );
  }
}
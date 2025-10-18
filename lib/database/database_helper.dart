import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    String path = join(await getDatabasesPath(), 'bitacora_mantenimiento.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de vehículos
    await db.execute('''
      CREATE TABLE vehiculos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        ano TEXT NOT NULL,
        placa TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        kilometraje INTEGER NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'auto',
        estadoAceite INTEGER NOT NULL DEFAULT 100,
        estadoLlantas INTEGER NOT NULL DEFAULT 100,
        estadoFrenos INTEGER NOT NULL DEFAULT 100,
        estadoBateria INTEGER NOT NULL DEFAULT 100,
        proximoMantenimiento TEXT NOT NULL DEFAULT 'Sin mantenimientos programados',
        kmProximoMantenimiento INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabla de mantenimientos
    await db.execute('''
      CREATE TABLE mantenimientos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehiculo_id INTEGER NOT NULL,
        fecha INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        costo REAL NOT NULL,
        kilometraje INTEGER NOT NULL,
        taller TEXT NOT NULL,
        notas TEXT,
        FOREIGN KEY (vehiculo_id) REFERENCES vehiculos (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar nuevas columnas a la tabla vehiculos
      await db.execute('ALTER TABLE vehiculos ADD COLUMN tipo TEXT NOT NULL DEFAULT "auto"');
      await db.execute('ALTER TABLE vehiculos ADD COLUMN estadoAceite INTEGER NOT NULL DEFAULT 100');
      await db.execute('ALTER TABLE vehiculos ADD COLUMN estadoLlantas INTEGER NOT NULL DEFAULT 100');
      await db.execute('ALTER TABLE vehiculos ADD COLUMN estadoFrenos INTEGER NOT NULL DEFAULT 100');
      await db.execute('ALTER TABLE vehiculos ADD COLUMN estadoBateria INTEGER NOT NULL DEFAULT 100');
      await db.execute('ALTER TABLE vehiculos ADD COLUMN proximoMantenimiento TEXT NOT NULL DEFAULT "Sin mantenimientos programados"');
      await db.execute('ALTER TABLE vehiculos ADD COLUMN kmProximoMantenimiento INTEGER NOT NULL DEFAULT 0');
    }
  }

  // Métodos para vehículos
  Future<int> insertVehiculo(Vehiculo vehiculo) async {
    final db = await database;
    return await db.insert('vehiculos', vehiculo.toMap());
  }

  Future<List<Vehiculo>> getVehiculos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vehiculos');
    return List.generate(maps.length, (i) {
      return Vehiculo.fromMap(maps[i]);
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
      return Vehiculo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateVehiculo(Vehiculo vehiculo) async {
    final db = await database;
    return await db.update(
      'vehiculos',
      vehiculo.toMap(),
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
      where: 'vehiculo_id = ?',
      whereArgs: [vehiculoId],
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) {
      return Mantenimiento.fromMap(maps[i]);
    });
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

  Future<int> updateMantenimiento(Mantenimiento mantenimiento) async {
    final db = await database;
    return await db.update(
      'mantenimientos',
      mantenimiento.toMap(),
      where: 'id = ?',
      whereArgs: [mantenimiento.id],
    );
  }

  Future<int> deleteMantenimiento(int id) async {
    final db = await database;
    return await db.delete(
      'mantenimientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

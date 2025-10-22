import '../database/database_helper.dart';
import '../models/licencia_conductor.dart';

class LicenciaService {
  // Crear tabla de licencias
  static Future<void> createTable() async {
    final db = await DatabaseHelper().database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS licencias_conductor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numeroLicencia TEXT NOT NULL UNIQUE,
        categoria TEXT NOT NULL,
        fechaExpedicion TEXT NOT NULL,
        fechaVencimiento TEXT NOT NULL,
        organismoExpedidor TEXT NOT NULL,
        restricciones TEXT,
        notas TEXT,
        fechaCreacion TEXT NOT NULL
      )
    ''');
  }

  // Insertar licencia
  static Future<int> insertLicencia(LicenciaConductor licencia) async {
    final db = await DatabaseHelper().database;
    return await db.insert('licencias_conductor', licencia.toMap());
  }

  // Obtener todas las licencias
  static Future<List<LicenciaConductor>> getLicencias() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('licencias_conductor');
    return List.generate(maps.length, (i) {
      return LicenciaConductor.fromMap(maps[i]);
    });
  }

  // Obtener licencia por ID
  static Future<LicenciaConductor?> getLicenciaById(int id) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'licencias_conductor',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return LicenciaConductor.fromMap(maps.first);
    }
    return null;
  }

  // Obtener licencia por número
  static Future<LicenciaConductor?> getLicenciaByNumero(String numero) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'licencias_conductor',
      where: 'numeroLicencia = ?',
      whereArgs: [numero],
    );
    if (maps.isNotEmpty) {
      return LicenciaConductor.fromMap(maps.first);
    }
    return null;
  }

  // Actualizar licencia
  static Future<int> updateLicencia(LicenciaConductor licencia) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'licencias_conductor',
      licencia.toMap(),
      where: 'id = ?',
      whereArgs: [licencia.id],
    );
  }

  // Eliminar licencia
  static Future<int> deleteLicencia(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete(
      'licencias_conductor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener licencias próximas a vencer
  static Future<List<LicenciaConductor>> getLicenciasProximasAVencer() async {
    final db = await DatabaseHelper().database;
    final hoy = DateTime.now();
    final proximoMes = DateTime(hoy.year, hoy.month + 1, hoy.day);

    final List<Map<String, dynamic>> maps = await db.query(
      'licencias_conductor',
      where: 'fechaVencimiento BETWEEN ? AND ?',
      whereArgs: [
        hoy.toIso8601String().split('T')[0],
        proximoMes.toIso8601String().split('T')[0],
      ],
    );

    return List.generate(maps.length, (i) {
      return LicenciaConductor.fromMap(maps[i]);
    });
  }

  // Obtener licencias vencidas
  static Future<List<LicenciaConductor>> getLicenciasVencidas() async {
    final db = await DatabaseHelper().database;
    final hoy = DateTime.now().toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'licencias_conductor',
      where: 'fechaVencimiento < ?',
      whereArgs: [hoy],
    );

    return List.generate(maps.length, (i) {
      return LicenciaConductor.fromMap(maps[i]);
    });
  }

  // Obtener licencia vigente (la más reciente)
  static Future<LicenciaConductor?> getLicenciaVigente() async {
    final db = await DatabaseHelper().database;
    final hoy = DateTime.now().toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'licencias_conductor',
      where: 'fechaVencimiento >= ?',
      whereArgs: [hoy],
      orderBy: 'fechaExpedicion DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return LicenciaConductor.fromMap(maps.first);
    }
    return null;
  }

  // Verificar si existe una licencia con el mismo número
  static Future<bool> existeLicencia(String numeroLicencia) async {
    final licencia = await getLicenciaByNumero(numeroLicencia);
    return licencia != null;
  }

  // Obtener estadísticas de licencias
  static Future<Map<String, int>> getEstadisticasLicencias() async {
    final licencias = await getLicencias();
    final hoy = DateTime.now();
    
    int vigentes = 0;
    int proximasAVencer = 0;
    int vencidas = 0;

    for (final licencia in licencias) {
      final fechaVenc = DateTime.parse(licencia.fechaVencimiento);
      final diasRestantes = fechaVenc.difference(hoy).inDays;
      
      if (diasRestantes < 0) {
        vencidas++;
      } else if (diasRestantes <= 30) {
        proximasAVencer++;
      } else {
        vigentes++;
      }
    }

    return {
      'total': licencias.length,
      'vigentes': vigentes,
      'proximasAVencer': proximasAVencer,
      'vencidas': vencidas,
    };
  }
}

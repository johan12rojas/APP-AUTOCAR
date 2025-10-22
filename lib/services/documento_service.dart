import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/documento_vehiculo.dart';
import '../database/database_helper.dart';

class DocumentoService {
  static final ImagePicker _picker = ImagePicker();

  // Crear tabla de documentos si no existe
  static Future<void> createTable() async {
    final db = await DatabaseHelper().database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS documentos_vehiculo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehiculoId INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        nombreArchivo TEXT NOT NULL,
        rutaArchivo TEXT NOT NULL,
        fechaEmision TEXT NOT NULL,
        fechaVencimiento TEXT NOT NULL,
        notas TEXT,
        fechaCreacion TEXT NOT NULL,
        FOREIGN KEY (vehiculoId) REFERENCES vehiculos (id)
      )
    ''');
  }

  // Insertar documento
  static Future<int> insertDocumento(DocumentoVehiculo documento) async {
    final db = await DatabaseHelper().database;
    
    // Si no se especifica fecha de vencimiento, calcular automáticamente (1 año después)
    if (documento.fechaVencimiento.isEmpty) {
      final fechaEmision = DateTime.parse(documento.fechaEmision);
      final fechaVencimiento = DateTime(fechaEmision.year + 1, fechaEmision.month, fechaEmision.day);
      documento = documento.copyWith(fechaVencimiento: fechaVencimiento.toIso8601String().split('T')[0]);
    }
    
    return await db.insert('documentos_vehiculo', documento.toMap());
  }

  // Obtener documentos por vehículo
  static Future<List<DocumentoVehiculo>> getDocumentosByVehiculo(int vehiculoId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documentos_vehiculo',
      where: 'vehiculoId = ?',
      whereArgs: [vehiculoId],
      orderBy: 'fechaVencimiento ASC',
    );

    return List.generate(maps.length, (i) {
      return DocumentoVehiculo.fromMap(maps[i]);
    });
  }

  // Obtener documento por ID
  static Future<DocumentoVehiculo?> getDocumentoById(int id) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documentos_vehiculo',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DocumentoVehiculo.fromMap(maps.first);
    }
    return null;
  }

  // Actualizar documento
  static Future<int> updateDocumento(DocumentoVehiculo documento) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'documentos_vehiculo',
      documento.toMap(),
      where: 'id = ?',
      whereArgs: [documento.id],
    );
  }

  // Eliminar documento
  static Future<int> deleteDocumento(int id) async {
    final db = await DatabaseHelper().database;
    
    // Obtener el documento para eliminar el archivo
    final documento = await getDocumentoById(id);
    if (documento != null) {
      try {
        final file = File(documento.rutaArchivo);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error al eliminar archivo: $e');
      }
    }
    
    return await db.delete(
      'documentos_vehiculo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener alertas de documentos próximos a vencer
  static Future<List<DocumentoVehiculo>> getAlertasDocumentos() async {
    final db = await DatabaseHelper().database;
    final hoy = DateTime.now();
    final proximoMes = DateTime(hoy.year, hoy.month + 1, hoy.day);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'documentos_vehiculo',
      where: 'fechaVencimiento BETWEEN ? AND ?',
      whereArgs: [
        hoy.toIso8601String().split('T')[0],
        proximoMes.toIso8601String().split('T')[0],
      ],
    );
    
    return List.generate(maps.length, (i) {
      return DocumentoVehiculo.fromMap(maps[i]);
    });
  }


  // Seleccionar imagen desde galería
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
    }
    return null;
  }

  // Seleccionar imagen desde cámara
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print('Error al tomar foto: $e');
    }
    return null;
  }

  // Guardar imagen en directorio de documentos
  static Future<String> saveDocumentImage(File imageFile, int vehiculoId, String tipo) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final documentosDir = Directory(path.join(directory.path, 'documentos_vehiculos'));
      
      if (!await documentosDir.exists()) {
        await documentosDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = '${tipo}_${vehiculoId}_$timestamp$extension';
      final filePath = path.join(documentosDir.path, fileName);

      // Verificar que el archivo existe antes de copiarlo
      if (await imageFile.exists()) {
        await imageFile.copy(filePath);
        return filePath;
      } else {
        throw Exception('El archivo de imagen no existe: ${imageFile.path}');
      }
    } catch (e) {
      print('Error al guardar imagen: $e');
      rethrow;
    }
  }

  // Obtener documentos próximos a vencer (30 días)
  static Future<List<DocumentoVehiculo>> getDocumentosProximosAVencer() async {
    final db = await DatabaseHelper().database;
    final fechaLimite = DateTime.now().add(const Duration(days: 30));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'documentos_vehiculo',
      where: 'fechaVencimiento <= ? AND fechaVencimiento >= ?',
      whereArgs: [
        fechaLimite.toIso8601String(),
        DateTime.now().toIso8601String(),
      ],
      orderBy: 'fechaVencimiento ASC',
    );

    return List.generate(maps.length, (i) {
      return DocumentoVehiculo.fromMap(maps[i]);
    });
  }

  // Obtener documentos vencidos
  static Future<List<DocumentoVehiculo>> getDocumentosVencidos() async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'documentos_vehiculo',
      where: 'fechaVencimiento < ?',
      whereArgs: [DateTime.now().toIso8601String()],
      orderBy: 'fechaVencimiento ASC',
    );

    return List.generate(maps.length, (i) {
      return DocumentoVehiculo.fromMap(maps[i]);
    });
  }

  // Obtener estadísticas de documentos por vehículo
  static Future<Map<String, int>> getEstadisticasDocumentos(int vehiculoId) async {
    final documentos = await getDocumentosByVehiculo(vehiculoId);
    
    int vencidos = 0;
    int proximosAVencer = 0;
    int vigentes = 0;

    for (final documento in documentos) {
      switch (documento.estado) {
        case 'vencido':
          vencidos++;
          break;
        case 'proximo_vencer':
          proximosAVencer++;
          break;
        case 'vigente':
          vigentes++;
          break;
      }
    }

    return {
      'vencidos': vencidos,
      'proximos_vencer': proximosAVencer,
      'vigentes': vigentes,
      'total': documentos.length,
    };
  }

  // Verificar si un vehículo tiene documentos vencidos o próximos a vencer
  static Future<bool> tieneDocumentosConAlerta(int vehiculoId) async {
    final documentos = await getDocumentosByVehiculo(vehiculoId);
    
    for (final documento in documentos) {
      if (documento.vencido || documento.proximoAVencer) {
        return true;
      }
    }
    
    return false;
  }
}

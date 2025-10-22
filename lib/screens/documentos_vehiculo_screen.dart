import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';
import '../models/vehiculo.dart';
import '../models/documento_vehiculo.dart';
import '../services/documento_service.dart';
import '../services/pdf_export_service.dart';

class DocumentosVehiculoScreen extends StatefulWidget {
  final Vehiculo vehiculo;

  const DocumentosVehiculoScreen({
    super.key,
    required this.vehiculo,
  });

  @override
  State<DocumentosVehiculoScreen> createState() => _DocumentosVehiculoScreenState();
}

class _DocumentosVehiculoScreenState extends State<DocumentosVehiculoScreen> {
  List<DocumentoVehiculo> _documentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocumentos();
  }

  Future<void> _loadDocumentos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final documentos = await DocumentoService.getDocumentosByVehiculo(widget.vehiculo.id!);
      setState(() {
        _documentos = documentos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error al cargar documentos: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(Icons.error, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C2C2C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C2C2C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _agregarDocumento(String tipo) async {
    try {
      if (tipo == 'propiedad') {
        // Para documentos de propiedad, necesitamos dos fotos
        await _agregarDocumentoPropiedad();
      } else {
        // Para otros documentos, solo una foto
        await _agregarDocumentoSimple(tipo);
      }
    } catch (e) {
      _showErrorSnackBar('Error al agregar documento: $e');
    }
  }

  Future<void> _agregarDocumentoSimple(String tipo) async {
    // Mostrar opciones de selección
    final source = await _showImageSourceDialog();
    if (source == null) return;

    File? imageFile;
    if (source == 'camera') {
      imageFile = await DocumentoService.pickImageFromCamera();
    } else {
      imageFile = await DocumentoService.pickImageFromGallery();
    }

    if (imageFile == null) return;

    // Mostrar formulario para completar datos
    final documento = await _showDocumentoForm(tipo, imageFile);
    if (documento != null) {
      await DocumentoService.insertDocumento(documento);
      _showSuccessSnackBar('Documento agregado correctamente');
      _loadDocumentos();
    }
  }

  Future<void> _agregarDocumentoPropiedad() async {
    // Primera foto (frontal)
    final source1 = await _showImageSourceDialog('Seleccionar foto frontal');
    if (source1 == null) return;

    File? imageFile1;
    if (source1 == 'camera') {
      imageFile1 = await DocumentoService.pickImageFromCamera();
    } else {
      imageFile1 = await DocumentoService.pickImageFromGallery();
    }

    if (imageFile1 == null) return;

    // Segunda foto (trasera)
    final source2 = await _showImageSourceDialog('Seleccionar foto trasera');
    if (source2 == null) return;

    File? imageFile2;
    if (source2 == 'camera') {
      imageFile2 = await DocumentoService.pickImageFromCamera();
    } else {
      imageFile2 = await DocumentoService.pickImageFromGallery();
    }

    if (imageFile2 == null) return;

    // Mostrar formulario para completar datos
    final documento = await _showDocumentoFormPropiedad(imageFile1, imageFile2);
    if (documento != null) {
      await DocumentoService.insertDocumento(documento);
      _showSuccessSnackBar('Documento de propiedad agregado correctamente');
      _loadDocumentos();
    }
  }

  Future<String?> _showImageSourceDialog([String? title]) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AutocarTheme.darkBackground,
          title: Text(
            title ?? 'Seleccionar Imagen',
            style: const TextStyle(color: AutocarTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AutocarTheme.textPrimary),
                title: const Text(
                  'Cámara',
                  style: TextStyle(color: AutocarTheme.textPrimary),
                ),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AutocarTheme.textPrimary),
                title: const Text(
                  'Galería',
                  style: TextStyle(color: AutocarTheme.textPrimary),
                ),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<DocumentoVehiculo?> _showDocumentoForm(String tipo, File imageFile) async {
    final fechaEmisionController = TextEditingController();
    final fechaVencimientoController = TextEditingController();
    final notasController = TextEditingController();

    return showDialog<DocumentoVehiculo>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AutocarTheme.darkBackground,
          title: Text(
            'Agregar ${tipo == 'tecnomecanica' ? 'Tecnomecánica' : tipo == 'seguro' ? 'Seguro' : 'Propiedad'}',
            style: const TextStyle(color: AutocarTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fechaEmisionController,
                  style: const TextStyle(color: AutocarTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Emisión',
                    labelStyle: TextStyle(color: AutocarTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.textSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.primaryBlue),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      fechaEmisionController.text = '${date.day}/${date.month}/${date.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fechaVencimientoController,
                  style: const TextStyle(color: AutocarTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Vencimiento',
                    labelStyle: TextStyle(color: AutocarTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.textSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.primaryBlue),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 2000)),
                    );
                    if (date != null) {
                      fechaVencimientoController.text = '${date.day}/${date.month}/${date.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notasController,
                  style: const TextStyle(color: AutocarTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    labelStyle: TextStyle(color: AutocarTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.textSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.primaryBlue),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AutocarTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (fechaEmisionController.text.isEmpty || fechaVencimientoController.text.isEmpty) {
                  _showErrorSnackBar('Por favor complete todos los campos requeridos');
                  return;
                }

                try {
                  // Parsear fechas
                  final fechaEmisionParts = fechaEmisionController.text.split('/');
                  final fechaVencimientoParts = fechaVencimientoController.text.split('/');
                  
                  final fechaEmision = DateTime(
                    int.parse(fechaEmisionParts[2]),
                    int.parse(fechaEmisionParts[1]),
                    int.parse(fechaEmisionParts[0]),
                  );
                  
                  final fechaVencimiento = DateTime(
                    int.parse(fechaVencimientoParts[2]),
                    int.parse(fechaVencimientoParts[1]),
                    int.parse(fechaVencimientoParts[0]),
                  );

                  // Guardar imagen
                  final rutaArchivo = await DocumentoService.saveDocumentImage(
                    imageFile,
                    widget.vehiculo.id!,
                    tipo,
                  );

                  final documento = DocumentoVehiculo(
                    vehiculoId: widget.vehiculo.id!,
                    tipo: tipo,
                    nombreArchivo: imageFile.path.split('/').last,
                    rutaArchivo: rutaArchivo,
                    fechaEmision: fechaEmision.toIso8601String().split('T')[0],
                    fechaVencimiento: fechaVencimiento.toIso8601String().split('T')[0],
                    notas: notasController.text.isNotEmpty ? notasController.text : null,
                    fechaCreacion: DateTime.now(),
                  );

                  Navigator.of(context).pop(documento);
                } catch (e) {
                  _showErrorSnackBar('Error al procesar fechas: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AutocarTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<DocumentoVehiculo?> _showDocumentoFormPropiedad(File imageFile1, File imageFile2) async {
    final fechaEmisionController = TextEditingController();
    final fechaVencimientoController = TextEditingController();
    final notasController = TextEditingController();

    return showDialog<DocumentoVehiculo>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AutocarTheme.darkBackground,
          title: const Text(
            'Agregar Propiedad',
            style: TextStyle(color: AutocarTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mostrar preview de las dos fotos
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Foto Frontal',
                            style: TextStyle(color: AutocarTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AutocarTheme.textSecondary),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                imageFile1,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Foto Trasera',
                            style: TextStyle(color: AutocarTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AutocarTheme.textSecondary),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                imageFile2,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: fechaEmisionController,
                  style: const TextStyle(color: AutocarTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Emisión',
                    labelStyle: TextStyle(color: AutocarTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.textSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.primaryBlue),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      fechaEmisionController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fechaVencimientoController,
                  style: const TextStyle(color: AutocarTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Vencimiento',
                    labelStyle: TextStyle(color: AutocarTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.textSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.primaryBlue),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (date != null) {
                      fechaVencimientoController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notasController,
                  style: const TextStyle(color: AutocarTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    labelStyle: TextStyle(color: AutocarTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.textSecondary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AutocarTheme.primaryBlue),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AutocarTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (fechaEmisionController.text.isEmpty || fechaVencimientoController.text.isEmpty) {
                  _showErrorSnackBar('Por favor complete todas las fechas');
                  return;
                }

                try {
                  // Parsear fechas
                  final fechaEmisionParts = fechaEmisionController.text.split('/');
                  final fechaVencimientoParts = fechaVencimientoController.text.split('/');
                  
                  final fechaEmision = DateTime(
                    int.parse(fechaEmisionParts[2]),
                    int.parse(fechaEmisionParts[1]),
                    int.parse(fechaEmisionParts[0]),
                  );
                  
                  final fechaVencimiento = DateTime(
                    int.parse(fechaVencimientoParts[2]),
                    int.parse(fechaVencimientoParts[1]),
                    int.parse(fechaVencimientoParts[0]),
                  );

                  // Guardar ambas imágenes
                  final rutaArchivo1 = await DocumentoService.saveDocumentImage(
                    imageFile1,
                    widget.vehiculo.id!,
                    'propiedad_frontal',
                  );

                  final rutaArchivo2 = await DocumentoService.saveDocumentImage(
                    imageFile2,
                    widget.vehiculo.id!,
                    'propiedad_trasera',
                  );

                  final documento = DocumentoVehiculo(
                    vehiculoId: widget.vehiculo.id!,
                    tipo: 'propiedad',
                    nombreArchivo: 'propiedad_${imageFile1.path.split('/').last}',
                    rutaArchivo: rutaArchivo1,
                    rutaArchivoAdicional: rutaArchivo2,
                    fechaEmision: fechaEmision.toIso8601String().split('T')[0],
                    fechaVencimiento: fechaVencimiento.toIso8601String().split('T')[0],
                    notas: notasController.text.isNotEmpty ? notasController.text : null,
                    fechaCreacion: DateTime.now(),
                  );

                  Navigator.of(context).pop(documento);
                } catch (e) {
                  _showErrorSnackBar('Error al procesar fechas: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AutocarTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarDocumento(DocumentoVehiculo documento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AutocarTheme.darkBackground,
          title: const Text(
            'Eliminar Documento',
            style: TextStyle(color: AutocarTheme.textPrimary),
          ),
          content: Text(
            '¿Está seguro de que desea eliminar este documento?',
            style: const TextStyle(color: AutocarTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AutocarTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await DocumentoService.deleteDocumento(documento.id!);
        _showSuccessSnackBar('Documento eliminado correctamente');
        _loadDocumentos();
      } catch (e) {
        _showErrorSnackBar('Error al eliminar documento: $e');
      }
    }
  }

  // Exportar documentos a PDF
  Future<void> _exportarDocumentosPDF() async {
    try {
      await PdfExportService.exportDocumentosPDF(widget.vehiculo, _documentos);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.greenAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Icon(Icons.download, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Documentos exportados exitosamente',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2C2C2C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Icon(Icons.error, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al exportar: $e',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2C2C2C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AutocarTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          'Documentos - ${widget.vehiculo.marca} ${widget.vehiculo.modelo}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_documentos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: _exportarDocumentosPDF,
              tooltip: 'Exportar PDF',
            ),
        ],
      ),
      body: BackgroundGradientWidget(
        child: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AutocarTheme.primaryBlue),
                ),
              )
            else
              Column(
                children: [
                // Botones para agregar documentos
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: AutocarTheme.primaryBlue.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _agregarDocumento('tecnomecanica'),
                                icon: const Icon(Icons.build, color: Colors.white),
                                label: const Text('Tecno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _agregarDocumento('seguro'),
                                icon: const Icon(Icons.security, color: Colors.white),
                                label: const Text('Seguro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE65100), Color(0xFFBF360C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _agregarDocumento('propiedad'),
                          icon: const Icon(Icons.description, color: Colors.white),
                          label: const Text('Propiedad del Vehículo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lista de documentos
                Expanded(
                  child: _documentos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 64,
                                color: AutocarTheme.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay documentos registrados',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AutocarTheme.textSecondary.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Agrega documentos usando los botones de arriba',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AutocarTheme.textSecondary.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _documentos.length,
                          itemBuilder: (context, index) {
                            final documento = _documentos[index];
                            return _buildDocumentoCard(documento);
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentoCard(DocumentoVehiculo documento) {
    Color estadoColor;
    String estadoText;
    
    switch (documento.estado) {
      case 'vencido':
        estadoColor = Colors.red;
        estadoText = 'Vencido';
        break;
      case 'proximo_vencer':
        estadoColor = Colors.orange;
        estadoText = 'Próximo a vencer';
        break;
      default:
        estadoColor = Colors.green;
        estadoText = 'Vigente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estadoColor.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: estadoColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: estadoColor, width: 2),
          ),
          child: Center(
            child: Text(
              documento.icono,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          documento.tipoDisplayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Vence: ${documento.fechaVencimiento}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: estadoColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                estadoText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'delete') {
              _eliminarDocumento(documento);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Mostrar imagen del documento
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AutocarTheme.darkBackground,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              documento.tipoDisplayName,
                              style: const TextStyle(
                                color: AutocarTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close, color: AutocarTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(documento.rutaArchivo),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

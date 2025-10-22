import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../models/documento_vehiculo.dart';

class PdfExportService {
  static String _getVehicleTypeDescription(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'carro':
        return 'Carro';
      case 'sedan':
        return 'Sedán';
      case 'hatchback':
        return 'Hatchback';
      case 'suv':
        return 'SUV';
      case 'moto':
        return 'Motocicleta';
      default:
        return tipo;
    }
  }

  static Future<void> exportVehiculosToPdf(
    BuildContext context,
    List<Vehiculo> vehiculos,
    List<Mantenimiento> mantenimientos,
  ) async {
    try {
      final pdf = pw.Document();
      
      // Cargar imágenes necesarias
      final logoImage = await _loadImageFromAssets('assets/images/logos/icon_app_small.png');
      final carIcon = await _loadImageFromAssets('assets/images/icons/car_icon.png');
      final motoIcon = await _loadImageFromAssets('assets/images/icons/moto_icon.png');
      final maintenanceIcon = await _loadImageFromAssets('assets/images/icons/maintenance_icon.png');
      final batteryIcon = await _loadImageFromAssets('assets/images/icons/battery_icon.png');
      final brakeIcon = await _loadImageFromAssets('assets/images/icons/brake_icon.png');
      final oilIcon = await _loadImageFromAssets('assets/images/icons/oil_icon.png');
      final tireIcon = await _loadImageFromAssets('assets/images/icons/tire_icon.png');
      
      // PÁGINA 1: Resumen Ejecutivo
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              // Encabezado mejorado con logo
              _buildHeader(logoImage),
              
              pw.SizedBox(height: 20),
              
              // Resumen general con estadísticas (reorganizado)
              _buildSummarySection(vehiculos, mantenimientos, carIcon, maintenanceIcon),
              
              pw.SizedBox(height: 20),
              
              // Gráfico de barras para mantenimientos mensuales
              _buildMonthlyChart(mantenimientos),
              
              pw.SizedBox(height: 20),
              
              // Análisis de costos
              _buildCostAnalysis(mantenimientos),
              
              pw.SizedBox(height: 20),
              
              // Pie de página corporativo
              _buildFooter(),
            ];
          },
        ),
      );

      // PÁGINA 2: Vehículos Registrados
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              // Encabezado
              _buildHeader(logoImage),
              
              pw.SizedBox(height: 20),
              
              // Tabla de vehículos con imágenes reales
              _buildVehiclesSection(vehiculos, carIcon, motoIcon),
              
              pw.SizedBox(height: 20),
              
              // Pie de página
              _buildFooter(),
            ];
          },
        ),
      );

      // PÁGINA 3: Historial de Mantenimientos
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              // Encabezado
              _buildHeader(logoImage),
              
              pw.SizedBox(height: 20),
              
              // Tabla de mantenimientos con iconos
              _buildMaintenancesSection(mantenimientos, oilIcon, tireIcon, brakeIcon, batteryIcon, maintenanceIcon),
              
              pw.SizedBox(height: 20),
              
              // Pie de página
              _buildFooter(),
            ];
          },
        ),
      );

      // Mostrar diálogo de impresión/guardado
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Reporte_Vehiculos_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Cargar imagen desde assets
  static Future<pw.MemoryImage> _loadImageFromAssets(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      // Si no se puede cargar la imagen, crear una imagen placeholder
      return _createPlaceholderImage();
    }
  }

  // Crear imagen placeholder en caso de error
  static pw.MemoryImage _createPlaceholderImage() {
    // Crear una imagen simple de 1x1 pixel transparente
    final bytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
    return pw.MemoryImage(bytes);
  }

  // Cargar imagen de vehículo personalizada o por defecto
  static Future<pw.MemoryImage> _loadVehicleImage(Vehiculo vehiculo) async {
    // Intentar cargar imagen personalizada primero
    if (vehiculo.imagenPersonalizada != null && vehiculo.imagenPersonalizada!.isNotEmpty) {
      try {
        final file = File(vehiculo.imagenPersonalizada!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return pw.MemoryImage(bytes);
        }
      } catch (e) {
        print('Error loading personalized vehicle image: $e');
      }
    }
    
    // Si no hay imagen personalizada, usar imagen por defecto según el tipo
    try {
      if (vehiculo.tipo.contains('moto')) {
        return await _loadImageFromAssets('assets/images/vehicles/motorcycle_default.png');
      } else {
        return await _loadImageFromAssets('assets/images/vehicles/car_default.png');
      }
    } catch (e) {
      print('Error loading default vehicle image: $e');
      return _createPlaceholderImage();
    }
  }

  // Encabezado con logo
  static pw.Widget _buildHeader(pw.MemoryImage logoImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blue600, PdfColors.blue800],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        children: [
          pw.Image(logoImage, width: 60, height: 60),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AUTOCAR GPS',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  'Sistema de Gestión de Vehículos',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  'Versión 1.0.0',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                'Hora: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Resumen con iconos
  static pw.Widget _buildSummarySection(
    List<Vehiculo> vehiculos,
    List<Mantenimiento> mantenimientos,
    pw.MemoryImage carIcon,
    pw.MemoryImage maintenanceIcon,
  ) {
    final completedMaintenances = mantenimientos.where((m) => m.status == 'completed').length;
    final pendingMaintenances = mantenimientos.where((m) => m.status == 'pending').length;
    final urgentMaintenances = mantenimientos.where((m) => m.status == 'urgent').length;
    final totalCost = mantenimientos.fold<double>(0, (sum, m) => sum + m.costo);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESUMEN EJECUTIVO',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Column(
            children: [
              // Primera fila: estadísticas principales
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('VEHÍCULOS', vehiculos.length.toString(), PdfColors.blue600, carIcon),
                  _buildSummaryCard('MANTENIMIENTOS', mantenimientos.length.toString(), PdfColors.green600, maintenanceIcon),
                  _buildSummaryCard('COMPLETADOS', completedMaintenances.toString(), PdfColors.green700, maintenanceIcon),
                  _buildSummaryCard('PENDIENTES', pendingMaintenances.toString(), PdfColors.orange600, maintenanceIcon),
                  _buildSummaryCard('URGENTES', urgentMaintenances.toString(), PdfColors.red600, maintenanceIcon),
                ],
              ),
              pw.SizedBox(height: 16),
              // Segunda fila: costo total centrado
              pw.Center(
                child: _buildSummaryCard('COSTO TOTAL', '\$${totalCost.toStringAsFixed(0)}', PdfColors.purple600, maintenanceIcon),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tarjeta de resumen con icono
  static pw.Widget _buildSummaryCard(String label, String value, PdfColor color, pw.MemoryImage icon) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 2),
      ),
      child: pw.Column(
        children: [
          pw.Image(icon, width: 24, height: 24),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Gráfico de barras mensual
  static pw.Widget _buildMonthlyChart(List<Mantenimiento> mantenimientos) {
    final Map<int, int> monthlyData = {};
    for (var mantenimiento in mantenimientos) {
      final month = mantenimiento.fecha.month;
      monthlyData[month] = (monthlyData[month] ?? 0) + 1;
    }

    final maxValue = monthlyData.values.isNotEmpty ? monthlyData.values.reduce((a, b) => a > b ? a : b) : 1;
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MANTENIMIENTOS POR MES',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: months.asMap().entries.map((entry) {
              final index = entry.key;
              final month = entry.value;
              final value = monthlyData[index + 1] ?? 0;
              final height = (value / maxValue) * 100;

              return pw.Column(
                children: [
                  pw.Container(
                    width: 20,
                    height: height,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue400,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    month,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    value.toString(),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Análisis de costos
  static pw.Widget _buildCostAnalysis(List<Mantenimiento> mantenimientos) {
    final totalCost = mantenimientos.fold<double>(0, (sum, m) => sum + m.costo);
    final averageCost = mantenimientos.isNotEmpty ? totalCost / mantenimientos.length : 0;
    final completedCost = mantenimientos
        .where((m) => m.status == 'completed')
        .fold<double>(0, (sum, m) => sum + m.costo);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ANÁLISIS DE COSTOS',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    'Costo Total',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    '\$${totalCost.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red600,
                    ),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Costo Promedio',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    '\$${averageCost.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange600,
                    ),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Costo Completado',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    '\$${completedCost.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tabla de vehículos con imágenes
  static pw.Widget _buildVehiclesSection(
    List<Vehiculo> vehiculos,
    pw.MemoryImage carIcon,
    pw.MemoryImage motoIcon,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'VEHÍCULOS REGISTRADOS',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 12),
        
        // Verificar si hay vehículos
        if (vehiculos.isEmpty) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Center(
              child: pw.Text(
                'No hay vehículos registrados',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ),
        ] else ...[
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(1), // Imagen
            1: const pw.FlexColumnWidth(2), // Marca/Modelo
            2: const pw.FlexColumnWidth(1), // Año
            3: const pw.FlexColumnWidth(1), // Tipo
            4: const pw.FlexColumnWidth(1.5), // Placa
            5: const pw.FlexColumnWidth(1.5), // Kilometraje
          },
          children: [
            // Encabezados
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Imagen', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Marca/Modelo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Año', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Placa', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Kilometraje', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ),
              ],
            ),
            // Datos de vehículos
            ...vehiculos.map((vehiculo) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Image(
                    vehiculo.tipo.contains('moto') ? motoIcon : carIcon,
                    width: 40,
                    height: 40,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('${vehiculo.marca} ${vehiculo.modelo}'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text(vehiculo.ano.toString()),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text(_getVehicleTypeDescription(vehiculo.tipo)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text(vehiculo.placa),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('${vehiculo.kilometraje} km'),
                ),
              ],
            )),
          ],
        ),
        ],
      ],
    );
  }

  // Tabla de mantenimientos con iconos
  static pw.Widget _buildMaintenancesSection(
    List<Mantenimiento> mantenimientos,
    pw.MemoryImage oilIcon,
    pw.MemoryImage tireIcon,
    pw.MemoryImage brakeIcon,
    pw.MemoryImage batteryIcon,
    pw.MemoryImage maintenanceIcon,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HISTORIAL DE MANTENIMIENTOS',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(1), // Icono
            1: const pw.FlexColumnWidth(2), // Tipo
            2: const pw.FlexColumnWidth(1.5), // Fecha
            3: const pw.FlexColumnWidth(1), // Kilometraje
            4: const pw.FlexColumnWidth(1), // Costo
            5: const pw.FlexColumnWidth(1.5), // Estado
          },
          children: [
            // Encabezados
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.green100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Descripción', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Fecha', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Kilometraje', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Costo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text('Estado', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ),
              ],
            ),
            // Datos de mantenimientos
            ...mantenimientos.map((mantenimiento) {
              final icon = _getMaintenanceIcon(mantenimiento.tipo, oilIcon, tireIcon, brakeIcon, batteryIcon, maintenanceIcon);
              final statusColor = _getStatusColor(mantenimiento.status);
              
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Image(icon, width: 24, height: 24),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Text(_getMaintenanceTypeName(mantenimiento.tipo)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Text('${mantenimiento.fecha.day}/${mantenimiento.fecha.month}/${mantenimiento.fecha.year}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Text('${mantenimiento.kilometraje} km'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Text('\$${mantenimiento.costo.toStringAsFixed(0)}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: statusColor,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        _getStatusText(mantenimiento.status),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  // Obtener icono según tipo de mantenimiento
  static pw.MemoryImage _getMaintenanceIcon(
    String tipo,
    pw.MemoryImage oilIcon,
    pw.MemoryImage tireIcon,
    pw.MemoryImage brakeIcon,
    pw.MemoryImage batteryIcon,
    pw.MemoryImage maintenanceIcon,
  ) {
    switch (tipo.toLowerCase()) {
      case 'oil':
        return oilIcon;
      case 'tires':
        return tireIcon;
      case 'brakes':
        return brakeIcon;
      case 'battery':
        return batteryIcon;
      default:
        return maintenanceIcon;
    }
  }

  // Obtener nombre del tipo de mantenimiento
  static String _getMaintenanceTypeName(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'oil':
        return 'Cambio de Aceite';
      case 'tires':
        return 'Llantas';
      case 'brakes':
        return 'Frenos';
      case 'battery':
        return 'Batería';
      case 'coolant':
        return 'Refrigerante';
      case 'airfilter':
        return 'Filtro de Aire';
      case 'alignment':
        return 'Alineación';
      case 'chain':
        return 'Cadena/Kit Arrastre';
      case 'sparkplug':
        return 'Bujía';
      default:
        return tipo;
    }
  }

  // Obtener color según estado
  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PdfColors.green600;
      case 'pending':
        return PdfColors.orange600;
      case 'urgent':
        return PdfColors.red600;
      default:
        return PdfColors.grey600;
    }
  }

  // Obtener texto del estado
  static String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completado';
      case 'pending':
        return 'Pendiente';
      case 'urgent':
        return 'Urgente';
      default:
        return status;
    }
  }

  // Pie de página
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generado por AUTOCAR GPS',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Página 1 de 1',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // Exportar documentos de vehículo a PDF
  static Future<void> exportDocumentosPDF(Vehiculo vehiculo, List<DocumentoVehiculo> documentos) async {
    final pdf = pw.Document();
    
    // Cargar imágenes
    final logoImage = await _loadImageFromAssets('assets/images/logos/icon_app_small.png');
    
    // Página principal
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildDocumentosHeader(logoImage, vehiculo),
            pw.SizedBox(height: 20),
            _buildDocumentosSummary(documentos),
            pw.SizedBox(height: 20),
            _buildDocumentosTable(documentos),
            pw.SizedBox(height: 30),
            _buildDocumentosFooter(),
          ];
        },
      ),
    );
    
    // Guardar PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Documentos_${vehiculo.marca}_${vehiculo.modelo}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Header para documentos
  static pw.Widget _buildDocumentosHeader(pw.MemoryImage logoImage, Vehiculo vehiculo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blue800, PdfColors.blue600],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 60,
            height: 60,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Image(logoImage, width: 40, height: 40),
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DOCUMENTOS DEL VEHÍCULO',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${vehiculo.marca} ${vehiculo.modelo} - ${vehiculo.placa}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  'Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método helper para crear items de resumen
  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  // Resumen de documentos
  static pw.Widget _buildDocumentosSummary(List<DocumentoVehiculo> documentos) {
    final totalDocumentos = documentos.length;
    final vencidos = documentos.where((d) => d.estado == 'Vencido').length;
    final porVencer = documentos.where((d) => d.estado == 'Por vencer').length;
    final alDia = documentos.where((d) => d.estado == 'Al día').length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', totalDocumentos.toString(), PdfColors.blue),
          _buildSummaryItem('Al día', alDia.toString(), PdfColors.green),
          _buildSummaryItem('Por vencer', porVencer.toString(), PdfColors.orange),
          _buildSummaryItem('Vencidos', vencidos.toString(), PdfColors.red),
        ],
      ),
    );
  }

  // Tabla de documentos
  static pw.Widget _buildDocumentosTable(List<DocumentoVehiculo> documentos) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Tipo de Documento',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Fecha Emisión',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Fecha Vencimiento',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Estado',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Días Restantes',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Filas de datos
        ...documentos.map((documento) {
          PdfColor statusColor;
          switch (documento.estado) {
            case 'Vencido':
              statusColor = PdfColors.red;
              break;
            case 'Por vencer':
              statusColor = PdfColors.orange;
              break;
            case 'Al día':
              statusColor = PdfColors.green;
              break;
            default:
              statusColor = PdfColors.grey;
          }

          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(documento.tipo),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(documento.fechaEmision),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(documento.fechaVencimiento),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: statusColor,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    documento.estado,
                    style: pw.TextStyle(
                      color: statusColor,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  documento.diasRestantes > 0 ? documento.diasRestantes.toString() : '-',
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Footer para documentos
  static pw.Widget _buildDocumentosFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'AutoCar - Sistema de Gestión Vehicular',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Página 1 de 1',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
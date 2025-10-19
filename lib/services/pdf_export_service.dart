import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';

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
      
      // Crear página principal
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Encabezado
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'AUTOCAR',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Text(
                          'Reporte de Vehículos y Mantenimientos',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Hora: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Resumen general
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Resumen General',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Vehículos', vehiculos.length.toString()),
                        _buildSummaryItem('Mantenimientos', mantenimientos.length.toString()),
                        _buildSummaryItem('Completados', mantenimientos.where((m) => m.status == 'completed').length.toString()),
                        _buildSummaryItem('Pendientes', mantenimientos.where((m) => m.status == 'pending').length.toString()),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Lista de vehículos
              pw.Text(
                'Vehículos Registrados',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Tabla de vehículos
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Encabezados
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Marca/Modelo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Año', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Placa', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Kilometraje', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Datos de vehículos
                  ...vehiculos.map((vehiculo) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${vehiculo.marca} ${vehiculo.modelo}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(vehiculo.ano.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(_getVehicleTypeDescription(vehiculo.tipo)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(vehiculo.placa),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${vehiculo.kilometraje} km'),
                      ),
                    ],
                  )),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Lista de mantenimientos
              pw.Text(
                'Historial de Mantenimientos',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Tabla de mantenimientos
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Encabezados
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Fecha', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Kilometraje', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Costo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Ubicación', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Estado', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Datos de mantenimientos
                  ...mantenimientos.map((mantenimiento) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${mantenimiento.fecha.day}/${mantenimiento.fecha.month}/${mantenimiento.fecha.year}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(mantenimiento.tipo),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${mantenimiento.kilometraje} km'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('\$${mantenimiento.costo.toStringAsFixed(2)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(mantenimiento.ubicacion.isNotEmpty ? mantenimiento.ubicacion : 'N/A'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          mantenimiento.status,
                          style: pw.TextStyle(
                            color: mantenimiento.status == 'completed' 
                                ? PdfColors.green 
                                : mantenimiento.status == 'urgent' 
                                    ? PdfColors.red 
                                    : PdfColors.orange,
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Pie de página
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Generado por AUTOCAR',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Sistema de gestión de mantenimiento vehicular',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );
      
      // Mostrar diálogo de impresión/guardado
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'AUTOCAR_Reporte_${DateTime.now().millisecondsSinceEpoch}.pdf',
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
  
  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
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
}

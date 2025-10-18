import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../database/database_helper.dart';

class MantenimientoDetailScreen extends StatefulWidget {
  final Mantenimiento mantenimiento;
  final Vehiculo vehiculo;

  const MantenimientoDetailScreen({
    super.key,
    required this.mantenimiento,
    required this.vehiculo,
  });

  @override
  State<MantenimientoDetailScreen> createState() => _MantenimientoDetailScreenState();
}

class _MantenimientoDetailScreenState extends State<MantenimientoDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _deleteMantenimiento() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este mantenimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dbHelper.deleteMantenimiento(widget.mantenimiento.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mantenimiento eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar mantenimiento: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Mantenimiento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteMantenimiento,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del vehículo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehículo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${widget.vehiculo.marca} ${widget.vehiculo.modelo}'),
                    Text('Placa: ${widget.vehiculo.placa}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Detalles del mantenimiento
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles del Mantenimiento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Fecha', DateFormat('dd/MM/yyyy').format(widget.mantenimiento.fecha)),
                    _buildDetailRow('Tipo', widget.mantenimiento.tipo),
                    _buildDetailRow('Descripción', widget.mantenimiento.descripcion),
                    _buildDetailRow('Costo', '\$${widget.mantenimiento.costo.toStringAsFixed(2)}'),
                    _buildDetailRow('Kilometraje', '${widget.mantenimiento.kilometraje} km'),
                    _buildDetailRow('Taller/Servicio', widget.mantenimiento.taller),
                    if (widget.mantenimiento.notas != null && widget.mantenimiento.notas!.isNotEmpty)
                      _buildDetailRow('Notas', widget.mantenimiento.notas!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Información adicional
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Adicional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Días transcurridos', _calculateDaysSince()),
                    _buildDetailRow('Kilómetros desde mantenimiento', _calculateKmSince()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDaysSince() {
    final days = DateTime.now().difference(widget.mantenimiento.fecha).inDays;
    return '$days días';
  }

  String _calculateKmSince() {
    final km = widget.vehiculo.kilometraje - widget.mantenimiento.kilometraje;
    return '$km km';
  }
}


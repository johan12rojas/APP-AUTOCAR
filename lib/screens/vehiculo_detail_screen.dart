import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../database/database_helper.dart';
import 'agendar_mantenimiento_screen.dart';
import 'mantenimiento_detail_screen.dart';

class VehiculoDetailScreen extends StatefulWidget {
  final Vehiculo vehiculo;

  const VehiculoDetailScreen({super.key, required this.vehiculo});

  @override
  State<VehiculoDetailScreen> createState() => _VehiculoDetailScreenState();
}

class _VehiculoDetailScreenState extends State<VehiculoDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Mantenimiento> _mantenimientos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMantenimientos();
  }

  Future<void> _loadMantenimientos() async {
    final mantenimientos = await _dbHelper.getMantenimientosByVehiculo(widget.vehiculo.id!);
    setState(() {
      _mantenimientos = mantenimientos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehiculo.marca} ${widget.vehiculo.modelo}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Información del vehículo
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_car, size: 40, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.vehiculo.marca} ${widget.vehiculo.modelo}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Año: ${widget.vehiculo.ano}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Placa', widget.vehiculo.placa),
                  _buildInfoRow('Tipo', widget.vehiculo.tipo.toUpperCase()),
                  _buildInfoRow('Kilometraje', '${widget.vehiculo.kilometraje} km'),
                ],
              ),
            ),
          ),
          // Lista de mantenimientos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mantenimientos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.build,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay mantenimientos registrados',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Toca el botón + para agregar el primer mantenimiento',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _mantenimientos.length,
                        itemBuilder: (context, index) {
                          final mantenimiento = _mantenimientos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: const Icon(
                                Icons.build,
                                color: Colors.orange,
                              ),
                              title: Text(
                                mantenimiento.tipo,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(mantenimiento.notas),
                                  Text(
                                    'Fecha: ${_formatDate(mantenimiento.fecha)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Costo: \$${mantenimiento.costo.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MantenimientoDetailScreen(
                                      mantenimiento: mantenimiento,
                                      vehiculo: widget.vehiculo,
                                    ),
                                  ),
                                );
                                _loadMantenimientos();
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                  builder: (context) => AgendarMantenimientoScreen(vehiculo: widget.vehiculo),
            ),
          );
          _loadMantenimientos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


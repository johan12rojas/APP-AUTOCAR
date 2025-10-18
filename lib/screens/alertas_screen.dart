import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../database/database_helper.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _alertas = [];
  Vehiculo? _vehiculoActual;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehiculos = await _dbHelper.getVehiculos();
      if (vehiculos.isNotEmpty) {
        _vehiculoActual = vehiculos.first;
        await _generarAlertas();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generarAlertas() async {
    if (_vehiculoActual == null) return;

    final alertas = <Map<String, dynamic>>[];

    // Alerta por kilometraje próximo a mantenimiento
    if (_vehiculoActual!.kmProximoMantenimiento > 0) {
      final kmRestantes = _vehiculoActual!.kmProximoMantenimiento - _vehiculoActual!.kilometraje;
      if (kmRestantes <= 1000 && kmRestantes > 0) {
        alertas.add({
          'tipo': 'mantenimiento',
          'titulo': 'Mantenimiento Próximo',
          'descripcion': '${_vehiculoActual!.proximoMantenimiento} en $kmRestantes km',
          'prioridad': kmRestantes <= 500 ? 'alta' : 'media',
          'icono': Icons.build,
          'color': kmRestantes <= 500 ? Colors.red : Colors.orange,
        });
      }
    }

    // Alertas por estado de componentes
    if (_vehiculoActual!.estadoAceite <= 20) {
      alertas.add({
        'tipo': 'componente',
        'titulo': 'Aceite de Motor',
        'descripcion': 'Estado crítico: ${_vehiculoActual!.estadoAceite}%',
        'prioridad': 'alta',
        'icono': Icons.oil_barrel,
        'color': Colors.red,
      });
    } else if (_vehiculoActual!.estadoAceite <= 40) {
      alertas.add({
        'tipo': 'componente',
        'titulo': 'Aceite de Motor',
        'descripcion': 'Estado bajo: ${_vehiculoActual!.estadoAceite}%',
        'prioridad': 'media',
        'icono': Icons.oil_barrel,
        'color': Colors.orange,
      });
    }

    if (_vehiculoActual!.estadoLlantas <= 20) {
      alertas.add({
        'tipo': 'componente',
        'titulo': 'Llantas',
        'descripcion': 'Estado crítico: ${_vehiculoActual!.estadoLlantas}%',
        'prioridad': 'alta',
        'icono': Icons.directions_car,
        'color': Colors.red,
      });
    } else if (_vehiculoActual!.estadoLlantas <= 40) {
      alertas.add({
        'tipo': 'componente',
        'titulo': 'Llantas',
        'descripcion': 'Estado bajo: ${_vehiculoActual!.estadoLlantas}%',
        'prioridad': 'media',
        'icono': Icons.directions_car,
        'color': Colors.orange,
      });
    }

    if (_vehiculoActual!.estadoFrenos <= 20) {
      alertas.add({
        'tipo': 'componente',
        'titulo': 'Frenos',
        'descripcion': 'Estado crítico: ${_vehiculoActual!.estadoFrenos}%',
        'prioridad': 'alta',
        'icono': Icons.stop_circle,
        'color': Colors.red,
      });
    } else if (_vehiculoActual!.estadoFrenos <= 40) {
      alertas.add({
        'tipo': 'componente',
        'titulo': 'Frenos',
        'descripcion': 'Estado bajo: ${_vehiculoActual!.estadoFrenos}%',
        'prioridad': 'media',
        'icono': Icons.stop_circle,
        'color': Colors.orange,
      });
    }

    if (_vehiculoActual!.estadoBateria <= 20) {
      alertas.add({
        'tipo': 'componente',
        'titulo': 'Batería',
        'descripcion': 'Estado crítico: ${_vehiculoActual!.estadoBateria}%',
        'prioridad': 'alta',
        'icono': Icons.battery_charging_full,
        'color': Colors.red,
      });
    } else if (_vehiculoActual!.estadoBateria <= 40) {
      alertas.add({
        'tipo': 'componente',
        'titulo': 'Batería',
        'descripcion': 'Estado bajo: ${_vehiculoActual!.estadoBateria}%',
        'prioridad': 'media',
        'icono': Icons.battery_charging_full,
        'color': Colors.orange,
      });
    }

    setState(() {
      _alertas = alertas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Alertas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _cargarAlertas,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _vehiculoActual == null
              ? _buildSinVehiculo()
              : _buildAlertas(),
    );
  }

  Widget _buildSinVehiculo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off,
            size: 100,
            color: Colors.white70,
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay vehículos registrados',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Agrega un vehículo para recibir alertas',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertas() {
    if (_alertas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Color(0xFF32CD32),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Todo en orden!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'No hay alertas pendientes',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumenAlertas(),
          const SizedBox(height: 30),
          _buildListaAlertas(),
        ],
      ),
    );
  }

  Widget _buildResumenAlertas() {
    final alertasAltas = _alertas.where((a) => a['prioridad'] == 'alta').length;
    final alertasMedias = _alertas.where((a) => a['prioridad'] == 'media').length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6), // Azul claro
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Alertas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Críticas',
                alertasAltas.toString(),
                Colors.red,
                Icons.warning,
              ),
              _buildStatItem(
                'Advertencias',
                alertasMedias.toString(),
                Colors.orange,
                Icons.info,
              ),
              _buildStatItem(
                'Total',
                _alertas.length.toString(),
                Colors.white70,
                Icons.notifications,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildListaAlertas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas Activas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ..._alertas.map((alerta) => _buildAlertaCard(alerta)),
      ],
    );
  }

  Widget _buildAlertaCard(Map<String, dynamic> alerta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (alerta['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alerta['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              alerta['icono'],
              color: alerta['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alerta['titulo'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: alerta['color'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alerta['prioridad'].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  alerta['descripcion'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              _mostrarAccionesAlerta(alerta);
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarAccionesAlerta(Map<String, dynamic> alerta) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E3A8A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              alerta['titulo'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.build, color: Color(0xFFFF6B35)),
              title: const Text(
                'Agendar Mantenimiento',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a agendar mantenimiento
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white70),
              title: const Text(
                'Actualizar Estado',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Actualizar estado del componente
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.white70),
              title: const Text(
                'Marcar como Resuelto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Marcar alerta como resuelta
              },
            ),
          ],
        ),
      ),
    );
  }
}

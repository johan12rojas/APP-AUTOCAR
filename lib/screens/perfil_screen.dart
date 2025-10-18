import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../database/database_helper.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Vehiculo> _vehiculos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  Future<void> _cargarVehiculos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehiculos = await _dbHelper.getVehiculos();
      setState(() {
        _vehiculos = vehiculos;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Configuración
            },
            icon: const Icon(
              Icons.settings,
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPerfilUsuario(),
                  const SizedBox(height: 30),
                  _buildEstadisticasGenerales(),
                  const SizedBox(height: 30),
                  _buildVehiculosSection(),
                  const SizedBox(height: 30),
                  _buildOpcionesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPerfilUsuario() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6), // Azul claro
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Usuario AUTOCAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Gestión de Vehículos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Vehículos',
                _vehiculos.length.toString(),
                Icons.directions_car,
              ),
              _buildStatItem(
                'Días Activo',
                '30',
                Icons.calendar_today,
              ),
              _buildStatItem(
                'Mantenimientos',
                '12',
                Icons.build,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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

  Widget _buildEstadisticasGenerales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas Generales',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildStatRow('Total de Vehículos', _vehiculos.length.toString()),
              const Divider(color: Colors.white24),
              _buildStatRow('Kilometraje Total', _calcularKilometrajeTotal()),
              const Divider(color: Colors.white24),
              _buildStatRow('Último Mantenimiento', 'Hace 15 días'),
              const Divider(color: Colors.white24),
              _buildStatRow('Próximo Mantenimiento', 'En 5 días'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _calcularKilometrajeTotal() {
    final totalKm = _vehiculos.fold<int>(0, (sum, vehiculo) => sum + vehiculo.kilometraje);
    return '${totalKm.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km';
  }

  Widget _buildVehiculosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis Vehículos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Agregar vehículo
              },
              icon: const Icon(Icons.add, color: Color(0xFFFF6B35)),
              label: const Text(
                'Agregar',
                style: TextStyle(color: Color(0xFFFF6B35)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (_vehiculos.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 50,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No hay vehículos registrados',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._vehiculos.map((vehiculo) => _buildVehiculoCard(vehiculo)),
      ],
    );
  }

  Widget _buildVehiculoCard(Vehiculo vehiculo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFFFF6B35),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehiculo.marca} ${vehiculo.modelo}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${vehiculo.ano} • ${vehiculo.placa}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${vehiculo.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _mostrarOpcionesVehiculo(vehiculo);
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

  Widget _buildOpcionesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildOpcionItem(
                'Configuración',
                'Ajustes de la aplicación',
                Icons.settings,
                () {
                  // TODO: Configuración
                },
              ),
              const Divider(color: Colors.white24, height: 1),
              _buildOpcionItem(
                'Exportar Datos',
                'Exportar información a PDF',
                Icons.file_download,
                () {
                  // TODO: Exportar datos
                },
              ),
              const Divider(color: Colors.white24, height: 1),
              _buildOpcionItem(
                'Respaldo',
                'Crear respaldo de datos',
                Icons.backup,
                () {
                  // TODO: Respaldo
                },
              ),
              const Divider(color: Colors.white24, height: 1),
              _buildOpcionItem(
                'Acerca de',
                'Información de la aplicación',
                Icons.info,
                () {
                  _mostrarAcercaDe();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpcionItem(String titulo, String subtitulo, IconData icono, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icono,
        color: Colors.white70,
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _mostrarOpcionesVehiculo(Vehiculo vehiculo) {
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
              '${vehiculo.marca} ${vehiculo.modelo}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFFF6B35)),
              title: const Text(
                'Editar Vehículo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Editar vehículo
              },
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.white70),
              title: const Text(
                'Ver Mantenimientos',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Ver mantenimientos
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar Vehículo',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminacion(vehiculo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminacion(Vehiculo vehiculo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A8A),
        title: const Text(
          'Eliminar Vehículo',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar ${vehiculo.marca} ${vehiculo.modelo}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.deleteVehiculo(vehiculo.id!);
              if (mounted) {
                Navigator.pop(context);
                _cargarVehiculos();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarAcercaDe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A8A),
        title: const Text(
          'AUTOCAR',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car,
              size: 50,
              color: Color(0xFFFF6B35),
            ),
            SizedBox(height: 10),
            Text(
              'Bitácora de Mantenimiento Vehicular',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              'Versión 1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              'Desarrollado con Flutter',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

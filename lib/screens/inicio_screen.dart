import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vehiculo.dart';
import '../database/database_helper.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  Vehiculo? _vehiculoActual;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _cargarVehiculoActual();
  }

  Future<void> _cargarVehiculoActual() async {
    final vehiculos = await _dbHelper.getVehiculos();
    if (vehiculos.isNotEmpty) {
      setState(() {
        _vehiculoActual = vehiculos.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro
      body: SafeArea(
        child: _vehiculoActual == null
            ? _buildSinVehiculos()
            : _buildConVehiculo(),
      ),
    );
  }

  Widget _buildSinVehiculos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car,
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
            'Agrega tu primer vehículo para comenzar',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navegar a agregar vehículo
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar Vehículo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConVehiculo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildKilometrajeCard(),
          const SizedBox(height: 20),
          _buildProximoMantenimientoCard(),
          const SizedBox(height: 30),
          _buildEstadoVehiculoSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // TODO: Abrir configuración
          },
          icon: const Icon(
            Icons.settings,
            color: Colors.white70,
            size: 24,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                '${_vehiculoActual!.marca} ${_vehiculoActual!.modelo} ${_vehiculoActual!.ano}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6), // Azul claro
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            onPressed: () {
              // TODO: Cambiar tipo de vehículo
            },
            child: const Text(
              'Cambiar a Moto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKilometrajeCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kilometraje Actual',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () {
                  _mostrarDialogoKilometraje();
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_vehiculoActual!.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximoMantenimientoCard() {
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
            'Próximo Mantenimiento',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _vehiculoActual!.proximoMantenimiento,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVehiculoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estado del Vehículo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6), // Azul claro
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  // TODO: Agendar mantenimiento
                },
                child: const Text(
                  '+ Agendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildComponenteCard(
          icon: Icons.oil_barrel,
          nombre: 'Aceite de Motor',
          porcentaje: _vehiculoActual!.estadoAceite,
          color: const Color(0xFFFFA500), // Naranja
        ),
        const SizedBox(height: 15),
        _buildComponenteCard(
          icon: Icons.directions_car,
          nombre: 'Llantas',
          porcentaje: _vehiculoActual!.estadoLlantas,
          color: const Color(0xFFFF4500), // Rojo naranja
        ),
        const SizedBox(height: 15),
        _buildComponenteCard(
          icon: Icons.stop_circle,
          nombre: 'Frenos',
          porcentaje: _vehiculoActual!.estadoFrenos,
          color: const Color(0xFFFFA500), // Naranja
        ),
        const SizedBox(height: 15),
        _buildComponenteCard(
          icon: Icons.battery_charging_full,
          nombre: 'Batería',
          porcentaje: _vehiculoActual!.estadoBateria,
          color: const Color(0xFF32CD32), // Verde
        ),
      ],
    );
  }

  Widget _buildComponenteCard({
    required IconData icon,
    required String nombre,
    required int porcentaje,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: porcentaje / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Text(
            '$porcentaje%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoKilometraje() {
    final controller = TextEditingController(text: _vehiculoActual!.kilometraje.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Kilometraje'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Kilometraje',
            suffixText: 'km',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoKilometraje = int.tryParse(controller.text);
              if (nuevoKilometraje != null) {
                final vehiculoActualizado = _vehiculoActual!.copyWith(
                  kilometraje: nuevoKilometraje,
                );
                await _dbHelper.updateVehiculo(vehiculoActualizado);
                if (mounted) {
                  setState(() {
                    _vehiculoActual = vehiculoActualizado;
                  });
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

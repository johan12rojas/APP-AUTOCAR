import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vehiculo.dart';
import '../database/database_helper.dart';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';
import 'add_vehiculo_screen.dart';
import 'vehiculo_detail_screen.dart';

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
      backgroundColor: AutocarTheme.darkBackground,
      body: BackgroundGradientWidget(
        child: SafeArea(
          child: _vehiculoActual == null
              ? _buildSinVehiculos()
              : _buildConVehiculo(),
        ),
      ),
    );
  }

  Widget _buildSinVehiculos() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la aplicación con efecto de gradiente
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: AutocarTheme.accentGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: AutocarTheme.buttonShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'assets/images/logos/logo_autocar.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.directions_car,
                      size: 70,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'AUTOCAR',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AutocarTheme.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: AutocarTheme.accentOrange.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Bitácora de Mantenimiento Vehicular',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AutocarTheme.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AutocarTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AutocarTheme.cardShadow,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.car_rental,
                    size: 50,
                    color: AutocarTheme.accentOrange,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '¡Bienvenido a AUTOCAR!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AutocarTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No hay vehículos registrados.\nAgrega tu primer vehículo para comenzar a gestionar sus mantenimientos.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AutocarTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddVehiculoScreen(),
                  ),
                );
                if (result == true) {
                  _cargarVehiculoActual();
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Agregar Mi Primer Vehículo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AutocarTheme.accentOrange,
                foregroundColor: AutocarTheme.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
                shadowColor: AutocarTheme.accentOrange.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
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
          const SizedBox(height: 20),
          _buildEstadisticasCard(),
          const SizedBox(height: 30),
          _buildEstadoVehiculoSection(),
          const SizedBox(height: 20),
          _buildAccionesRapidas(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AutocarTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AutocarTheme.cardShadow,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VehiculoDetailScreen(vehiculo: _vehiculoActual!),
                ),
              );
            },
            icon: const Icon(
              Icons.info_outline,
              color: AutocarTheme.textPrimary,
              size: 24,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // Logo pequeño en el header
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AutocarTheme.accentGradient,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: AutocarTheme.buttonShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/logos/logo_autocar.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 35,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_vehiculoActual!.marca} ${_vehiculoActual!.modelo} ${_vehiculoActual!.ano}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AutocarTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AutocarTheme.accentOrange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _vehiculoActual!.tipo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AutocarTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVehiculoScreen(),
                  ),
                );
              if (result == true) {
                _cargarVehiculoActual();
              }
            },
            icon: const Icon(
              Icons.edit,
              color: AutocarTheme.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKilometrajeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AutocarTheme.successGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AutocarTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.speed,
                    color: AutocarTheme.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kilometraje Actual',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AutocarTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  _mostrarDialogoKilometraje();
                },
                icon: const Icon(
                  Icons.edit,
                  color: AutocarTheme.textPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '${_vehiculoActual!.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AutocarTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AutocarTheme.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AutocarTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
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
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AutocarTheme.warningGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AutocarTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AutocarTheme.textPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estadísticas del Vehículo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AutocarTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Años', '${DateTime.now().year - int.parse(_vehiculoActual!.ano.toString())}'),
              _buildStatItem('Promedio', '15,000 km/año'),
              _buildStatItem('Estado', 'Excelente'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AutocarTheme.textPrimary.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAccionesRapidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Nuevo Mantenimiento',
                color: AutocarTheme.accentGreen,
                onTap: () {
                  // TODO: Navegar a agregar mantenimiento
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionButton(
                icon: Icons.history,
                label: 'Ver Historial',
                color: AutocarTheme.accentPurple,
                onTap: () {
                  // TODO: Navegar a historial
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.notifications_active,
                label: 'Configurar Alertas',
                color: AutocarTheme.accentPink,
                onTap: () {
                  // TODO: Navegar a configuración de alertas
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionButton(
                icon: Icons.share,
                label: 'Exportar Datos',
                color: AutocarTheme.accentYellow,
                onTap: () {
                  // TODO: Exportar datos
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AutocarTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
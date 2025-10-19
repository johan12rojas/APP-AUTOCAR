import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';
import '../viewmodels/vehiculo_viewmodel.dart';
import '../services/maintenance_service.dart';
import '../models/vehiculo.dart';
import '../services/vehicle_image_service.dart';
import '../services/user_preferences_service.dart';
import 'agregar_vehiculo_screen.dart';
import 'agendar_mantenimiento_screen.dart';
import 'vehiculo_detail_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  String _nombreUsuario = 'Usuario';
  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculoViewModel>().cargarVehiculos();
    });
  }

  Future<void> _cargarNombreUsuario() async {
    final nombre = await UserPreferencesService.obtenerNombreUsuario();
    setState(() {
      _nombreUsuario = nombre;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: BackgroundGradientWidget(
        child: SafeArea(
          child: Consumer<VehiculoViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && viewModel.vehiculos.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AutocarTheme.accentOrange,
                  ),
                );
              }

              if (viewModel.vehiculos.isEmpty) {
                return _buildSinVehiculos(context, viewModel);
              }

              return _buildConVehiculo(context, viewModel);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSinVehiculos(BuildContext context, VehiculoViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la aplicación
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
                color: AutocarTheme.cardBackground.withValues(alpha: 0.2),
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
                    builder: (context) => const AgregarVehiculoScreen(),
                  ),
                );
                if (result == true) {
                  viewModel.cargarVehiculos();
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

  Widget _buildConVehiculo(BuildContext context, VehiculoViewModel viewModel) {
    final vehiculo = viewModel.vehiculoActual!;
    final alertasCriticas = viewModel.alertasCriticas;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderMejorado(context, vehiculo, viewModel),
          const SizedBox(height: 20),
          
          // Alertas críticas si las hay
          if (alertasCriticas.isNotEmpty) ...[
            _buildAlertasCriticas(context, alertasCriticas),
            const SizedBox(height: 20),
          ],
          
          _buildVehiculoActualCard(context, vehiculo, viewModel),
          const SizedBox(height: 20),
          _buildEstadoVehiculoSection(context, vehiculo, viewModel),
          const SizedBox(height: 20),
          _buildGridFunciones(context, viewModel, vehiculo),
          const SizedBox(height: 20),
          _buildGraficoMantenimiento(context, vehiculo),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, vehiculo, VehiculoViewModel viewModel) {
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
              _showVehicleSelector(context, viewModel);
            },
            icon: const Icon(
              Icons.swap_horiz,
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
                      vehiculo.tipo == 'carro' 
                        ? 'assets/images/vehicles/car_default.png'
                        : 'assets/images/vehicles/motorcycle.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          vehiculo.tipo.contains('moto') ? Icons.motorcycle : Icons.directions_car,
                          color: Colors.white,
                          size: 35,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${vehiculo.marca} ${vehiculo.modelo} ${vehiculo.ano}',
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
                    vehiculo.tipo.toUpperCase(),
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
                  builder: (context) => const AgregarVehiculoScreen(),
                ),
              );
              if (result == true) {
                viewModel.cargarVehiculos();
              }
            },
            icon: const Icon(
              Icons.add,
              color: AutocarTheme.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertasCriticas(BuildContext context, List<MapEntry<String, dynamic>> alertasCriticas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '¡Atención Requerida!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...alertasCriticas.map((alerta) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '• ${MaintenanceService.getCategoryDisplayName(alerta.key)} en nivel crítico (${(alerta.value as MaintenanceData).percentage.round()}%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildKilometrajeCard(BuildContext context, vehiculo, VehiculoViewModel viewModel) {
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
                  _mostrarDialogoKilometraje(context, vehiculo, viewModel);
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
            '${vehiculo.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
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

  Widget _buildEstadoVehiculoSection(BuildContext context, vehiculo, VehiculoViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Estado del Vehículo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AutocarTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orangeAccent.withValues(alpha: 0.8),
                    Colors.deepOrangeAccent.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgendarMantenimientoScreen(vehiculo: vehiculo),
                    ),
                  );
                  if (result == true) {
                    viewModel.cargarMantenimientos();
                  }
                },
                child: const Text(
                  '+ Agendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...vehiculo.maintenance.entries.map((entry) {
          final categoria = entry.key;
          final datos = entry.value;
          final color = _getProgressBarColor(datos.percentage);
          final icono = MaintenanceService.getMaintenanceIcon(categoria);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildComponenteCard(
              icon: icono,
              nombre: MaintenanceService.getCategoryDisplayName(categoria),
              porcentaje: datos.percentage.round(),
              color: color,
              dueKm: datos.dueKm,
              currentKm: vehiculo.kilometraje,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildComponenteCard({
    required String icon,
    required String nombre,
    required int porcentaje,
    required Color color,
    required int dueKm,
    required int currentKm,
  }) {
    final kmRestantes = dueKm - currentKm;
    final diasRestantes = (kmRestantes / 50).round(); // Asumiendo 50 km/día promedio
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Icon(
              _getIconData(icon),
              color: color,
              size: 24,
            ),
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
                _buildGradientProgressBar(porcentaje, color),
                const SizedBox(height: 4),
                Text(
                  kmRestantes > 0 
                    ? 'Faltan ${kmRestantes.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km (~$diasRestantes días)'
                    : 'Vencido por ${(-kmRestantes).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
                  style: TextStyle(
                    color: kmRestantes > 0 ? Colors.white70 : Colors.red.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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

  Widget _buildAccionesRapidas(BuildContext context, VehiculoViewModel viewModel) {
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
                icon: Icons.schedule,
                label: 'Agendar Mantenimiento',
                color: Colors.orangeAccent,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgendarMantenimientoScreen(vehiculo: viewModel.vehiculoActual!),
                    ),
                  );
                  if (result == true) {
                    viewModel.cargarMantenimientos();
                  }
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
                label: 'Ver Alertas',
                color: AutocarTheme.accentPink,
                onTap: () {
                  // TODO: Navegar a alertas
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

  void _mostrarDialogoKilometraje(BuildContext context, vehiculo, VehiculoViewModel viewModel) {
    final controller = TextEditingController(text: vehiculo.kilometraje.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Kilometraje'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
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
              if (nuevoKilometraje != null && nuevoKilometraje >= vehiculo.kilometraje) {
                await viewModel.actualizarKilometraje(nuevoKilometraje);
                if (mounted) {
                  Navigator.pop(context);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El kilometraje debe ser mayor o igual al actual'),
                  ),
                );
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Color _getProgressBarColor(double percentage) {
    if (percentage <= 10) return Colors.red;
    if (percentage <= 30) return Colors.orange;
    if (percentage <= 60) return Colors.yellow;
    if (percentage <= 90) return Colors.blue;
    return Colors.green;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'oil_barrel': return Icons.oil_barrel;
      case 'directions_car': return Icons.directions_car;
      case 'stop_circle': return Icons.stop_circle;
      case 'battery_charging_full': return Icons.battery_charging_full;
      case 'thermostat': return Icons.thermostat;
      case 'air': return Icons.air;
      case 'settings': return Icons.settings;
      case 'link': return Icons.link;
      case 'flash_on': return Icons.flash_on;
      default: return Icons.build;
    }
  }


  void _showVehicleSelector(BuildContext context, VehiculoViewModel viewModel) {
    if (viewModel.vehiculos.length <= 1) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AutocarTheme.darkBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Seleccionar Vehículo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AutocarTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...viewModel.vehiculos.map((vehiculo) => ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: vehiculo.imagenPersonalizada != null && vehiculo.imagenPersonalizada!.isNotEmpty
                      ? Image.file(
                          File(vehiculo.imagenPersonalizada!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              VehicleImageService.getVehicleImagePath(vehiculo.tipo),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  vehiculo.tipo.contains('moto') ? Icons.motorcycle : Icons.directions_car,
                                  size: 30,
                                  color: Colors.blue,
                                );
                              },
                            );
                          },
                        )
                      : Image.asset(
                          VehicleImageService.getVehicleImagePath(vehiculo.tipo),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              vehiculo.tipo.contains('moto') ? Icons.motorcycle : Icons.directions_car,
                              size: 30,
                              color: Colors.blue,
                            );
                          },
                        ),
                ),
              ),
              title: Text(
                '${vehiculo.marca} ${vehiculo.modelo}',
                style: const TextStyle(
                  color: AutocarTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${vehiculo.placa} • ${vehiculo.kilometraje} km',
                style: const TextStyle(color: AutocarTheme.textSecondary),
              ),
              trailing: vehiculo.id == viewModel.vehiculoActual?.id
                  ? const Icon(Icons.check, color: AutocarTheme.accentOrange)
                  : null,
              onTap: () {
                viewModel.cambiarVehiculoActual(vehiculo);
                Navigator.pop(context);
              },
            )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoMantenimiento(BuildContext context, Vehiculo vehiculo) {
    final maintenanceData = vehiculo.maintenance;
    final categories = maintenanceData.keys.toList();
    
    // Preparar datos para el gráfico de barras
    final barGroups = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final data = maintenanceData[category]!;
      final percentage = data.percentage;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: _getProgressBarColor(percentage),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estado de Mantenimiento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${vehiculo.kilometraje} km',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final category = categories[group.x];
                      final data = maintenanceData[category]!;
                      return BarTooltipItem(
                        '${MaintenanceService.getCategoryDisplayName(category)}\n${data.percentage.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < categories.length) {
                          final category = categories[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              MaintenanceService.getCategoryDisplayName(category).split(' ').first,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Excelente', Colors.green),
              _buildLegendItem('Bueno', Colors.yellow),
              _buildLegendItem('Regular', Colors.orange),
              _buildLegendItem('Crítico', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderMejorado(BuildContext context, Vehiculo vehiculo, VehiculoViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.waving_hand,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "¡Bienvenido $_nombreUsuario!",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tu centro de control vehicular inteligente",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehiculoActualCard(BuildContext context, Vehiculo vehiculo, VehiculoViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                  child: vehiculo.imagenPersonalizada != null && vehiculo.imagenPersonalizada!.isNotEmpty
                      ? Image.file(
                          File(vehiculo.imagenPersonalizada!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              VehicleImageService.getVehicleImagePath(vehiculo.tipo),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  vehiculo.tipo.contains('moto') ? Icons.motorcycle : Icons.directions_car,
                                  color: Colors.white,
                                  size: 35,
                                );
                              },
                            );
                          },
                        )
                      : Image.asset(
                          VehicleImageService.getVehicleImagePath(vehiculo.tipo),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              vehiculo.tipo.contains('moto') ? Icons.motorcycle : Icons.directions_car,
                              color: Colors.white,
                              size: 35,
                            );
                          },
                        ),
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
                            '${vehiculo.marca} ${vehiculo.modelo}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (viewModel.vehiculos.length > 1)
                          IconButton(
                            onPressed: () => _showVehicleSelector(context, viewModel),
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.swap_horiz,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehiculo.placa} • ${vehiculo.kilometraje} km',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Kilometraje', '${vehiculo.kilometraje}', Icons.speed),
              ),
              Expanded(
                child: _buildStatItem('Año', '${vehiculo.ano}', Icons.calendar_today),
              ),
              Expanded(
                child: _buildStatItem('Tipo', vehiculo.tipo == 'carro' ? 'Carro' : 'Moto', Icons.category),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withValues(alpha: 0.8),
                  Colors.blue.withValues(alpha: 0.6),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _mostrarActualizarKilometraje(context, vehiculo, viewModel),
              icon: const Icon(Icons.speed, size: 20),
              label: const Text('Actualizar Kilometraje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridFunciones(BuildContext context, VehiculoViewModel viewModel, Vehiculo vehiculo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Funciones Principales",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.1,
          children: [
            _buildCard(
              icon: Icons.directions_car,
              color: Colors.orangeAccent,
              title: "Mi vehículo",
              subtitle: "Información y estado",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehiculoDetailScreen(vehiculo: vehiculo),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.build_circle,
              color: Colors.greenAccent,
              title: "Mantenimiento",
              subtitle: "Auto-programado",
              onTap: () {
                // El sistema ahora es completamente automático
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'El mantenimiento se programa automáticamente según el kilometraje',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF1A1A2E),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
            _buildCard(
              icon: Icons.analytics,
              color: Colors.purpleAccent,
              title: "Estadísticas",
              subtitle: "Consumo y km",
              onTap: () {
                // TODO: Implementar pantalla de estadísticas
              },
            ),
            _buildCard(
              icon: Icons.map,
              color: Colors.lightBlueAccent,
              title: "Ubicación",
              subtitle: "Talleres cercanos",
              onTap: () {
                // TODO: Implementar pantalla de ubicación
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      splashColor: color.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
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
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 45),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarActualizarKilometraje(BuildContext context, Vehiculo vehiculo, VehiculoViewModel viewModel) {
    final TextEditingController kilometrajeController = TextEditingController(text: vehiculo.kilometraje.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AutocarTheme.darkBackground,
        title: const Text('Actualizar Kilometraje', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${vehiculo.marca} ${vehiculo.modelo}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: kilometrajeController,
              decoration: const InputDecoration(
                labelText: 'Nuevo Kilometraje',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                suffixText: 'km',
                suffixStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoKilometraje = int.tryParse(kilometrajeController.text);
              if (nuevoKilometraje != null && nuevoKilometraje > vehiculo.kilometraje) {
                await viewModel.actualizarKilometrajeVehiculo(vehiculo.id!, nuevoKilometraje);
                
                // Recalcular automáticamente los estados del vehículo
                await viewModel.recalcularEstadosVehiculo(vehiculo.id!);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kilometraje actualizado y estados recalculados'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El kilometraje debe ser mayor al actual'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientProgressBar(int porcentaje, Color baseColor) {
    // Determinar los colores del gradiente basado en el color base
    List<Color> gradientColors;
    
    if (baseColor == Colors.green) {
      gradientColors = [Colors.green.shade300, Colors.green.shade600, Colors.green.shade800];
    } else if (baseColor == Colors.blue) {
      gradientColors = [Colors.blue.shade300, Colors.blue.shade600, Colors.blue.shade800];
    } else if (baseColor == Colors.orange) {
      gradientColors = [Colors.orange.shade300, Colors.orange.shade600, Colors.orange.shade800];
    } else if (baseColor == Colors.red) {
      gradientColors = [Colors.red.shade300, Colors.red.shade600, Colors.red.shade800];
    } else if (baseColor == Colors.yellow) {
      gradientColors = [Colors.yellow.shade300, Colors.yellow.shade600, Colors.yellow.shade800];
    } else if (baseColor == Colors.purple) {
      gradientColors = [Colors.purple.shade300, Colors.purple.shade600, Colors.purple.shade800];
    } else if (baseColor == Colors.teal) {
      gradientColors = [Colors.teal.shade300, Colors.teal.shade600, Colors.teal.shade800];
    } else {
      // Color por defecto
      gradientColors = [baseColor.withValues(alpha: 0.3), baseColor, baseColor.withValues(alpha: 0.8)];
    }

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withValues(alpha: 0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Fondo
            Container(
              width: double.infinity,
              height: 8,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            // Barra de progreso con gradiente
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    ...gradientColors,
                    Colors.transparent,
                  ],
                  stops: [
                    0.0,
                    (porcentaje / 100).clamp(0.0, 1.0),
                    (porcentaje / 100).clamp(0.0, 1.0),
                    1.0,
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.last.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
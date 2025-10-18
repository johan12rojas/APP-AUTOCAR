import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mantenimiento.dart';
import '../models/vehiculo.dart';
import '../database/database_helper.dart';
import '../viewmodels/vehiculo_viewmodel.dart';
import '../services/maintenance_service.dart';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';
import '../services/auto_maintenance_scheduler.dart';
import 'agendar_mantenimiento_screen.dart';
import 'completar_mantenimiento_screen.dart';

class BitacoraScreen extends StatefulWidget {
  const BitacoraScreen({super.key});

  @override
  State<BitacoraScreen> createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Mantenimiento> _mantenimientos = [];
  late TabController _tabController;
  String _filtroActual = 'Todos';
  
  final Map<String, String> _filtros = {
    'Todos': 'Todos',
    'Completados': 'Completados', 
    'Pendientes': 'Pendientes',
    'Urgentes': 'Urgentes',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculoViewModel>().cargarVehiculos();
      _cargarMantenimientos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarMantenimientos() async {
    final viewModel = context.read<VehiculoViewModel>();
    if (viewModel.vehiculoActual != null) {
      final mantenimientos = await _dbHelper.getMantenimientosPorVehiculo(viewModel.vehiculoActual!.id!);
      setState(() {
        _mantenimientos = mantenimientos;
      });
    }
  }

  List<Mantenimiento> _filtrarMantenimientos() {
    switch (_filtroActual) {
      case 'Completados':
        return _mantenimientos.where((m) => m.status == 'completed').toList();
      case 'Pendientes':
        return _mantenimientos.where((m) => m.status == 'pending').toList();
      case 'Urgentes':
        return _mantenimientos.where((m) => m.status == 'urgent').toList();
      default:
        return _mantenimientos;
    }
  }

  Map<String, int> _calcularEstadisticas() {
    return {
      'total': _mantenimientos.length,
      'completados': _mantenimientos.where((m) => m.status == 'completed').length,
      'pendientes': _mantenimientos.where((m) => m.status == 'pending').length,
      'urgentes': _mantenimientos.where((m) => m.status == 'urgent').length,
    };
  }

  double _calcularGastosTotales() {
    return _mantenimientos
        .where((m) => m.status == 'completed')
        .fold(0.0, (sum, m) => sum + m.costo);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundGradientWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Bitácora',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<VehiculoViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.vehiculos.length > 1) {
                  return IconButton(
                    onPressed: () => _showVehicleSelector(context, viewModel),
                    icon: const Icon(
                      Icons.swap_horiz,
                      color: Colors.white,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              onPressed: () => _mostrarAgregarMantenimiento(),
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Consumer<VehiculoViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (viewModel.vehiculoActual == null) {
              return _buildSinVehiculo();
            }

            return _buildBitacora(viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildSinVehiculo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
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
            'Agrega un vehículo para ver su bitácora',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBitacora(VehiculoViewModel viewModel) {
    final estadisticas = _calcularEstadisticas();
    final gastosTotales = _calcularGastosTotales();
    final mantenimientosFiltrados = _filtrarMantenimientos();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(viewModel.vehiculoActual!, estadisticas),
          const SizedBox(height: 20),
          _buildGastosCard(gastosTotales),
          const SizedBox(height: 20),
          _buildTabs(),
          const SizedBox(height: 20),
          _buildMantenimientosList(mantenimientosFiltrados),
        ],
      ),
    );
  }

  Widget _buildHeader(Vehiculo vehiculo, Map<String, int> estadisticas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bitácora',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${estadisticas['completados']} completados • ${estadisticas['pendientes']} pendientes',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGastosCard(double gastosTotales) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.tealAccent.withOpacity(0.8),
            Colors.cyanAccent.withOpacity(0.6),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gastos Totales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${gastosTotales.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        onTap: (index) {
          setState(() {
            _filtroActual = _filtros.keys.elementAt(index);
          });
        },
        tabs: _filtros.keys.map((filtro) => Tab(text: filtro)).toList(),
      ),
    );
  }

  Widget _buildMantenimientosList(List<Mantenimiento> mantenimientos) {
    if (mantenimientos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 60,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay mantenimientos ${_filtroActual.toLowerCase()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega un nuevo mantenimiento',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: mantenimientos.map((mantenimiento) => 
        _buildMantenimientoCard(mantenimiento)
      ).toList(),
    );
  }

  Widget _buildMantenimientoCard(Mantenimiento mantenimiento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          _getMaintenanceImage(mantenimiento.tipo),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getMaintenanceIcon(mantenimiento.tipo),
                              color: Colors.white,
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getMaintenanceDisplayName(mantenimiento.tipo),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${mantenimiento.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatearFecha(mantenimiento.fecha),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (mantenimiento.notas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              mantenimiento.notas,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
          if (mantenimiento.costo > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  color: Color(0xFF32CD32),
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  '\$${mantenimiento.costo.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF32CD32),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (mantenimiento.status != 'completed') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarCompletarMantenimiento(mantenimiento),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Completar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _editarMantenimiento(mantenimiento),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _eliminarMantenimiento(mantenimiento),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Eliminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  String _getMaintenanceImage(String maintenanceType) {
    switch (maintenanceType) {
      case 'oil': return 'assets/images/maintenance/oil_change.png';
      case 'tires': return 'assets/images/maintenance/tire_rotation.png';
      case 'brakes': return 'assets/images/maintenance/brake_service.png';
      case 'battery': return 'assets/images/maintenance/battery_check.png';
      case 'coolant': return 'assets/images/maintenance/engine_service.png';
      case 'airFilter': return 'assets/images/maintenance/air_filter.png';
      case 'alignment': return 'assets/images/maintenance/transmission.png';
      case 'chain': return 'assets/images/maintenance/transmission.png';
      case 'sparkPlug': return 'assets/images/maintenance/spark_plugs.png';
      default: return 'assets/images/maintenance/engine_service.png';
    }
  }

  IconData _getMaintenanceIcon(String maintenanceType) {
    switch (maintenanceType) {
      case 'oil': return Icons.oil_barrel;
      case 'tires': return Icons.tire_repair;
      case 'brakes': return Icons.disc_full;
      case 'battery': return Icons.battery_charging_full;
      case 'coolant': return Icons.ac_unit;
      case 'airFilter': return Icons.filter_alt;
      case 'alignment': return Icons.settings_ethernet;
      case 'chain': return Icons.link;
      case 'sparkPlug': return Icons.electrical_services;
      default: return Icons.build;
    }
  }

  String _getMaintenanceDisplayName(String maintenanceType) {
    switch (maintenanceType) {
      case 'oil': return 'Aceite de Motor';
      case 'tires': return 'Llantas';
      case 'brakes': return 'Frenos';
      case 'battery': return 'Batería';
      case 'coolant': return 'Refrigerante';
      case 'airFilter': return 'Filtro de Aire';
      case 'alignment': return 'Alineación y Balanceo';
      case 'chain': return 'Cadena/Kit de Arrastre';
      case 'sparkPlug': return 'Bujía';
      default: return maintenanceType;
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
                  child: Image.asset(
                    vehiculo.tipo == 'carro'
                        ? 'assets/images/vehicles/car_default.png'
                        : 'assets/images/vehicles/motorcycle.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        vehiculo.tipo == 'carro' ? Icons.directions_car : Icons.motorcycle,
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
                _cargarMantenimientos();
                Navigator.pop(context);
              },
            )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _mostrarAgregarMantenimiento() {
    final viewModel = context.read<VehiculoViewModel>();
    if (viewModel.vehiculoActual != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgendarMantenimientoScreen(vehiculo: viewModel.vehiculoActual!),
        ),
      ).then((_) => _cargarMantenimientos());
    }
  }

  Future<void> _cambiarEstadoMantenimiento(Mantenimiento mantenimiento, String nuevoEstado) async {
    await _dbHelper.updateMantenimiento(mantenimiento.copyWith(status: nuevoEstado));
    await _cargarMantenimientos();
    
    // Actualizar el estado del vehículo si se completó el mantenimiento
    if (nuevoEstado == 'completed') {
      final viewModel = context.read<VehiculoViewModel>();
      await viewModel.actualizarKilometraje(viewModel.vehiculoActual!.kilometraje);
    }
  }

  void _mostrarCompletarMantenimiento(Mantenimiento mantenimiento) {
    final TextEditingController kilometrajeRealController = TextEditingController(text: mantenimiento.kilometraje.toString());
    final TextEditingController kilometrajeVehiculoController = TextEditingController(text: context.read<VehiculoViewModel>().vehiculoActual?.kilometraje.toString() ?? '');
    final TextEditingController costoController = TextEditingController(text: mantenimiento.costo > 0 ? mantenimiento.costo.toString() : '');
    final TextEditingController ubicacionController = TextEditingController(text: mantenimiento.ubicacion);
    final TextEditingController notasController = TextEditingController(text: mantenimiento.notas);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AutocarTheme.darkBackground,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            const Text('Completar Mantenimiento', style: TextStyle(color: Colors.white)),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white70),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirma los detalles del mantenimiento completado. El kilometraje del vehículo se actualizará automáticamente.',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 20),
              
              // Confirmar Detalles
              const Text('Confirmar Detalles', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: kilometrajeRealController,
                decoration: const InputDecoration(
                  labelText: 'Kilometraje Real *',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  suffixText: 'km',
                  suffixStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 5),
              Text(
                'Kilometraje exacto cuando se realizó el mantenimiento',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 15),

              // Actualizar Kilometraje del Vehículo
              const Text('Actualizar Kilometraje del Vehículo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: kilometrajeVehiculoController,
                decoration: const InputDecoration(
                  labelText: 'Kilometraje Actual *',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  suffixText: 'km',
                  suffixStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 5),
              Text(
                'Actualiza el kilometraje actual de tu vehículo',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 15),

              // Costo Real
              const Text('Costo Real (Opcional)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: costoController,
                decoration: const InputDecoration(
                  labelText: 'Costo Final',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 5),
              Text(
                'Costo final del mantenimiento',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 15),

              // Taller o Ubicación
              const Text('Taller o Ubicación (Opcional)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Taller o Ubicación',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  hintText: 'Ej: Taller AutoCare, Service Center...',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15),

              // Notas Adicionales
              const Text('Notas Adicionales (Opcional)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final kilometrajeReal = int.tryParse(kilometrajeRealController.text);
                final kilometrajeVehiculo = int.tryParse(kilometrajeVehiculoController.text);
                final costo = double.tryParse(costoController.text) ?? 0.0;

                if (kilometrajeReal == null || kilometrajeVehiculo == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa valores válidos para el kilometraje'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Actualizar el kilometraje del vehículo PRIMERO
                final viewModel = context.read<VehiculoViewModel>();
                await viewModel.actualizarKilometrajeVehiculo(viewModel.vehiculoActual!.id!, kilometrajeVehiculo);

                // Luego usar AutoMaintenanceScheduler para completar el mantenimiento
                await AutoMaintenanceScheduler.completeMaintenance(mantenimiento.id!, viewModel.vehiculoActual!, _dbHelper);

                Navigator.pop(context);
                await _cargarMantenimientos();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mantenimiento completado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Marcar como Completado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editarMantenimiento(Mantenimiento mantenimiento) {
    // TODO: Implementar edición de mantenimiento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de edición próximamente disponible'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _eliminarMantenimiento(Mantenimiento mantenimiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AutocarTheme.darkBackground,
        title: const Text('Eliminar Mantenimiento', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que quieres eliminar este mantenimiento?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.deleteMantenimiento(mantenimiento.id!);
              Navigator.pop(context);
              await _cargarMantenimientos();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mantenimiento eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

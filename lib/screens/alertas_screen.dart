import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehiculo.dart';
import '../viewmodels/vehiculo_viewmodel.dart';
import '../services/maintenance_service.dart';
import '../services/vehicle_image_service.dart';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';

class AlertasScreen extends StatelessWidget {
  const AlertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AutocarTheme.darkBackground,
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
                return _buildSinVehiculos(context);
              }

              return _buildConVehiculos(context, viewModel);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSinVehiculos(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'No hay alertas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Agrega un vehículo para recibir alertas de mantenimiento',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConVehiculos(BuildContext context, VehiculoViewModel viewModel) {
    final alertasCriticas = viewModel.alertasCriticas;
    final alertasNormales = _generarAlertasNormales(viewModel);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Alertas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          if (viewModel.vehiculos.length > 1)
            IconButton(
              onPressed: () => _mostrarSelectorVehiculos(context, viewModel),
              icon: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderMejorado(viewModel.vehiculoActual!, alertasCriticas.length, alertasNormales.length),
            const SizedBox(height: 25),
            
            if (alertasCriticas.isNotEmpty) ...[
              _buildSeccionAlertas(
                context,
                'Alertas Críticas',
                alertasCriticas,
                Colors.redAccent,
                Icons.warning,
              ),
              const SizedBox(height: 25),
            ],
            
            if (alertasNormales.isNotEmpty) ...[
              _buildSeccionAlertas(
                context,
                'Alertas Preventivas',
                alertasNormales,
                Colors.orangeAccent,
                Icons.info,
              ),
            ],
            
            if (alertasCriticas.isEmpty && alertasNormales.isEmpty) ...[
              _buildSinAlertas(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMejorado(Vehiculo vehiculo, int criticas, int normales) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${criticas} críticas • ${normales} preventivas',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    VehicleImageService.getVehicleImagePath(vehiculo.tipo),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        vehiculo.tipo.contains('moto') ? Icons.motorcycle : Icons.directions_car,
                        color: Colors.white,
                        size: 30,
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
                    Text(
                      '${vehiculo.marca} ${vehiculo.modelo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, VehiculoViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AutocarTheme.accentGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AutocarTheme.buttonShadow,
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alertas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Mantenimiento de vehículos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (viewModel.vehiculos.length > 1)
            IconButton(
              onPressed: () => _mostrarSelectorVehiculos(context, viewModel),
              icon: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeccionAlertas(
    BuildContext context,
    String titulo,
    List<MapEntry<String, dynamic>> alertas,
    Color colorPrincipal,
    IconData iconoPrincipal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorPrincipal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                iconoPrincipal,
                color: colorPrincipal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorPrincipal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${alertas.length}',
                style: TextStyle(
                  color: colorPrincipal,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...alertas.map((alerta) => _buildAlertaCardMejorada(context, alerta, colorPrincipal)),
      ],
    );
  }

  Widget _buildAlertaCardMejorada(BuildContext context, MapEntry<String, dynamic> alerta, Color colorPrincipal) {
    final categoria = alerta.key;
    final datos = alerta.value;
    final porcentaje = datos.percentage.round();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
          color: colorPrincipal.withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorPrincipal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                _getMaintenanceIconPath(categoria),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getMaintenanceIconData(categoria),
                    color: colorPrincipal,
                    size: 30,
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
                Text(
                  MaintenanceService.getCategoryDisplayName(categoria),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorPrincipal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estado: $porcentaje%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: porcentaje / 100,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(colorPrincipal),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorPrincipal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorPrincipal, width: 1),
            ),
            child: Text(
              porcentaje < 20 ? 'Crítico' : 'Bajo',
              style: TextStyle(
                color: colorPrincipal,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMaintenanceIconPath(String categoria) {
    switch (categoria) {
      case 'oil': return 'assets/images/maintenance/oil_change.png';
      case 'tires': return 'assets/images/maintenance/tire_rotation.png';
      case 'brakes': return 'assets/images/maintenance/brake_service.png';
      case 'battery': return 'assets/images/maintenance/battery_check.png';
      case 'engine': return 'assets/images/maintenance/engine_service.png';
      case 'transmission': return 'assets/images/maintenance/transmission.png';
      case 'air_filter': return 'assets/images/maintenance/air_filter.png';
      case 'spark_plugs': return 'assets/images/maintenance/spark_plugs.png';
      default: return 'assets/images/maintenance/oil_change.png';
    }
  }

  IconData _getMaintenanceIconData(String categoria) {
    switch (categoria) {
      case 'oil': return Icons.local_gas_station;
      case 'tires': return Icons.tire_repair;
      case 'brakes': return Icons.car_repair;
      case 'battery': return Icons.battery_alert;
      default: return Icons.build;
    }
  }

  Widget _buildAlertaCard(BuildContext context, MapEntry<String, dynamic> alerta, Color color) {
    final categoria = alerta.key;
    final data = alerta.value;
    final porcentaje = data.percentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(MaintenanceService.getMaintenanceIcon(categoria)),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MaintenanceService.getCategoryDisplayName(categoria),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getAlertaDescripcion(categoria, porcentaje, data),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${porcentaje.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinAlertas(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¡Todo en orden!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No hay alertas pendientes para este vehículo',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, dynamic>> _generarAlertasNormales(VehiculoViewModel viewModel) {
    final vehiculo = viewModel.vehiculoActual;
    if (vehiculo == null) return [];

    final alertas = <MapEntry<String, dynamic>>[];
    final maintenanceData = vehiculo.maintenance;

    for (final entry in maintenanceData.entries) {
      final categoria = entry.key;
      final data = entry.value;
      final porcentaje = data.percentage;

      // Alertas normales (no críticas)
      if (porcentaje <= 60 && porcentaje > 10) {
        alertas.add(MapEntry(categoria, data));
      }
    }

    return alertas;
  }

  String _getAlertaDescripcion(String categoria, double porcentaje, dynamic data) {
    if (porcentaje <= 10) {
      return 'Mantenimiento crítico requerido';
    } else if (porcentaje <= 30) {
      return 'Mantenimiento urgente necesario';
    } else if (porcentaje <= 60) {
      return 'Programar mantenimiento pronto';
    } else {
      return 'Estado normal';
    }
  }

  void _mostrarSelectorVehiculos(BuildContext context, VehiculoViewModel viewModel) {
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'oil_barrel': return Icons.oil_barrel;
      case 'directions_car': return Icons.directions_car;
      case 'tire_repair': return Icons.tire_repair;
      case 'disc_full': return Icons.disc_full;
      case 'battery_charging_full': return Icons.battery_charging_full;
      case 'ac_unit': return Icons.ac_unit;
      case 'filter_alt': return Icons.filter_alt;
      case 'settings_ethernet': return Icons.settings_ethernet;
      case 'link': return Icons.link;
      case 'electrical_services': return Icons.electrical_services;
      default: return Icons.build;
    }
  }
}
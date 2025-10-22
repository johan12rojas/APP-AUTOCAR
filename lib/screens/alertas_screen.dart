import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/vehiculo.dart';
import '../models/documento_vehiculo.dart';
import '../models/licencia_conductor.dart';
import '../viewmodels/vehiculo_viewmodel.dart';
import '../services/maintenance_service.dart';
import '../services/vehicle_image_service.dart';
import '../services/documento_service.dart';
import '../services/licencia_service.dart';
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
    final alertasPositivas = _generarAlertasPositivas(viewModel);

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
            _buildHeaderMejorado(viewModel.vehiculoActual!, alertasCriticas.length, alertasNormales.length, alertasPositivas.length),
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
              const SizedBox(height: 25),
            ],
            
            if (alertasPositivas.isNotEmpty) ...[
              _buildSeccionAlertas(
                context,
                'Logros Positivos',
                alertasPositivas,
                Colors.greenAccent,
                Icons.check_circle,
              ),
              const SizedBox(height: 25),
            ],
            
            // Sección de documentos
            _buildSeccionDocumentos(context, viewModel.vehiculoActual!),
            
            // Sección de licencia del conductor
            _buildSeccionLicencia(),
            
            if (alertasCriticas.isEmpty && alertasNormales.isEmpty) ...[
              _buildSinAlertas(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMejorado(Vehiculo vehiculo, int criticas, int normales, int positivas) {
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
          '${criticas} críticas • ${normales} preventivas • ${positivas} logros',
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
                                  size: 30,
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
        color: Colors.white.withOpacity(0.12), // Volver a la transparencia original
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
              color: Colors.white, // Fondo blanco sólido para el badge
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorPrincipal, width: 2),
            ),
            child: Text(
              porcentaje < 20 ? 'Crítico' : porcentaje >= 80 ? 'Excelente' : 'Bajo',
              style: TextStyle(
                color: porcentaje >= 80 ? Colors.green[800] : colorPrincipal, // Verde más oscuro para mejor contraste
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
      case 'coolant': return 'assets/images/maintenance/refrigerante.png';
      case 'airFilter': return 'assets/images/maintenance/air_filter.png';
      case 'alignment': return 'assets/images/maintenance/ali_bal.png';
      case 'chain': return 'assets/images/maintenance/kitarrastre.png';
      case 'sparkPlug': return 'assets/images/maintenance/spark_plugs.png';
      default: return 'assets/images/maintenance/oil_change.png';
    }
  }

  IconData _getMaintenanceIconData(String categoria) {
    switch (categoria) {
      case 'oil': return Icons.local_gas_station;
      case 'tires': return Icons.tire_repair;
      case 'brakes': return Icons.car_repair;
      case 'battery': return Icons.battery_alert;
      case 'alignment': return Icons.settings;
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

  List<MapEntry<String, dynamic>> _generarAlertasPositivas(VehiculoViewModel viewModel) {
    final vehiculo = viewModel.vehiculoActual;
    if (vehiculo == null) return [];

    final alertas = <MapEntry<String, dynamic>>[];
    final maintenanceData = vehiculo.maintenance;

    for (final entry in maintenanceData.entries) {
      final categoria = entry.key;
      final data = entry.value;
      final porcentaje = data.percentage;

      // Alertas positivas (estado excelente)
      if (porcentaje >= 80) {
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
    } else if (porcentaje >= 80) {
      return '¡Excelente estado!';
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

  Widget _buildSeccionDocumentos(BuildContext context, Vehiculo vehiculo) {
    return FutureBuilder<List<DocumentoVehiculo>>(
      future: DocumentoService.getDocumentosByVehiculo(vehiculo.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final documentos = snapshot.data!;
        if (documentos.isEmpty) {
          return const SizedBox.shrink();
        }

        final documentosVencidos = documentos.where((d) => d.vencido).length;
        final documentosPorVencer = documentos.where((d) => d.proximoAVencer).length;
        final documentosAlDia = documentos.where((d) => d.estado == 'Al día').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.folder_open, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tus Documentos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Resumen de documentos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDocumentoResumen('Total', documentos.length.toString(), Colors.white),
                      _buildDocumentoResumen('Al día', documentosAlDia.toString(), Colors.green),
                      _buildDocumentoResumen('Por vencer', documentosPorVencer.toString(), Colors.orange),
                      _buildDocumentoResumen('Vencidos', documentosVencidos.toString(), Colors.red),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Lista de documentos
                  ...documentos.map((documento) => _buildDocumentoCard(documento)).toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentoResumen(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentoCard(DocumentoVehiculo documento) {
    Color statusColor;
    switch (documento.estado) {
      case 'Vencido':
        statusColor = Colors.red;
        break;
      case 'Por vencer':
        statusColor = Colors.orange;
        break;
      case 'Al día':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor,
                    statusColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                documento.tipo == 'tecnomecanica' ? Icons.car_crash :
                documento.tipo == 'seguro' ? Icons.verified_user :
                documento.tipo == 'propiedad' ? Icons.description :
                Icons.insert_drive_file,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documento.tipoDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vence: ${documento.fechaVencimiento}',
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              documento.estado,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionLicencia() {
    return FutureBuilder<LicenciaConductor?>(
      future: LicenciaService.getLicenciaVigente(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final licencia = snapshot.data!;
        
        // Solo mostrar si está próxima a vencer o vencida
        if (licencia.estado == 'Vigente') {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.card_membership, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Licencia del Conductor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildLicenciaCard(licencia),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLicenciaCard(LicenciaConductor licencia) {
    Color statusColor;
    switch (licencia.estado) {
      case 'Vencida':
        statusColor = Colors.red;
        break;
      case 'Por vencer':
        statusColor = Colors.orange;
        break;
      case 'Vigente':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: licencia.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  licencia.icon,
                  color: licencia.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      licencia.categoriaDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'N° ${licencia.numeroLicencia}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  licencia.estado,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expedida:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      licencia.fechaExpedicion,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vence:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      licencia.fechaVencimiento,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (licencia.diasRestantes > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Días restantes: ${licencia.diasRestantes}',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
          if (licencia.restricciones != null && licencia.restricciones!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Restricciones: ${licencia.restricciones}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ],
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
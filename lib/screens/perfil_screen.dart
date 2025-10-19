import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/vehiculo.dart';
import '../viewmodels/vehiculo_viewmodel.dart';
import '../widgets/background_widgets.dart';
import '../database/database_helper.dart';
import '../services/vehicle_image_service.dart';
import '../services/user_preferences_service.dart';
import '../services/pdf_export_service.dart';
import 'vehicle_form_screen.dart';
import 'agregar_vehiculo_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();
  String _nombreUsuario = 'Usuario AUTOCAR';
  String _emailUsuario = 'usuario@autocar.com';
  File? _imagenPerfil;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos del usuario cuando cambian las dependencias
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final nombre = await UserPreferencesService.obtenerNombreUsuario();
    final email = await UserPreferencesService.obtenerEmailUsuario();
    final rutaImagen = await UserPreferencesService.obtenerImagenPerfil();
    setState(() {
      _nombreUsuario = nombre;
      _emailUsuario = email;
      if (rutaImagen != null) {
        _imagenPerfil = File(rutaImagen);
      }
    });
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
            'Perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<VehiculoViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPerfilUsuario(),
                  const SizedBox(height: 25),
                  _buildControlGastosMejorado(viewModel),
                  const SizedBox(height: 25),
                  _buildRecomendacionesInteligentes(viewModel),
                  const SizedBox(height: 25),
                  _buildVehiculosSection(viewModel),
                  const SizedBox(height: 25),
                  _buildAccionesRapidas(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPerfilUsuario() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _mostrarOpcionesImagen,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              backgroundImage: _imagenPerfil != null ? FileImage(_imagenPerfil!) : null,
              child: _imagenPerfil == null ? const Icon(
                Icons.person,
                size: 35,
                color: Colors.white,
              ) : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nombreUsuario,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _emailUsuario,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _mostrarEditarPerfil,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Editar Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlGastosMejorado(VehiculoViewModel viewModel) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _obtenerDatosGastos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orangeAccent.withValues(alpha: 0.8),
                  Colors.deepOrangeAccent.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        final datos = snapshot.data ?? {};
        final gastosTotales = datos['total'] ?? 0.0;
        final gastosMes = datos['mes'] ?? 0.0;
        final gastosPorCategoria = datos['categorias'] ?? <String, double>{};

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orangeAccent.withValues(alpha: 0.8),
                Colors.deepOrangeAccent.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Control de Gastos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Resumen financiero',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildGastoCard(
                      'Total',
                      '\$${gastosTotales.toStringAsFixed(0)}',
                      Icons.attach_money,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGastoCard(
                      'Este Mes',
                      '\$${gastosMes.toStringAsFixed(0)}',
                      Icons.calendar_month,
                      Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Resumen de Gastos',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGastoCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaGastoCard(String categoria, double monto, double porcentaje) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForCategory(categoria),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: porcentaje,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${monto.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'aceite':
        return Icons.oil_barrel;
      case 'frenos':
        return Icons.stop_circle;
      case 'llantas':
        return Icons.tire_repair;
      case 'batería':
        return Icons.battery_charging_full;
      case 'filtros':
        return Icons.filter_alt;
      case 'alineación':
        return Icons.settings;
      default:
        return Icons.build;
    }
  }

  Widget _buildVehiculosSection(VehiculoViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mis Vehículos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${viewModel.vehiculos.length} vehículo${viewModel.vehiculos.length != 1 ? 's' : ''} registrado${viewModel.vehiculos.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VehicleFormScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Agregar vehículo',
                  ),
                  IconButton(
                    onPressed: () => _mostrarSelectorVehiculos(context, viewModel),
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    tooltip: 'Cambiar vehículo',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...viewModel.vehiculos.map((vehiculo) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildVehiculoCard(vehiculo, viewModel),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVehiculoCard(Vehiculo vehiculo, VehiculoViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: vehiculo.imagenPersonalizada != null && vehiculo.imagenPersonalizada!.isNotEmpty
                  ? Image.file(
                      File(vehiculo.imagenPersonalizada!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Si la imagen personalizada no se puede cargar, usar la predeterminada
                        return Image.asset(
                          VehicleImageService.getVehicleImagePath(vehiculo.tipo),
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      VehicleImageService.getVehicleImagePath(vehiculo.tipo),
                      fit: BoxFit.cover,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${vehiculo.ano} • ${vehiculo.kilometraje} km',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'editar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehicleFormScreen(vehiculo: vehiculo),
                  ),
                );
              } else if (value == 'eliminar') {
                _mostrarConfirmacionEliminarVehiculo(context, vehiculo, viewModel);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesRapidas() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acciones Rápidas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Herramientas y configuraciones',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildAccionCardMejorado(
                'Exportar PDF',
                'Generar reporte',
                Icons.picture_as_pdf,
                Colors.white,
                _exportarDatos,
              ),
              _buildAccionCardMejorado(
                'Respaldar',
                'Guardar datos',
                Icons.backup,
                Colors.white,
                _respaldarDatos,
              ),
              _buildAccionCardMejorado(
                'Configuración',
                'Ajustes app',
                Icons.settings,
                Colors.white,
                _mostrarConfiguracion,
              ),
              _buildAccionCardMejorado(
                'Acerca de',
                'Información',
                Icons.info,
                Colors.white,
                _mostrarAcercaDe,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccionCardMejorado(String titulo, String subtitulo, IconData icono, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _obtenerDatosGastos() async {
    final mantenimientos = await _dbHelper.getAllMantenimientos();
    final mantenimientosCompletados = mantenimientos.where((m) => m.status == 'completed').toList();
    
    double gastosTotales = 0.0;
    double gastosMes = 0.0;
    Map<String, double> gastosPorCategoria = {};
    
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    
    for (final mantenimiento in mantenimientosCompletados) {
      final costo = mantenimiento.costo;
      gastosTotales += costo;
      
      if (mantenimiento.fecha.isAfter(inicioMes)) {
        gastosMes += costo;
      }
      
      gastosPorCategoria[mantenimiento.tipo] = 
          (gastosPorCategoria[mantenimiento.tipo] ?? 0.0) + costo;
    }
    
    return {
      'total': gastosTotales,
      'mes': gastosMes,
      'categorias': gastosPorCategoria,
    };
  }

  void _mostrarSelectorVehiculos(BuildContext context, VehiculoViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E3A8A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Vehículo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...viewModel.vehiculos.map((vehiculo) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      VehicleImageService.getVehicleImagePath(vehiculo.tipo),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  '${vehiculo.marca} ${vehiculo.modelo}',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${vehiculo.ano} • ${vehiculo.kilometraje} km',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  viewModel.cambiarVehiculoActual(vehiculo);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _mostrarEditarPerfil() {
    final nombreController = TextEditingController(text: _nombreUsuario);
    final emailController = TextEditingController(text: _emailUsuario);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'Editar Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los cambios se guardarán automáticamente',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
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
              await UserPreferencesService.guardarNombreUsuario(nombreController.text);
              await UserPreferencesService.guardarEmailUsuario(emailController.text);
              setState(() {
                _nombreUsuario = nombreController.text;
                _emailUsuario = emailController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Perfil actualizado correctamente',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E3A8A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Cambiar foto de perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Elegir de galería', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Tomar foto', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            if (_imagenPerfil != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    _imagenPerfil = null;
                  });
                  // Eliminar la imagen de las preferencias
                  await UserPreferencesService.eliminarImagenPerfil();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Foto eliminada',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _imagenPerfil = File(image.path);
        });
        
        // Guardar la ruta de la imagen
        await UserPreferencesService.guardarImagenPerfil(image.path);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Foto actualizada correctamente',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al seleccionar imagen: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _mostrarEditarVehiculo(Vehiculo vehiculo, VehiculoViewModel viewModel) {
    // Implementar edición de vehículo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de edición en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }


  void _exportarDatos() async {
    try {
      final viewModel = context.read<VehiculoViewModel>();
      await PdfExportService.exportVehiculosToPdf(context, viewModel.vehiculos, viewModel.mantenimientos);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'PDF exportado correctamente',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al exportar: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _respaldarDatos() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Función de respaldo en desarrollo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _mostrarConfiguracion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Configuración en desarrollo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _mostrarAcercaDe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'AUTOCAR',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Versión 1.0.0',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Tu aplicación de gestión vehicular inteligente. Mantén el control total de tus vehículos y sus mantenimientos.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Características:\n• Gestión multi-vehículo\n• Programación automática\n• Control de gastos\n• Exportación PDF\n• Alertas inteligentes',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendacionesInteligentes(VehiculoViewModel viewModel) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _obtenerRecomendaciones(viewModel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Error al cargar recomendaciones',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final recomendaciones = snapshot.data!;
        final alertasCriticas = recomendaciones['alertasCriticas'] as List<Map<String, dynamic>>;
        final recomendacionesGasto = recomendaciones['recomendacionesGasto'] as List<String>;
        final consejosAhorro = recomendaciones['consejosAhorro'] as List<String>;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(4, 4),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Recomendaciones Inteligentes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Alertas Críticas
              if (alertasCriticas.isNotEmpty) ...[
                _buildSeccionRecomendacion(
                  '🚨 Alertas Críticas',
                  Colors.red,
                  alertasCriticas.map((alerta) => _buildAlertaCritica(alerta)).toList(),
                ),
              ],

              // Recomendaciones de Gasto
              if (recomendacionesGasto.isNotEmpty) ...[
                _buildSeccionRecomendacion(
                  '💰 Análisis de Gastos',
                  Colors.orange,
                  recomendacionesGasto.map((recomendacion) => _buildRecomendacionItem(recomendacion)).toList(),
                ),
              ],

              // Consejos de Ahorro
              if (consejosAhorro.isNotEmpty) ...[
                _buildSeccionRecomendacion(
                  '💡 Consejos de Ahorro',
                  Colors.green,
                  consejosAhorro.map((consejo) => _buildRecomendacionItem(consejo)).toList(),
                ),
              ],

              // Si no hay recomendaciones
              if (alertasCriticas.isEmpty && recomendacionesGasto.isEmpty && consejosAhorro.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '¡Todo se ve excelente! Tus vehículos están en buen estado y tus gastos están bajo control.',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeccionRecomendacion(String titulo, Color color, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForSection(titulo),
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  IconData _getIconForSection(String titulo) {
    if (titulo.contains('Alertas')) return Icons.warning_rounded;
    if (titulo.contains('Gastos')) return Icons.analytics_rounded;
    if (titulo.contains('Ahorro')) return Icons.savings_rounded;
    return Icons.info_rounded;
  }

  Widget _buildAlertaCritica(Map<String, dynamic> alerta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.15),
            Colors.red.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta['titulo'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alerta['descripcion'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendacionItem(String texto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _obtenerRecomendaciones(VehiculoViewModel viewModel) async {
    final mantenimientos = await _dbHelper.getAllMantenimientos();
    final mantenimientosCompletados = mantenimientos.where((m) => m.status == 'completed').toList();
    
    // Calcular gastos por categoría
    Map<String, double> gastosPorCategoria = {};
    double gastoTotal = 0.0;
    
    for (final mantenimiento in mantenimientosCompletados) {
      final costo = mantenimiento.costo;
      gastoTotal += costo;
      gastosPorCategoria[mantenimiento.tipo] = 
          (gastosPorCategoria[mantenimiento.tipo] ?? 0.0) + costo;
    }

    // Analizar estado crítico de componentes
    List<Map<String, dynamic>> alertasCriticas = [];
    if (viewModel.vehiculoActual != null) {
      final vehiculo = viewModel.vehiculoActual!;
      vehiculo.maintenance.forEach((categoria, datos) {
        if (datos.percentage <= 20) {
          alertasCriticas.add({
            'titulo': '${_getCategoriaNombre(categoria)} - Estado Crítico',
            'descripcion': 'Solo queda ${datos.percentage.toStringAsFixed(0)}% de vida útil. Considera revisión inmediata.',
            'categoria': categoria,
            'porcentaje': datos.percentage,
          });
        }
      });
    }

    // Recomendaciones basadas en gastos
    List<String> recomendacionesGasto = [];
    if (gastoTotal > 0) {
      // Encontrar la categoría con más gastos
      String categoriaMasGasto = '';
      double mayorGasto = 0.0;
      gastosPorCategoria.forEach((categoria, gasto) {
        if (gasto > mayorGasto) {
          mayorGasto = gasto;
          categoriaMasGasto = categoria;
        }
      });

      if (categoriaMasGasto.isNotEmpty) {
        final porcentaje = (mayorGasto / gastoTotal * 100).toStringAsFixed(1);
        recomendacionesGasto.add(
          'El ${_getCategoriaNombre(categoriaMasGasto).toLowerCase()} representa el $porcentaje% de tus gastos totales (${mayorGasto.toStringAsFixed(0)} pesos)'
        );
      }

      // Análisis de frecuencia de gastos
      if (mantenimientosCompletados.length > 3) {
        recomendacionesGasto.add(
          'Has realizado ${mantenimientosCompletados.length} mantenimientos. Considera un programa preventivo más estricto.'
        );
      }
    }

    // Consejos de ahorro
    List<String> consejosAhorro = [];
    
    if (gastoTotal > 100000) {
      consejosAhorro.add('Con un gasto total de ${gastoTotal.toStringAsFixed(0)} pesos, considera buscar proveedores alternativos');
    }
    
    if (alertasCriticas.isNotEmpty) {
      consejosAhorro.add('Revisa los componentes críticos pronto para evitar costos mayores');
    }
    
    consejosAhorro.add('Programa mantenimientos preventivos para reducir gastos futuros');
    consejosAhorro.add('Compara precios entre diferentes talleres antes de realizar mantenimientos');
    
    if (gastosPorCategoria.length > 2) {
      consejosAhorro.add('Mantén un registro detallado de gastos por categoría para mejor control');
    }

    return {
      'alertasCriticas': alertasCriticas,
      'recomendacionesGasto': recomendacionesGasto,
      'consejosAhorro': consejosAhorro,
    };
  }

  String _getCategoriaNombre(String categoria) {
    const nombres = {
      'oil': 'Aceite de Motor',
      'tires': 'Llantas',
      'brakes': 'Frenos',
      'battery': 'Batería',
      'coolant': 'Refrigerante',
      'airFilter': 'Filtro de Aire',
      'alignment': 'Alineación y Balanceo',
      'chain': 'Cadena/Kit de Arrastre',
      'sparkPlug': 'Bujía',
    };
    return nombres[categoria] ?? categoria;
  }



  void _mostrarConfirmacionEliminarVehiculo(BuildContext context, Vehiculo vehiculo, VehiculoViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        title: const Text(
          'Eliminar Vehículo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar ${vehiculo.marca} ${vehiculo.modelo}?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await viewModel.eliminarVehiculo(vehiculo.id!);
                Navigator.pop(context);
                _mostrarSnackBar('Vehículo eliminado correctamente', Colors.green);
              } catch (e) {
                _mostrarSnackBar('Error al eliminar vehículo: $e', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
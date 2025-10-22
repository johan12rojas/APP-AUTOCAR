import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';
import '../models/mantenimiento.dart';
import '../services/maintenance_data_service.dart';

class CompletarMantenimientoScreen extends StatefulWidget {
  final Mantenimiento mantenimiento;

  const CompletarMantenimientoScreen({
    super.key,
    required this.mantenimiento,
  });

  @override
  State<CompletarMantenimientoScreen> createState() => _CompletarMantenimientoScreenState();
}

class _CompletarMantenimientoScreenState extends State<CompletarMantenimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kilometrajeRealController = TextEditingController();
  final _kilometrajeVehiculoController = TextEditingController();
  final _costoRealController = TextEditingController();
  final _notasRealesController = TextEditingController();
  final _ubicacionRealController = TextEditingController();
  
  DateTime _fechaReal = DateTime.now();
  MaintenanceInfo? _maintenanceInfo;

  @override
  void initState() {
    super.initState();
    // Los controladores se inicializan aquí
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-llenar campos después de que los controladores estén listos
    _prefillFields();
  }

  void _prefillFields() {
    // Obtener información específica del tipo de mantenimiento
    _maintenanceInfo = MaintenanceDataService.getMaintenanceInfo(widget.mantenimiento.tipo);
    
    // Debug: imprimir información
    print('🔧 Tipo de mantenimiento: ${widget.mantenimiento.tipo}');
    print('📋 MaintenanceInfo encontrado: ${_maintenanceInfo != null}');
    
    if (_maintenanceInfo != null) {
      print('✅ Pre-llenando con datos específicos para Cúcuta');
      _costoRealController.text = _maintenanceInfo!.costoEstimado.toString();
      _ubicacionRealController.text = _maintenanceInfo!.tallerRecomendado;
      _notasRealesController.text = _maintenanceInfo!.descripcion;
      print('💰 Costo: ${_maintenanceInfo!.costoEstimado}');
      print('🏪 Taller: ${_maintenanceInfo!.tallerRecomendado}');
    } else {
      print('⚠️ Usando datos del mantenimiento programado');
      // Fallback a valores del mantenimiento programado
      _costoRealController.text = widget.mantenimiento.costo > 0 
          ? widget.mantenimiento.costo.toString() 
          : '';
      _notasRealesController.text = widget.mantenimiento.notas;
      _ubicacionRealController.text = widget.mantenimiento.ubicacion;
    }
  }

  @override
  void dispose() {
    _kilometrajeRealController.dispose();
    _kilometrajeVehiculoController.dispose();
    _costoRealController.dispose();
    _notasRealesController.dispose();
    _ubicacionRealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AutocarTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Completar Mantenimiento',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: AutocarTheme.darkBackground,
        foregroundColor: AutocarTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BackgroundGradientWidget(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMantenimientoInfo(),
                const SizedBox(height: 30),
                _buildKilometrajeReal(),
                const SizedBox(height: 20),
                _buildFechaReal(),
                const SizedBox(height: 20),
                _buildKilometrajeVehiculo(),
                const SizedBox(height: 20),
                _buildCostoReal(),
                const SizedBox(height: 20),
                _buildUbicacionReal(),
                const SizedBox(height: 20),
                _buildNotasReales(),
                const SizedBox(height: 40),
                _buildBotonCompletar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMantenimientoInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AutocarTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AutocarTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getIconData(widget.mantenimiento.tipo),
                color: AutocarTheme.accentOrange,
                size: 30,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  widget.mantenimiento.tipoDisplayName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AutocarTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Información específica del mantenimiento si está disponible
          if (_maintenanceInfo != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AutocarTheme.cardBackground.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AutocarTheme.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AutocarTheme.accentOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Información Específica para Cúcuta',
                        style: TextStyle(
                          color: AutocarTheme.accentOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _maintenanceInfo!.descripcion,
                    style: TextStyle(
                      color: AutocarTheme.textPrimary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duración estimada: ${_maintenanceInfo!.duracionEstimada}',
                    style: TextStyle(
                      color: AutocarTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                'Programado',
                '${widget.mantenimiento.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
                Icons.schedule,
              ),
              _buildInfoItem(
                'Fecha',
                '${widget.mantenimiento.fecha.day}/${widget.mantenimiento.fecha.month}/${widget.mantenimiento.fecha.year}',
                Icons.calendar_today,
              ),
              if (_maintenanceInfo != null)
                _buildInfoItem(
                  'Costo Est.',
                  '\$${_maintenanceInfo!.costoEstimado.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  Icons.attach_money,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AutocarTheme.textSecondary,
          size: 20,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AutocarTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildKilometrajeReal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kilometraje Real del Mantenimiento *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _kilometrajeRealController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Kilometraje exacto cuando se realizó',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            suffixText: 'km',
            suffixStyle: TextStyle(color: AutocarTheme.textSecondary),
            filled: true,
            fillColor: AutocarTheme.cardBackground.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AutocarTheme.accentOrange,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El kilometraje real es obligatorio';
            }
            final kilometraje = int.tryParse(value);
            if (kilometraje == null) {
              return 'Ingresa un número válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFechaReal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha Real de Completado',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final fecha = await showDatePicker(
              context: context,
              initialDate: _fechaReal,
              firstDate: widget.mantenimiento.fecha.subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AutocarTheme.accentOrange,
                      surface: AutocarTheme.cardBackground,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (fecha != null) {
              setState(() {
                _fechaReal = fecha;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AutocarTheme.cardBackground.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AutocarTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  '${_fechaReal.day}/${_fechaReal.month}/${_fechaReal.year}',
                  style: TextStyle(
                    color: AutocarTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKilometrajeVehiculo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actualizar Kilometraje del Vehículo *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _kilometrajeVehiculoController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Kilometraje actual del vehículo',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            suffixText: 'km',
            suffixStyle: TextStyle(color: AutocarTheme.textSecondary),
            filled: true,
            fillColor: AutocarTheme.cardBackground.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AutocarTheme.accentOrange,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El kilometraje del vehículo es obligatorio';
            }
            final kilometraje = int.tryParse(value);
            if (kilometraje == null) {
              return 'Ingresa un número válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Este será el nuevo kilometraje actual de tu vehículo',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AutocarTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCostoReal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Costo Real',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AutocarTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_maintenanceInfo != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pre-llenado',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _costoRealController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Costo real del mantenimiento',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            prefixText: '\$ ',
            prefixStyle: TextStyle(color: AutocarTheme.textSecondary),
            suffixText: 'COP',
            suffixStyle: TextStyle(
              color: AutocarTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: AutocarTheme.cardBackground.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AutocarTheme.accentOrange,
                width: 2,
              ),
            ),
          ),
        ),
        if (_maintenanceInfo != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Costo estimado para Cúcuta:',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$${_maintenanceInfo!.costoEstimado.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} COP',
                        style: TextStyle(
                          color: AutocarTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUbicacionReal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Taller o Ubicación Real',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AutocarTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_maintenanceInfo != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AutocarTheme.accentOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Recomendado',
                  style: TextStyle(
                    color: AutocarTheme.accentOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _ubicacionRealController,
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Dónde se realizó el mantenimiento',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            filled: true,
            fillColor: AutocarTheme.cardBackground.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AutocarTheme.accentOrange,
                width: 2,
              ),
            ),
          ),
        ),
        if (_maintenanceInfo != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AutocarTheme.cardBackground.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AutocarTheme.accentOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AutocarTheme.accentOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Taller Recomendado:',
                      style: TextStyle(
                        color: AutocarTheme.accentOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _maintenanceInfo!.tallerRecomendado,
                  style: TextStyle(
                    color: AutocarTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _maintenanceInfo!.ubicacionTaller,
                  style: TextStyle(
                    color: AutocarTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotasReales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas del Mantenimiento Realizado',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _notasRealesController,
          maxLines: 3,
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Detalles de lo que se hizo...',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            filled: true,
            fillColor: AutocarTheme.cardBackground.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AutocarTheme.accentOrange,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonCompletar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _completarMantenimiento,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
          shadowColor: Colors.green.withValues(alpha: 0.3),
        ),
        child: const Text(
          'Marcar como Completado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _completarMantenimiento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final kilometrajeReal = int.parse(_kilometrajeRealController.text);
    final kilometrajeVehiculo = int.parse(_kilometrajeVehiculoController.text);

    // Validar que el kilometraje del vehículo sea mayor o igual al real del mantenimiento
    if (kilometrajeVehiculo < kilometrajeReal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El kilometraje del vehículo debe ser mayor o igual al del mantenimiento'),
        ),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Completado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mantenimiento: ${widget.mantenimiento.tipoDisplayName}'),
            Text('Kilometraje real: ${kilometrajeReal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km'),
            Text('Fecha: ${_fechaReal.day}/${_fechaReal.month}/${_fechaReal.year}'),
            Text('Nuevo kilometraje vehículo: ${kilometrajeVehiculo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km'),
            if (_costoRealController.text.isNotEmpty)
              Text('Costo real: \$${_costoRealController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Aquí se llamaría al ViewModel para completar el mantenimiento
      // Por ahora solo cerramos la pantalla
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mantenimiento de ${widget.mantenimiento.tipoDisplayName} completado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  IconData _getIconData(String tipo) {
    switch (tipo) {
      case 'oil': return Icons.oil_barrel;
      case 'tires': return Icons.directions_car;
      case 'brakes': return Icons.stop_circle;
      case 'battery': return Icons.battery_charging_full;
      case 'coolant': return Icons.thermostat;
      case 'airFilter': return Icons.air;
      case 'alignment': return Icons.settings;
      case 'chain': return Icons.link;
      case 'sparkPlug': return Icons.flash_on;
      default: return Icons.build;
    }
  }
}

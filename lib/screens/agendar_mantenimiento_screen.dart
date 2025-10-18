import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';
import '../models/vehiculo.dart';
import '../services/maintenance_service.dart';

class AgendarMantenimientoScreen extends StatefulWidget {
  final Vehiculo vehiculo;

  const AgendarMantenimientoScreen({
    super.key,
    required this.vehiculo,
  });

  @override
  State<AgendarMantenimientoScreen> createState() => _AgendarMantenimientoScreenState();
}

class _AgendarMantenimientoScreenState extends State<AgendarMantenimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kilometrajeController = TextEditingController();
  final _costoController = TextEditingController();
  final _notasController = TextEditingController();
  final _ubicacionController = TextEditingController();
  
  String _tipoSeleccionado = '';
  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    // Seleccionar el primer tipo disponible por defecto
    final tiposDisponibles = MaintenanceService.getAvailableCategories(widget.vehiculo.tipo);
    if (tiposDisponibles.isNotEmpty) {
      _tipoSeleccionado = tiposDisponibles.first;
    }
  }

  @override
  void dispose() {
    _kilometrajeController.dispose();
    _costoController.dispose();
    _notasController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AutocarTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Agendar Mantenimiento'),
        backgroundColor: AutocarTheme.darkBackground,
        foregroundColor: AutocarTheme.textPrimary,
        elevation: 0,
      ),
      body: BackgroundGradientWidget(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVehiculoInfo(),
                const SizedBox(height: 30),
                _buildTipoMantenimiento(),
                const SizedBox(height: 20),
                _buildKilometrajeProgramado(),
                const SizedBox(height: 20),
                _buildFechaProgramada(),
                const SizedBox(height: 20),
                _buildCostoEstimado(),
                const SizedBox(height: 20),
                _buildUbicacion(),
                const SizedBox(height: 20),
                _buildNotas(),
                const SizedBox(height: 40),
                _buildBotonAgendar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehiculoInfo() {
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
          Text(
            '${widget.vehiculo.marca} ${widget.vehiculo.modelo} ${widget.vehiculo.ano}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AutocarTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Kilometraje actual: ${widget.vehiculo.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AutocarTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoMantenimiento() {
    final tiposDisponibles = MaintenanceService.getAvailableCategories(widget.vehiculo.tipo);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Mantenimiento *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: AutocarTheme.cardBackground.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AutocarTheme.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tipoSeleccionado.isEmpty ? null : _tipoSeleccionado,
              hint: Text(
                'Selecciona el tipo de mantenimiento',
                style: TextStyle(
                  color: AutocarTheme.textSecondary,
                ),
              ),
              dropdownColor: AutocarTheme.cardBackground,
              style: TextStyle(
                color: AutocarTheme.textPrimary,
              ),
              items: tiposDisponibles.map((tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Row(
                    children: [
                      Icon(
                        _getIconData(MaintenanceService.getMaintenanceIcon(tipo)),
                        color: AutocarTheme.accentOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(MaintenanceService.getCategoryDisplayName(tipo)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _tipoSeleccionado = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKilometrajeProgramado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kilometraje Programado *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _kilometrajeController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: ${widget.vehiculo.kilometraje + 5000}',
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
              return 'El kilometraje es obligatorio';
            }
            final kilometraje = int.tryParse(value);
            if (kilometraje == null) {
              return 'Ingresa un número válido';
            }
            if (kilometraje <= widget.vehiculo.kilometraje) {
              return 'Debe ser mayor al kilometraje actual';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFechaProgramada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha Programada',
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
              initialDate: _fechaSeleccionada,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
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
                _fechaSeleccionada = fecha;
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
                  '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
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

  Widget _buildCostoEstimado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Costo Estimado',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _costoController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: 50000',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            prefixText: '\$ ',
            prefixStyle: TextStyle(color: AutocarTheme.textSecondary),
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

  Widget _buildUbicacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Taller o Ubicación',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _ubicacionController,
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: AutoCare Service',
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

  Widget _buildNotas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas Adicionales',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _notasController,
          maxLines: 3,
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Detalles adicionales o recordatorios...',
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

  Widget _buildBotonAgendar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _agendarMantenimiento,
        style: ElevatedButton.styleFrom(
          backgroundColor: AutocarTheme.accentOrange,
          foregroundColor: AutocarTheme.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
          shadowColor: AutocarTheme.accentOrange.withValues(alpha: 0.3),
        ),
        child: const Text(
          'Agendar Mantenimiento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _agendarMantenimiento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tipoSeleccionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un tipo de mantenimiento'),
        ),
      );
      return;
    }

    // Validar datos adicionales
    final kilometrajeProgramado = int.parse(_kilometrajeController.text);
    final validationError = MaintenanceService.validateScheduledMaintenance(
      currentMileage: widget.vehiculo.kilometraje,
      scheduledMileage: kilometrajeProgramado,
      scheduledDate: _fechaSeleccionada,
    );

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Mantenimiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${MaintenanceService.getCategoryDisplayName(_tipoSeleccionado)}'),
            Text('Kilometraje: ${kilometrajeProgramado.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km'),
            Text('Fecha: ${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
            if (_costoController.text.isNotEmpty)
              Text('Costo estimado: \$${_costoController.text}'),
            if (_ubicacionController.text.isNotEmpty)
              Text('Ubicación: ${_ubicacionController.text}'),
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
      // Aquí se llamaría al ViewModel para agendar el mantenimiento
      // Por ahora solo cerramos la pantalla
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mantenimiento de ${MaintenanceService.getCategoryDisplayName(_tipoSeleccionado)} agendado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
}

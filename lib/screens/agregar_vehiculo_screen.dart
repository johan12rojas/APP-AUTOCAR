import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';
import '../viewmodels/vehiculo_viewmodel.dart';
import '../services/vehicle_image_service.dart';
import '../models/vehiculo.dart';

class AgregarVehiculoScreen extends StatefulWidget {
  const AgregarVehiculoScreen({super.key});

  @override
  State<AgregarVehiculoScreen> createState() => _AgregarVehiculoScreenState();
}

class _AgregarVehiculoScreenState extends State<AgregarVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _placaController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  
  String _tipoSeleccionado = 'Carro';

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _placaController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AutocarTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Agregar Vehículo'),
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
                _buildHeader(),
                const SizedBox(height: 30),
                _buildTipoVehiculo(),
                const SizedBox(height: 20),
                _buildMarca(),
                const SizedBox(height: 20),
                _buildModelo(),
                const SizedBox(height: 20),
                _buildAno(),
                const SizedBox(height: 20),
                _buildPlaca(),
                const SizedBox(height: 20),
                _buildKilometraje(),
                const SizedBox(height: 40),
                _buildBotonGuardar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AutocarTheme.accentGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AutocarTheme.buttonShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logos/icon_app.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_car,
                    size: 40,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Nuevo Vehículo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AutocarTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega la información de tu vehículo para comenzar a gestionar sus mantenimientos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AutocarTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipoVehiculo() {
    final tiposVehiculos = VehicleImageService.getAvailableVehicleTypes();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Vehículo *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
          ),
          itemCount: tiposVehiculos.length,
          itemBuilder: (context, index) {
            final tipo = tiposVehiculos[index];
            final tipoKey = VehicleImageService.getVehicleTypeForImage(tipo);
            final imagePath = VehicleImageService.getVehicleImagePath(tipoKey);
            final isSelected = _tipoSeleccionado == tipo;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _tipoSeleccionado = tipo;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFF6B35).withValues(alpha: 0.2),
                            const Color(0xFFFF8A65).withValues(alpha: 0.1),
                          ],
                        )
                      : null,
                  color: isSelected 
                      ? null
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFFFF6B35).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              tipo.toLowerCase().contains('moto') 
                                  ? Icons.motorcycle 
                                  : Icons.directions_car,
                              color: isSelected 
                                  ? const Color(0xFFFF6B35)
                                  : Colors.white.withValues(alpha: 0.7),
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tipo,
                      style: TextStyle(
                        color: isSelected 
                            ? const Color(0xFFFF6B35)
                            : Colors.white.withValues(alpha: 0.8),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTipoOption(String tipo, String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoSeleccionado = tipo;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected 
              ? AutocarTheme.accentOrange.withValues(alpha: 0.2)
              : AutocarTheme.cardBackground.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected 
                ? AutocarTheme.accentOrange
                : AutocarTheme.textSecondary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AutocarTheme.accentOrange : AutocarTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarca() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marca *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _marcaController,
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: Toyota, Honda, BMW',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            prefixIcon: Icon(
              Icons.branding_watermark,
              color: AutocarTheme.textSecondary,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La marca es obligatoria';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModelo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modelo *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _modeloController,
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: Corolla, Civic, X3',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            prefixIcon: Icon(
              Icons.model_training,
              color: AutocarTheme.textSecondary,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El modelo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAno() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Año *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _anoController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: 2020',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            prefixIcon: Icon(
              Icons.calendar_today,
              color: AutocarTheme.textSecondary,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El año es obligatorio';
            }
            final ano = int.tryParse(value);
            if (ano == null) {
              return 'Ingresa un año válido';
            }
            final currentYear = DateTime.now().year;
            if (ano < 1900 || ano > currentYear + 1) {
              return 'Ingresa un año entre 1900 y ${currentYear + 1}';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPlaca() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Placa *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AutocarTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _placaController,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(color: AutocarTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: ABC123',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            prefixIcon: Icon(
              Icons.confirmation_number,
              color: AutocarTheme.textSecondary,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La placa es obligatoria';
            }
            if (value.length < 3) {
              return 'La placa debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKilometraje() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kilometraje Actual *',
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
            hintText: 'Ej: 45000',
            hintStyle: TextStyle(color: AutocarTheme.textSecondary),
            prefixIcon: Icon(
              Icons.speed,
              color: AutocarTheme.textSecondary,
            ),
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
              return 'Ingresa un kilometraje válido';
            }
            if (kilometraje < 0) {
              return 'El kilometraje no puede ser negativo';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Este será el kilometraje inicial de tu vehículo. Todos los mantenimientos se calcularán desde este punto.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AutocarTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardarVehiculo,
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
          'Agregar Vehículo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Vehículo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${_tipoSeleccionado.toUpperCase()}'),
            Text('Marca: ${_marcaController.text}'),
            Text('Modelo: ${_modeloController.text}'),
            Text('Año: ${_anoController.text}'),
            Text('Placa: ${_placaController.text.toUpperCase()}'),
            Text('Kilometraje: ${_kilometrajeController.text} km'),
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
      // Usar el ViewModel para agregar el vehículo
      final viewModel = context.read<VehiculoViewModel>();
      
      try {
        // Crear el vehículo usando Vehiculo.nuevo() directamente
        final nuevoVehiculo = Vehiculo.nuevo(
          marca: _marcaController.text.trim(),
          modelo: _modeloController.text.trim(),
          ano: int.parse(_anoController.text.trim()),
          placa: _placaController.text.trim().toUpperCase(),
          tipo: VehicleImageService.getVehicleTypeForImage(_tipoSeleccionado),
          kilometraje: int.parse(_kilometrajeController.text.trim()),
          imagenPersonalizada: null, // No hay imagen personalizada en este formulario
        );
        
        // Usar el método que funciona en VehicleFormScreen
        await viewModel.agregarVehiculo(nuevoVehiculo);
        
        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_marcaController.text} ${_modeloController.text} agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar vehículo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

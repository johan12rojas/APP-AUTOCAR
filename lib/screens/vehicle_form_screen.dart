import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/vehiculo.dart';
import '../viewmodels/vehiculo_viewmodel.dart';
import '../services/vehicle_image_service.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehiculo? vehiculo; // Si es null, es para agregar; si tiene valor, es para editar

  const VehicleFormScreen({super.key, this.vehiculo});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  
  String _tipoSeleccionado = 'Carro';
  String _marcaSeleccionada = 'Toyota';
  String _modeloSeleccionado = 'Corolla';
  bool _esPersonalizado = false;
  File? _imagenSeleccionada;

  @override
  void initState() {
    super.initState();
      if (widget.vehiculo != null) {
      // Modo edición
      _tipoSeleccionado = _getDisplayNameForType(widget.vehiculo!.tipo);
      _anoController.text = widget.vehiculo!.ano.toString();
      _kilometrajeController.text = widget.vehiculo!.kilometraje.toString();
      
      // Cargar imagen personalizada si existe
      if (widget.vehiculo!.imagenPersonalizada != null && 
          widget.vehiculo!.imagenPersonalizada!.isNotEmpty) {
        _imagenSeleccionada = File(widget.vehiculo!.imagenPersonalizada!);
      }
      
      // Verificar si la marca está en la lista de marcas predeterminadas
      final marcasDisponibles = VehicleImageService.getBrandsForVehicleType(_tipoSeleccionado);
      if (marcasDisponibles.contains(widget.vehiculo!.marca)) {
        _marcaSeleccionada = widget.vehiculo!.marca;
        _esPersonalizado = false;
      } else {
        _esPersonalizado = true;
        _marcaController.text = widget.vehiculo!.marca;
      }
      
      // Verificar si el modelo está en la lista de modelos predeterminados
      final modelosDisponibles = VehicleImageService.getModelsForBrandAndType(_marcaSeleccionada, _tipoSeleccionado);
      if (modelosDisponibles.contains(widget.vehiculo!.modelo)) {
        _modeloSeleccionado = widget.vehiculo!.modelo;
      } else {
        _modeloSeleccionado = 'Personalizado';
        _modeloController.text = widget.vehiculo!.modelo;
      }
    } else {
      _updateMarcaYModelo();
    }
  }

  String _getDisplayNameForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'carro':
        return 'Carro';
      case 'sedan':
        return 'Sedán';
      case 'suv':
        return 'SUV';
      case 'hatchback':
        return 'Hatchback';
      case 'moto':
        return 'Motocicleta';
      case 'camion':
        return 'Camión';
      case 'van':
        return 'Van';
      default:
        return 'Carro';
    }
  }

  String _getTypeForDatabase(String displayName) {
    switch (displayName) {
      case 'Carro':
        return 'carro';
      case 'Sedán':
        return 'sedan';
      case 'SUV':
        return 'suv';
      case 'Hatchback':
        return 'hatchback';
      case 'Motocicleta':
        return 'moto';
      case 'Camión':
        return 'camion';
      case 'Van':
        return 'van';
      default:
        return 'carro';
    }
  }

  void _updateMarcaYModelo() {
    final marcas = VehicleImageService.getBrandsForVehicleType(_tipoSeleccionado);
    if (marcas.isNotEmpty) {
      _marcaSeleccionada = marcas.first;
      _updateModelos();
    }
  }

  void _updateModelos() {
    final modelos = VehicleImageService.getModelsForBrandAndType(_marcaSeleccionada, _tipoSeleccionado);
    if (modelos.isNotEmpty) {
      _modeloSeleccionado = modelos.first;
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleccionar imagen del vehículo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildOpcionImagen(
                    icon: Icons.camera_alt,
                    titulo: 'Cámara',
                    onTap: () => _seleccionarImagen(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOpcionImagen(
                    icon: Icons.photo_library,
                    titulo: 'Galería',
                    onTap: () => _seleccionarImagen(ImageSource.gallery),
                  ),
                ),
                if (_imagenSeleccionada != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOpcionImagen(
                      icon: Icons.delete,
                      titulo: 'Eliminar',
                      onTap: _eliminarImagen,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionImagen({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF6B35),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _seleccionarImagen(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null && mounted) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }

  void _eliminarImagen() {
    setState(() {
      _imagenSeleccionada = null;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF081126),
              Color(0xFF0E2242),
              Color(0xFF15335D),
              Color(0xFF1B3E75),
              Color(0xFF0A1A33),
            ],
            stops: [0.0, 0.25, 0.55, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVehiclePreview(),
                        const SizedBox(height: 30),
                        _buildTypeSelector(),
                        const SizedBox(height: 20),
                        _buildBrandSelector(),
                        const SizedBox(height: 20),
                        _buildModelSelector(),
                        const SizedBox(height: 20),
                        _buildYearField(),
                        const SizedBox(height: 20),
                        _buildMileageField(),
                        const SizedBox(height: 30),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Text(
              widget.vehiculo == null ? 'Agregar Vehículo' : 'Editar Vehículo',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Para balancear el botón de atrás
        ],
      ),
    );
  }

  Widget _buildVehiclePreview() {
    final imagePath = VehicleImageService.getVehicleImagePath(
      _getTypeForDatabase(_tipoSeleccionado),
      imagenPersonalizada: _imagenSeleccionada?.path,
    );
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _mostrarOpcionesImagen,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _imagenSeleccionada != null
                    ? Image.file(
                        _imagenSeleccionada!,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _mostrarOpcionesImagen,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _imagenSeleccionada != null ? Icons.edit : Icons.add_a_photo,
                    color: const Color(0xFFFF6B35),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _imagenSeleccionada != null ? 'Cambiar foto' : 'Agregar foto',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _tipoSeleccionado,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!_esPersonalizado) ...[
            Text(
              '$_marcaSeleccionada $_modeloSeleccionado',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Vehículo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tipoSeleccionado,
              dropdownColor: const Color(0xFF2A2A3E),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              items: VehicleImageService.getAvailableVehicleTypes()
                  .map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _tipoSeleccionado = value!;
                  _updateMarcaYModelo();
                  _esPersonalizado = false;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandSelector() {
    final marcas = VehicleImageService.getBrandsForVehicleType(_tipoSeleccionado);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marca',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _marcaSeleccionada,
                    dropdownColor: const Color(0xFF2A2A3E),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    items: marcas.map((marca) => DropdownMenuItem(
                          value: marca,
                          child: Text(marca),
                        )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _marcaSeleccionada = value!;
                        _esPersonalizado = (value == 'Personalizado');
                        if (!_esPersonalizado) {
                          _updateModelos();
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (_marcaSeleccionada == 'Personalizado')
              Expanded(
                child: TextField(
                  controller: _marcaController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Escribir marca',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modelo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _modeloSeleccionado,
                    dropdownColor: const Color(0xFF2A2A3E),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    items: VehicleImageService.getModelsForBrandAndType(_marcaSeleccionada, _tipoSeleccionado)
                        .map((modelo) => DropdownMenuItem(
                              value: modelo,
                              child: Text(modelo),
                            )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _modeloSeleccionado = value!;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (_modeloSeleccionado == 'Personalizado')
              Expanded(
                child: TextField(
                  controller: _modeloController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Escribir modelo',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildYearField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Año',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _anoController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B35)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMileageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kilometraje',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _kilometrajeController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B35)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveVehicle,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.vehiculo == null ? 'Agregar' : 'Actualizar',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final marca = _esPersonalizado ? _marcaController.text : _marcaSeleccionada;
    final modelo = _modeloSeleccionado == 'Personalizado' ? _modeloController.text : _modeloSeleccionado;

    if (marca.isEmpty || modelo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final viewModel = context.read<VehiculoViewModel>();
      
      final nuevoVehiculo = Vehiculo(
        id: widget.vehiculo?.id,
        marca: marca,
        modelo: modelo,
        ano: int.parse(_anoController.text),
        placa: widget.vehiculo?.placa ?? 'N/A',
        tipo: _getTypeForDatabase(_tipoSeleccionado),
        kilometraje: int.parse(_kilometrajeController.text),
        imagenPersonalizada: _imagenSeleccionada?.path,
        maintenance: widget.vehiculo?.maintenance ?? {},
        createdAt: widget.vehiculo?.createdAt ?? DateTime.now(),
      );
      
      if (widget.vehiculo == null) {
        // Agregar nuevo vehículo
        await viewModel.agregarVehiculo(
          marca: marca,
          modelo: modelo,
          ano: int.parse(_anoController.text),
          placa: 'N/A',
          tipo: _getTypeForDatabase(_tipoSeleccionado),
          kilometraje: int.parse(_kilometrajeController.text),
          imagenPersonalizada: _imagenSeleccionada?.path,
        );
        _showSuccessMessage('Vehículo agregado correctamente');
      } else {
        // Actualizar vehículo existente
        await viewModel.actualizarVehiculo(nuevoVehiculo);
        _showSuccessMessage('Vehículo actualizado correctamente');
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSuccessMessage('Error: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: message.contains('Error') ? const Color(0xFFB71C1C) : const Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 8,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }
}

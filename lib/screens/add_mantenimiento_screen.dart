import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../database/database_helper.dart';

class AddMantenimientoScreen extends StatefulWidget {
  final Vehiculo vehiculo;

  const AddMantenimientoScreen({super.key, required this.vehiculo});

  @override
  State<AddMantenimientoScreen> createState() => _AddMantenimientoScreenState();
}

class _AddMantenimientoScreenState extends State<AddMantenimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _costoController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  final _tallerController = TextEditingController();
  final _notasController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  DateTime _selectedDate = DateTime.now();
  String _selectedTipo = 'Preventivo';

  final List<String> _tiposMantenimiento = [
    'Preventivo',
    'Correctivo',
    'Predictivo',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _kilometrajeController.text = widget.vehiculo.kilometraje.toString();
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _descripcionController.dispose();
    _costoController.dispose();
    _kilometrajeController.dispose();
    _tallerController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMantenimiento() async {
    if (_formKey.currentState!.validate()) {
      final mantenimiento = Mantenimiento(
        vehiculoId: widget.vehiculo.id!,
        fecha: _selectedDate,
        tipo: _selectedTipo,
        descripcion: _descripcionController.text,
        costo: double.parse(_costoController.text),
        kilometraje: int.parse(_kilometrajeController.text),
        taller: _tallerController.text,
        notas: _notasController.text.isNotEmpty ? _notasController.text : null,
      );

      try {
        await _dbHelper.insertMantenimiento(mantenimiento);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mantenimiento agregado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al agregar mantenimiento: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Mantenimiento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Información del vehículo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vehículo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${widget.vehiculo.marca} ${widget.vehiculo.modelo}'),
                        Text('Placa: ${widget.vehiculo.placa}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Fecha
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),
                // Tipo de mantenimiento
                DropdownButtonFormField<String>(
                  initialValue: _selectedTipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Mantenimiento',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _tiposMantenimiento.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTipo = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costoController,
                  decoration: const InputDecoration(
                    labelText: 'Costo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el costo';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor ingresa un costo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _kilometrajeController,
                  decoration: const InputDecoration(
                    labelText: 'Kilometraje',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.speed),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el kilometraje';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor ingresa un kilometraje válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tallerController,
                  decoration: const InputDecoration(
                    labelText: 'Taller/Servicio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.build),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el taller o servicio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notasController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveMantenimiento,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Guardar Mantenimiento',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

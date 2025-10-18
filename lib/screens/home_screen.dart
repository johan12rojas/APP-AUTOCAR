import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../database/database_helper.dart';
import 'add_vehiculo_screen.dart';
import 'vehiculo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Vehiculo> _vehiculos = [];

  @override
  void initState() {
    super.initState();
    _loadVehiculos();
  }

  Future<void> _loadVehiculos() async {
    final vehiculos = await _dbHelper.getAllVehiculos();
    setState(() {
      _vehiculos = vehiculos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de Mantenimiento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _vehiculos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay vehículos registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toca el botón + para agregar tu primer vehículo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _vehiculos.length,
              itemBuilder: (context, index) {
                final vehiculo = _vehiculos[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.directions_car,
                      size: 40,
                      color: Colors.blue,
                    ),
                    title: Text(
                      '${vehiculo.marca} ${vehiculo.modelo}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Placa: ${vehiculo.placa}'),
                        Text('Año: ${vehiculo.ano}'),
                        Text('Kilometraje: ${vehiculo.kilometraje.toString()} km'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehiculoDetailScreen(vehiculo: vehiculo),
                        ),
                      );
                      _loadVehiculos();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddVehiculoScreen(),
            ),
          );
          _loadVehiculos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

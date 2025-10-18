import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehiculo.dart';
import '../viewmodels/vehiculo_viewmodel.dart';
import 'agregar_vehiculo_screen.dart';
import 'vehiculo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar vehículos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehiculoViewModel>(context, listen: false).cargarVehiculos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de Mantenimiento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<VehiculoViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.vehiculos.length > 1) {
                return PopupMenuButton<Vehiculo>(
                  icon: const Icon(Icons.swap_horiz),
                  onSelected: (Vehiculo vehiculo) {
                    Provider.of<VehiculoViewModel>(context, listen: false)
                        .cambiarVehiculoActual(vehiculo);
                  },
                  itemBuilder: (BuildContext context) {
                    return viewModel.vehiculos.map((Vehiculo vehiculo) {
                      return PopupMenuItem<Vehiculo>(
                        value: vehiculo,
                        child: Row(
                          children: [
                            Icon(
                              vehiculo.tipo == 'carro' ? Icons.directions_car : Icons.motorcycle,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text('${vehiculo.marca} ${vehiculo.modelo}'),
                            if (vehiculo.id == viewModel.vehiculoActual?.id)
                              const Icon(Icons.check, color: Colors.green),
                          ],
                        ),
                      );
                    }).toList();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<VehiculoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.vehiculos.isEmpty) {
            return const Center(
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
            );
          } else {
            return ListView.builder(
              itemCount: viewModel.vehiculos.length,
              itemBuilder: (context, index) {
                final vehiculo = viewModel.vehiculos[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
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
                      Provider.of<VehiculoViewModel>(context, listen: false).cargarVehiculos();
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarVehiculoScreen(),
            ),
          );
          if (result == true) {
            Provider.of<VehiculoViewModel>(context, listen: false).cargarVehiculos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


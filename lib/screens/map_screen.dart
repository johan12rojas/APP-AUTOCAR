import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/workshop.dart';
import '../models/route_info.dart';
import '../models/map_type_config.dart';
import '../models/gas_station.dart';
import '../data/workshop_data.dart';
import '../data/gas_station_data.dart';
import '../services/openroute_service.dart';
import '../widgets/workshop_card.dart';
import '../widgets/background_widgets.dart';

class MapScreen extends StatefulWidget {
  final String? searchQuery;
  final String? vehicleType;
  final String? specialty;

  const MapScreen({
    super.key,
    this.searchQuery,
    this.vehicleType,
    this.specialty,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<Workshop> _filteredWorkshops = [];
  List<GasStation> _gasStations = [];
  List<RouteInfo> _routes = [];
  List<RouteInfo> _gasStationRoutes = [];
  MapTypeConfig _selectedMapType = MapTypeConfig.mapTypes[0];
  bool _isLoading = true;
  bool _showRoutes = false;
  bool _showOnlyGasStations = false;
  Workshop? _selectedWorkshop;
  GasStation? _selectedGasStation;
  RouteInfo? _selectedRoute;
  RouteInfo? _persistentSelectedRoute; // Ruta que se mantiene al cerrar popup

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _filterWorkshops();
    _loadGasStations();
    await _calculateRoutes();
    setState(() {
      _isLoading = false;
      _showRoutes = true; // Mostrar rutas automáticamente
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Permission.location.request();
      if (permission.isGranted) {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      } else {
        // Usar ubicación por defecto de Cúcuta
        setState(() {
          _currentLocation = WorkshopData.cucutaCenter;
        });
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      setState(() {
        _currentLocation = WorkshopData.cucutaCenter;
      });
    }
  }

  void _filterWorkshops() {
    List<Workshop> workshops = WorkshopData.allWorkshops;

    // Filtrar por tipo de vehículo
    if (widget.vehicleType != null && widget.vehicleType!.isNotEmpty) {
      workshops = workshops.where((w) => w.servesVehicleType(widget.vehicleType!)).toList();
    }

    // Filtrar por especialidad
    if (widget.specialty != null && widget.specialty!.isNotEmpty) {
      workshops = workshops.where((w) => w.hasSpecialty(widget.specialty!)).toList();
    }

    // Filtrar por búsqueda
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      workshops = workshops.where((w) =>
        w.name.toLowerCase().contains(widget.searchQuery!.toLowerCase()) ||
        w.description.toLowerCase().contains(widget.searchQuery!.toLowerCase()) ||
        w.specialties.any((s) => s.toLowerCase().contains(widget.searchQuery!.toLowerCase()))
      ).toList();
    }

    // Ordenar por distancia si tenemos ubicación actual
    if (_currentLocation != null) {
      workshops.sort((a, b) => 
        a.distanceFrom(_currentLocation!).compareTo(b.distanceFrom(_currentLocation!))
      );
    }

    setState(() {
      _filteredWorkshops = workshops;
    });
  }

  void _loadGasStations() {
    setState(() {
      _gasStations = GasStationData.getGasStations();
    });
  }

  Future<void> _calculateRoutes() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoading = true;
    });

    final routes = <RouteInfo>[];
    final gasStationRoutes = <RouteInfo>[];
    
    // Calcular rutas solo para los 3 talleres más cercanos
    final limitedWorkshops = _filteredWorkshops.take(3).toList();
    
    for (final workshop in limitedWorkshops) {
      try {
        final route = await OpenRouteService.getRoute(
          start: _currentLocation!,
          end: workshop.location,
        );
        if (route != null) {
          routes.add(route);
        } else {
          // Fallback a ruta simple
          routes.add(OpenRouteService.createSimpleRoute(
            start: _currentLocation!,
            end: workshop.location,
          ));
        }
      } catch (e) {
        print('Error calculando ruta: $e');
        routes.add(OpenRouteService.createSimpleRoute(
          start: _currentLocation!,
          end: workshop.location,
        ));
      }
    }

    // Calcular rutas a las 3 gasolineras más cercanas
    final nearestGasStations = GasStationData.getNearestGasStations(
      _currentLocation!.latitude, 
      _currentLocation!.longitude,
      count: 3
    );
    
    for (final gasStation in nearestGasStations) {
      try {
        final route = await OpenRouteService.getRoute(
          start: _currentLocation!,
          end: LatLng(gasStation.latitude, gasStation.longitude),
        );
        if (route != null) {
          gasStationRoutes.add(route);
        } else {
          // Fallback a ruta simple
          gasStationRoutes.add(OpenRouteService.createSimpleRoute(
            start: _currentLocation!,
            end: LatLng(gasStation.latitude, gasStation.longitude),
          ));
        }
      } catch (e) {
        print('Error calculando ruta a gasolinera: $e');
        gasStationRoutes.add(OpenRouteService.createSimpleRoute(
          start: _currentLocation!,
          end: LatLng(gasStation.latitude, gasStation.longitude),
        ));
      }
    }

    setState(() {
      _routes = routes;
      _gasStationRoutes = gasStationRoutes;
      _isLoading = false;
    });
  }

  void _toggleRoutes() {
    setState(() {
      _showRoutes = !_showRoutes;
    });
  }

  void _toggleOnlyGasStations() {
    setState(() {
      _showOnlyGasStations = !_showOnlyGasStations;
      if (_showOnlyGasStations) {
        _showRoutes = true;
      }
    });
  }

  void _changeMapType() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          border: Border(
            top: BorderSide(color: Colors.white24, width: 1),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.layers,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tipo de Mapa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...MapTypeConfig.mapTypes.map((mapType) {
              final isSelected = _selectedMapType.name == mapType.name;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    _getMapTypeIcon(mapType.name),
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 20,
                  ),
                  title: Text(
                    mapType.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedMapType = mapType;
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getMapTypeIcon(String mapTypeName) {
    switch (mapTypeName) {
      case 'Calles':
        return Icons.map;
      case 'Satélite':
        return Icons.satellite;
      case 'Terreno':
        return Icons.terrain;
      case 'Híbrido':
        return Icons.layers;
      default:
        return Icons.map;
    }
  }

  void _centerOnLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 17.0);
    }
  }

  void _onWorkshopTapped(Workshop workshop) async {
    setState(() {
      _selectedWorkshop = workshop;
    });

    // Calcular ruta hacia este taller específico
    if (_currentLocation != null) {
      try {
        final route = await OpenRouteService.getRoute(
          start: _currentLocation!,
          end: workshop.location,
        );
        
        setState(() {
          _selectedRoute = route ?? OpenRouteService.createSimpleRoute(
            start: _currentLocation!,
            end: workshop.location,
          );
          // Guardar la ruta persistente
          _persistentSelectedRoute = _selectedRoute;
        });
      } catch (e) {
        print('Error calculando ruta hacia ${workshop.name}: $e');
        setState(() {
          _selectedRoute = OpenRouteService.createSimpleRoute(
            start: _currentLocation!,
            end: workshop.location,
          );
          // Guardar la ruta persistente
          _persistentSelectedRoute = _selectedRoute;
        });
      }
    }
  }

  void _onGasStationTapped(GasStation gasStation) async {
    setState(() {
      _selectedGasStation = gasStation;
    });

    // Calcular ruta hacia esta gasolinera específica
    if (_currentLocation != null) {
      try {
        final route = await OpenRouteService.getRoute(
          start: _currentLocation!,
          end: LatLng(gasStation.latitude, gasStation.longitude),
        );
        
        setState(() {
          _selectedRoute = route ?? OpenRouteService.createSimpleRoute(
            start: _currentLocation!,
            end: LatLng(gasStation.latitude, gasStation.longitude),
          );
          // Guardar la ruta persistente
          _persistentSelectedRoute = _selectedRoute;
        });
      } catch (e) {
        print('Error calculando ruta hacia ${gasStation.name}: $e');
        setState(() {
          _selectedRoute = OpenRouteService.createSimpleRoute(
            start: _currentLocation!,
            end: LatLng(gasStation.latitude, gasStation.longitude),
          );
          // Guardar la ruta persistente
          _persistentSelectedRoute = _selectedRoute;
        });
      }
    }
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 10),
            const Text(
              'Leyenda del Mapa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem(
              icon: Icons.directions_car,
              color: const Color(0xFF1A1A2E),
              title: 'Talleres para Carros',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              icon: Icons.motorcycle,
              color: Colors.orange,
              title: 'Talleres para Motos',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              icon: Icons.person,
              color: Colors.blue,
              title: 'Tu Ubicación',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              icon: Icons.route,
              color: const Color(0xFF4CAF50),
              title: 'Rutas de Talleres',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              icon: Icons.navigation,
              color: const Color(0xFF2196F3),
              title: 'Ruta Seleccionada',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              icon: Icons.local_gas_station,
              color: const Color(0xFFFFD700),
              title: 'Gasolineras',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              icon: Icons.route,
              color: const Color(0xFFFF6B35),
              title: 'Rutas a Gasolineras',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundGradientWidget(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Contenedor principal con gradiente y animación
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4CAF50),
                            Color(0xFF2E7D32),
                            Color(0xFF1B5E20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(70),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Indicador de carga personalizado con animación
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 4,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    
                    // Título principal
                    const Text(
                      'Cargando Mapa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Subtítulo animado
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            'Obteniendo tu ubicación y talleres cercanos',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Puntos animados
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.3 + (0.7 * (value - (index * 0.3)).clamp(0.0, 1.0)),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // AppBar personalizado
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GPS AUTOCAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _showOnlyGasStations 
                                  ? 'Modo Gasolineras - ${_gasStations.length} estaciones'
                                  : '${_filteredWorkshops.length} talleres encontrados',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _changeMapType,
                          icon: const Icon(Icons.layers, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: _centerOnLocation,
                          icon: const Icon(Icons.my_location, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: _toggleOnlyGasStations,
                          icon: Icon(
                            _showOnlyGasStations ? Icons.local_gas_station : Icons.local_gas_station_outlined,
                            color: _showOnlyGasStations ? const Color(0xFFFFD700) : Colors.white,
                          ),
                          tooltip: _showOnlyGasStations ? 'Mostrar todos' : 'Solo gasolineras',
                        ),
                        IconButton(
                          onPressed: _showLegend,
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  
                  // Mapa
                  Expanded(
                    flex: 2,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentLocation ?? WorkshopData.cucutaCenter,
                        initialZoom: 16.0,
                        minZoom: 10.0,
                        maxZoom: 18.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedWorkshop = null;
                          });
                        },
                      ),
                      children: [
                        // Tiles del mapa
                        TileLayer(
                          urlTemplate: _selectedMapType.urlTemplate,
                          additionalOptions: {
                            'attribution': _selectedMapType.attribution,
                          },
                          maxZoom: _selectedMapType.maxZoom.toDouble(),
                          minZoom: _selectedMapType.minZoom.toDouble(),
                        ),
                        
                        // Marcadores de talleres (solo si no está en modo solo gasolineras)
                        if (!_showOnlyGasStations)
                          MarkerLayer(
                            markers: _filteredWorkshops.map((workshop) {
                              // Determinar el icono según el tipo de vehículo
                              IconData workshopIcon;
                              Color workshopColor;
                              
                              if (workshop.vehicleTypes.contains('moto')) {
                                workshopIcon = Icons.motorcycle;
                                workshopColor = Colors.orange;
                              } else {
                                workshopIcon = Icons.directions_car;
                                workshopColor = const Color(0xFF1A1A2E);
                              }
                              
                              return Marker(
                                point: workshop.location,
                                width: 32.0,
                                height: 32.0,
                                child: GestureDetector(
                                  onTap: () => _onWorkshopTapped(workshop),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedWorkshop?.id == workshop.id 
                                          ? Colors.red 
                                          : workshopColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      workshopIcon,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        
                        // Marcadores de gasolineras (solo cuando está activo el modo gasolineras)
                        if (_showOnlyGasStations)
                          MarkerLayer(
                            markers: _gasStations.map((gasStation) {
                              return Marker(
                                point: LatLng(gasStation.latitude, gasStation.longitude),
                                width: 36.0,
                                height: 36.0,
                                child: GestureDetector(
                                  onTap: () => _onGasStationTapped(gasStation),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedGasStation?.id == gasStation.id 
                                          ? Colors.red 
                                          : const Color(0xFFFFD700),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      '⛽',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        
                        // Marcador de ubicación actual
                        if (_currentLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLocation!,
                              width: 30.0,
                              height: 30.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        // Rutas
                        if (_showRoutes)
         PolylineLayer(
           polylines: [
             // Rutas de los 3 talleres más cercanos (solo si no está en modo solo gasolineras)
             if (!_showOnlyGasStations)
               ..._routes.asMap().entries.map((entry) {
                 final index = entry.key;
                 final route = entry.value;
                 
                 // Colores específicos para los 3 talleres más cercanos
                 final colors = [
                   const Color(0xFF4CAF50),  // Verde vibrante para el más cercano
                   const Color(0xFFFF9800),  // Naranja vibrante para el segundo
                   const Color(0xFFE91E63),  // Rosa vibrante para el tercero
                 ];
                 
                 final color = index < colors.length ? colors[index] : const Color(0xFF9E9E9E);
                 
                 return Polyline(
                   points: route.coordinates,
                   color: color,
                   strokeWidth: 5.0,
                   borderColor: Colors.white,
                   borderStrokeWidth: 2.0,
                 );
               }),
             
             // Rutas a las 3 gasolineras más cercanas (solo cuando está activo el modo gasolineras)
             if (_showOnlyGasStations)
               ..._gasStationRoutes.asMap().entries.map((entry) {
                 final index = entry.key;
                 final route = entry.value;
                 
                 // Colores específicos para las 3 gasolineras más cercanas
                 final colors = [
                   const Color(0xFFFF6B35),  // Naranja vibrante para la más cercana
                   const Color(0xFF4ECDC4),  // Turquesa para la segunda
                   const Color(0xFF45B7D1),  // Azul para la tercera
                 ];
                 
                 final color = index < colors.length ? colors[index] : const Color(0xFF9E9E9E);
                 
                 return Polyline(
                   points: route.coordinates,
                   color: color,
                   strokeWidth: 5.0,
                   borderColor: Colors.white,
                   borderStrokeWidth: 2.0,
                 );
               }),
             
             // Ruta individual del taller o gasolinera seleccionado (persistente)
             if (_persistentSelectedRoute != null)
               Polyline(
                 points: _persistentSelectedRoute!.coordinates,
                 color: const Color(0xFF2196F3), // Azul para la ruta seleccionada
                 strokeWidth: 6.0,
                 borderColor: Colors.white,
                 borderStrokeWidth: 3.0,
               ),
           ],
         ),
                      ],
                    ),
                  ),
                  
                  // Lista de talleres
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF2A3F5F),
                            Color(0xFF1E3A5F),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header de la lista
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _showOnlyGasStations ? 'Gasolineras Cercanas' : 'Talleres Cercanos',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Botón para resetear rutas
                                if (_persistentSelectedRoute != null)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _persistentSelectedRoute = null;
                                        _selectedWorkshop = null;
                                        _selectedRoute = null;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.orange,
                                    ),
                                    tooltip: 'Resetear a las 3 más cercanas',
                                  ),
                                IconButton(
                                  onPressed: _toggleRoutes,
                                  icon: Icon(
                                    _showRoutes ? Icons.route : Icons.route_outlined,
                                    color: _showRoutes ? Colors.green : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          Expanded(
                            child: _showOnlyGasStations 
                              ? ListView.builder(
                                  itemCount: GasStationData.getNearestGasStations(
                                    _currentLocation?.latitude ?? 7.882018,
                                    _currentLocation?.longitude ?? -72.501954,
                                    count: 3
                                  ).length,
                                  itemBuilder: (context, index) {
                                    final nearestGasStations = GasStationData.getNearestGasStations(
                                      _currentLocation?.latitude ?? 7.882018,
                                      _currentLocation?.longitude ?? -72.501954,
                                      count: 3
                                    );
                                    final gasStation = nearestGasStations[index];
                                    final routeInfo = index < _gasStationRoutes.length ? _gasStationRoutes[index] : null;
                                    
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFFFFD700).withOpacity(0.1),
                                            const Color(0xFFFFD700).withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFFD700).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFD700),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    '⛽',
                                                    style: TextStyle(fontSize: 20),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      gasStation.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      gasStation.brand,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (routeInfo != null)
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${routeInfo.distance.toStringAsFixed(1)} km',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFFFFD700),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${routeInfo.duration.toStringAsFixed(0)} min',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  gasStation.location,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  itemCount: _filteredWorkshops.length,
                                  itemBuilder: (context, index) {
                                    final workshop = _filteredWorkshops[index];
                                    final routeInfo = index < _routes.length ? _routes[index] : null;
                                    
                                    return WorkshopCard(
                                      workshop: workshop,
                                      routeInfo: routeInfo,
                                      index: index,
                                      onTap: () {
                                        setState(() {
                                          _selectedWorkshop = workshop;
                                        });
                                        _mapController.move(workshop.location, 18.0);
                                      },
                                      onGetDirections: () {
                                        // Aquí podrías abrir Google Maps o Waze
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Abriendo direcciones hacia ${workshop.name}'),
                                            backgroundColor: const Color(0xFF1A1A2E),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ),
          
          // Popup del taller seleccionado
      if (_selectedWorkshop != null)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header del popup
                    Row(
                      children: [
                        Icon(
                          _selectedWorkshop!.vehicleTypes.contains('moto') 
                              ? Icons.motorcycle 
                              : Icons.directions_car,
                          color: _selectedWorkshop!.vehicleTypes.contains('moto') 
                              ? Colors.orange 
                              : const Color(0xFF1A1A2E),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedWorkshop!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedWorkshop = null;
                              _selectedRoute = null;
                              // NO limpiar _persistentSelectedRoute para mantener la ruta
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Ubicación
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 16),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _selectedWorkshop!.address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tipo de vehículo
                    Row(
                      children: [
                        Icon(
                          _selectedWorkshop!.vehicleTypes.contains('moto') 
                              ? Icons.motorcycle 
                              : Icons.directions_car,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Tipo: ${_selectedWorkshop!.vehicleTypes.join(', ')}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Servicios
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.build, color: Colors.grey, size: 16),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Servicios:', 
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _selectedWorkshop!.specialties.join(', '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (_selectedRoute != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.route, color: Colors.green, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            'Distancia: ${_selectedRoute!.distance.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 14, 
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 15),
                    
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Aquí podrías abrir Google Maps o Waze
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Abriendo direcciones hacia ${_selectedWorkshop!.name}'),
                                  backgroundColor: const Color(0xFF1A1A2E),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              elevation: 8,
                            ),
                            child: const Text('Ir aquí'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedWorkshop = null;
                                _selectedRoute = null;
                                // NO limpiar _persistentSelectedRoute para mantener la ruta
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF757575),
                              foregroundColor: Colors.white,
                              elevation: 8,
                            ),
                            child: const Text('Cerrar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Popup de la gasolinera seleccionada
        if (_selectedGasStation != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A1A2E),
                        Color(0xFF16213E),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header del popup
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '⛽',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedGasStation!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGasStation = null;
                                _selectedRoute = null;
                                // NO limpiar _persistentSelectedRoute para mantener la ruta
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Marca
                      Row(
                        children: [
                          const Icon(Icons.business, color: Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 5),
                          Text(
                            'Marca: ${_selectedGasStation!.brand}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Ubicación
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _selectedGasStation!.location,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (_selectedRoute != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.route, color: Colors.green, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              'Distancia: ${_selectedRoute!.distance.toStringAsFixed(2)} km',
                              style: const TextStyle(
                                fontSize: 14, 
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.orange, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              'Tiempo: ${_selectedRoute!.duration.toStringAsFixed(0)} min',
                              style: const TextStyle(
                                fontSize: 14, 
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 15),
                      
                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Aquí podrías abrir Google Maps o Waze
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Abriendo direcciones hacia ${_selectedGasStation!.name}'),
                                    backgroundColor: const Color(0xFF1A1A2E),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                elevation: 8,
                              ),
                              child: const Text('Ir aquí'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedGasStation = null;
                                  _selectedRoute = null;
                                  // NO limpiar _persistentSelectedRoute para mantener la ruta
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF757575),
                                foregroundColor: Colors.white,
                                elevation: 8,
                              ),
                              child: const Text('Cerrar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_info.dart';

class OpenRouteService {
  static const String _apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImMzMmMwOTIyN2M4MTQxMTY4NGU0M2Y5MGJiOTliMGUyIiwiaCI6Im11cm11cjY0In0=';
  static const String _baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';

  /// Obtiene la ruta entre dos puntos usando OpenRouteService
  static Future<RouteInfo?> getRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);
      
      final body = {
        'coordinates': [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude]
        ],
        'format': 'json',
        'geometry': true,
        'instructions': false,
        'maneuvers': false,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Respuesta exitosa de OpenRouteService');
        print('📊 Datos recibidos: ${data.toString().substring(0, 200)}...');
        return _parseRouteResponse(data);
      } else {
        print('❌ Error en OpenRouteService: ${response.statusCode}');
        print('📝 Response: ${response.body}');
        print('📤 Request body: ${jsonEncode(body)}');
        return null;
      }
    } catch (e) {
      print('Error al obtener ruta: $e');
      return null;
    }
  }

  /// Obtiene rutas desde un punto a múltiples destinos
  static Future<List<RouteInfo>> getRoutesToMultipleDestinations({
    required LatLng start,
    required List<LatLng> destinations,
  }) async {
    final List<RouteInfo> routes = [];
    
    // Limitar a 5 destinos para evitar sobrecarga de la API
    final limitedDestinations = destinations.take(5).toList();
    
    for (final destination in limitedDestinations) {
      try {
        final route = await getRoute(start: start, end: destination);
        if (route != null) {
          routes.add(route);
        }
      } catch (e) {
        print('Error al obtener ruta hacia ${destination.latitude}, ${destination.longitude}: $e');
      }
    }
    
    return routes;
  }

  /// Parsea la respuesta de OpenRouteService
  static RouteInfo? _parseRouteResponse(Map<String, dynamic> data) {
    try {
      print('🔍 Parseando respuesta de OpenRouteService...');
      print('📊 Estructura de datos: ${data.keys.toList()}');
      
      // OpenRouteService devuelve 'routes' cuando se usa formato JSON (no GeoJSON)
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final summary = route['summary'];
        
        print('📊 Información de la ruta:');
        print('📏 Distancia: ${(summary['distance'] / 1000.0).toStringAsFixed(2)} km');
        print('⏱️ Duración: ${_formatDuration(summary['duration'].round())}');
        
        // Extraer coordenadas de la geometría de la ruta (polyline codificado)
        List<LatLng> coordinates = [];
        if (route['geometry'] != null) {
          final geometry = route['geometry'];
          if (geometry is String) {
            // La geometría viene como polyline codificado
            coordinates = _decodePolyline(geometry);
          } else if (geometry is Map && geometry['coordinates'] != null) {
            final coords = geometry['coordinates'] as List;
            for (final coord in coords) {
              if (coord is List && coord.length >= 2) {
                // OpenRouteService usa [longitude, latitude]
                coordinates.add(LatLng(coord[1], coord[0]));
              }
            }
          }
        }
        
        // Si no tenemos coordenadas detalladas, usar el sistema de fallback
        if (coordinates.isEmpty) {
          print('⚠️ No se pudieron extraer coordenadas detalladas, usando ruta simple');
          return null; // Esto activará el sistema de fallback
        }
        
        print('🗺️ Coordenadas decodificadas: ${coordinates.length} puntos');
        
        final distance = (summary['distance'] ?? 0.0) / 1000.0; // Convertir a km
        final duration = summary['duration']?.round() ?? 0; // en segundos
        
        final summaryText = 'Ruta de ${distance.toStringAsFixed(1)} km, duración estimada: ${_formatDuration(duration)}';
        
        return RouteInfo(
          coordinates: coordinates,
          distance: distance,
          duration: duration,
          summary: summaryText,
          additionalData: {
            'elevation': summary['elevation'],
            'ascent': summary['ascent'],
            'descent': summary['descent'],
          },
        );
      } else {
        print('⚠️ No se encontraron routes en la respuesta');
        print('📊 Datos completos: $data');
        return null;
      }
    } catch (e) {
      print('❌ Error al parsear respuesta de ruta: $e');
      return null;
    }
  }


  /// Decodifica un polyline codificado de OpenRouteService
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  /// Formatea duración en segundos a texto legible
  static String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seg';
    } else if (seconds < 3600) {
      return '${(seconds / 60).round()} min';
    } else {
      final hours = (seconds / 3600).floor();
      final minutes = ((seconds % 3600) / 60).round();
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  /// Calcula una ruta simple como fallback si falla la API
  static RouteInfo createSimpleRoute({
    required LatLng start,
    required LatLng end,
  }) {
    const Distance distance = Distance();
    final routeDistance = distance.as(LengthUnit.Kilometer, start, end);
    
    // Estimar tiempo basado en velocidad promedio de 35 km/h en ciudad (Cúcuta)
    final estimatedDuration = (routeDistance / 35 * 3600).round();
    
    // Crear una línea recta simple con algunos puntos intermedios para mejor visualización
    final coordinates = [
      start,
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.33,
        start.longitude + (end.longitude - start.longitude) * 0.33,
      ),
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.66,
        start.longitude + (end.longitude - start.longitude) * 0.66,
      ),
      end,
    ];
    
    return RouteInfo(
      coordinates: coordinates,
      distance: routeDistance,
      duration: estimatedDuration,
      summary: 'Ruta aproximada de ${routeDistance.toStringAsFixed(1)} km, duración estimada: ${_formatDuration(estimatedDuration)}',
      additionalData: {
        'isSimpleRoute': true,
        'note': 'Ruta aproximada - se recomienda usar GPS para navegación exacta',
      },
    );
  }

  /// Verifica si el servicio está disponible
  static Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openrouteservice.org/status'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Calcula la distancia entre dos puntos usando la fórmula de Haversine
  static double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  /// Encuentra el punto más cercano a una ubicación dada
  static LatLng findNearestPoint(LatLng target, List<LatLng> points) {
    if (points.isEmpty) return target;
    
    LatLng nearest = points.first;
    double minDistance = calculateDistance(target, nearest);
    
    for (final point in points.skip(1)) {
      final distance = calculateDistance(target, point);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = point;
      }
    }
    
    return nearest;
  }
}

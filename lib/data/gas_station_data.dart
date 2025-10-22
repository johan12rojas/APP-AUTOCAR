import 'dart:math';
import '../models/gas_station.dart';

class GasStationData {
  static List<GasStation> getGasStations() {
    return [
      GasStation(
        id: 1,
        name: "Estación La Riviera",
        brand: "Terpel",
        location: "Av. Libertadores",
        latitude: 7.9039,
        longitude: -72.5081,
      ),
      GasStation(
        id: 2,
        name: "Estación Central",
        brand: "Biomax",
        location: "Av. 0 con Calle 10",
        latitude: 7.8985,
        longitude: -72.5057,
      ),
      GasStation(
        id: 3,
        name: "Estación El Pinar",
        brand: "Terpel",
        location: "Barrio El Pinar",
        latitude: 7.9150,
        longitude: -72.5034,
      ),
      GasStation(
        id: 4,
        name: "Estación La Merced",
        brand: "Esso",
        location: "Barrio La Merced",
        latitude: 7.8912,
        longitude: -72.5051,
      ),
      GasStation(
        id: 5,
        name: "Estación Aeropuerto",
        brand: "Zeuss",
        location: "Vía Aeropuerto",
        latitude: 7.9281,
        longitude: -72.5114,
      ),
      GasStation(
        id: 6,
        name: "Estación San Luis",
        brand: "Terpel",
        location: "Av. 7 con Calle 15",
        latitude: 7.8934,
        longitude: -72.5030,
      ),
      GasStation(
        id: 7,
        name: "Estación El Malecón",
        brand: "Primax",
        location: "Av. Libertadores",
        latitude: 7.9078,
        longitude: -72.5052,
      ),
      GasStation(
        id: 8,
        name: "Estación Panamericana",
        brand: "Terpel",
        location: "Av. 3E con Calle 5",
        latitude: 7.8859,
        longitude: -72.4956,
      ),
      GasStation(
        id: 9,
        name: "Estación El Progreso",
        brand: "Zeuss",
        location: "Barrio El Progreso",
        latitude: 7.9056,
        longitude: -72.5003,
      ),
      GasStation(
        id: 10,
        name: "Estación La Playa",
        brand: "Terpel",
        location: "Av. 4 con Calle 10",
        latitude: 7.8947,
        longitude: -72.5078,
      ),
      GasStation(
        id: 11,
        name: "Estación Guaymaral",
        brand: "Biomax",
        location: "Av. 7 con Calle 24",
        latitude: 7.8940,
        longitude: -72.4939,
      ),
      GasStation(
        id: 12,
        name: "Estación Belisario",
        brand: "Zeuss",
        location: "Barrio Belisario",
        latitude: 7.9121,
        longitude: -72.4977,
      ),
      GasStation(
        id: 13,
        name: "Estación Sevilla",
        brand: "Terpel",
        location: "Barrio Sevilla",
        latitude: 7.9145,
        longitude: -72.5068,
      ),
      GasStation(
        id: 14,
        name: "Estación La Ceiba",
        brand: "Esso",
        location: "Barrio La Ceiba",
        latitude: 7.8898,
        longitude: -72.4982,
      ),
      GasStation(
        id: 15,
        name: "Estación Motilones",
        brand: "Primax",
        location: "Av. 0 con Calle 3",
        latitude: 7.8823,
        longitude: -72.5011,
      ),
      GasStation(
        id: 16,
        name: "Estación San Mateo",
        brand: "Zeuss",
        location: "Av. 5 con Calle 11",
        latitude: 7.8952,
        longitude: -72.5005,
      ),
      GasStation(
        id: 17,
        name: "Estación La Cabrera",
        brand: "Biomax",
        location: "Barrio La Cabrera",
        latitude: 7.9017,
        longitude: -72.4966,
      ),
      GasStation(
        id: 18,
        name: "Estación Tucunaré",
        brand: "Terpel",
        location: "Av. Demetrio Mendoza",
        latitude: 7.9128,
        longitude: -72.4919,
      ),
      GasStation(
        id: 19,
        name: "Estación Carora",
        brand: "Primax",
        location: "Av. Guaimaral",
        latitude: 7.8880,
        longitude: -72.4959,
      ),
      GasStation(
        id: 20,
        name: "Estación Chapinero",
        brand: "Zeuss",
        location: "Barrio Chapinero",
        latitude: 7.9026,
        longitude: -72.4898,
      ),
      GasStation(
        id: 21,
        name: "Estación San Eduardo",
        brand: "Terpel",
        location: "Av. 0 con Calle 22",
        latitude: 7.8980,
        longitude: -72.4973,
      ),
      GasStation(
        id: 22,
        name: "Estación Pan de Azúcar",
        brand: "Biomax",
        location: "Barrio Pan de Azúcar",
        latitude: 7.9089,
        longitude: -72.4924,
      ),
      GasStation(
        id: 23,
        name: "Estación El Porvenir",
        brand: "Terpel",
        location: "Barrio El Porvenir",
        latitude: 7.8848,
        longitude: -72.4899,
      ),
      GasStation(
        id: 24,
        name: "Estación Boconó",
        brand: "Zeuss",
        location: "Vía Boconó",
        latitude: 7.9361,
        longitude: -72.5086,
      ),
      GasStation(
        id: 25,
        name: "Estación Las Américas",
        brand: "Primax",
        location: "Av. Libertadores",
        latitude: 7.9115,
        longitude: -72.5080,
      ),
    ];
  }

  /// Calcula la distancia entre dos puntos usando la fórmula de Haversine
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radio de la Tierra en kilómetros
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Encuentra las 3 gasolineras más cercanas a una ubicación dada
  static List<GasStation> getNearestGasStations(double userLat, double userLon, {int count = 3}) {
    List<GasStation> gasStations = getGasStations();
    
    // Calcular distancias y ordenar
    List<MapEntry<GasStation, double>> stationsWithDistance = gasStations.map((station) {
      double distance = calculateDistance(userLat, userLon, station.latitude, station.longitude);
      return MapEntry(station, distance);
    }).toList();
    
    // Ordenar por distancia
    stationsWithDistance.sort((a, b) => a.value.compareTo(b.value));
    
    // Retornar las más cercanas
    return stationsWithDistance.take(count).map((entry) => entry.key).toList();
  }
}

import 'package:latlong2/latlong.dart';

class RouteInfo {
  final List<LatLng> coordinates;
  final double distance; // en kilómetros
  final int duration; // en segundos
  final String summary;
  final Map<String, dynamic>? additionalData;

  const RouteInfo({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.summary,
    this.additionalData,
  });

  RouteInfo copyWith({
    List<LatLng>? coordinates,
    double? distance,
    int? duration,
    String? summary,
    Map<String, dynamic>? additionalData,
  }) {
    return RouteInfo(
      coordinates: coordinates ?? this.coordinates,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      summary: summary ?? this.summary,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Duración formateada (ej: "15 min")
  String get formattedDuration {
    if (duration < 60) {
      return '$duration seg';
    } else if (duration < 3600) {
      return '${(duration / 60).round()} min';
    } else {
      final hours = (duration / 3600).floor();
      final minutes = ((duration % 3600) / 60).round();
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  // Distancia formateada
  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    } else {
      return '${distance.toStringAsFixed(1)} km';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'coordinates': coordinates.map((coord) => {
        'latitude': coord.latitude,
        'longitude': coord.longitude,
      }).toList(),
      'distance': distance,
      'duration': duration,
      'summary': summary,
      'additionalData': additionalData,
    };
  }

  factory RouteInfo.fromMap(Map<String, dynamic> map) {
    return RouteInfo(
      coordinates: (map['coordinates'] as List)
          .map((coord) => LatLng(
                coord['latitude']?.toDouble() ?? 0.0,
                coord['longitude']?.toDouble() ?? 0.0,
              ))
          .toList(),
      distance: map['distance']?.toDouble() ?? 0.0,
      duration: map['duration'] ?? 0,
      summary: map['summary'] ?? '',
      additionalData: map['additionalData'] as Map<String, dynamic>?,
    );
  }
}


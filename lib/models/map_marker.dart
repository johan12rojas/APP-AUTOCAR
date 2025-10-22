import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapMarker {
  final String id;
  final String title;
  final String description;
  final LatLng position;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? data;

  const MapMarker({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.icon,
    required this.color,
    this.data,
  });

  MapMarker copyWith({
    String? id,
    String? title,
    String? description,
    LatLng? position,
    IconData? icon,
    Color? color,
    Map<String, dynamic>? data,
  }) {
    return MapMarker(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'icon': icon.codePoint,
      'color': color.value,
      'data': data,
    };
  }

  factory MapMarker.fromMap(Map<String, dynamic> map) {
    return MapMarker(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      position: LatLng(
        map['latitude']?.toDouble() ?? 0.0,
        map['longitude']?.toDouble() ?? 0.0,
      ),
      icon: IconData(map['icon'] ?? Icons.location_on.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] ?? Colors.red.value),
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}


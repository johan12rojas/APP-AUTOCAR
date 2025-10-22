import 'package:latlong2/latlong.dart';

class Workshop {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final String address;
  final String phone;
  final String email;
  final List<String> specialties;
  final List<String> vehicleTypes;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final String? website;
  final Map<String, dynamic>? additionalInfo;
  final bool isOpen24Hours;
  final List<String> workingHours;

  const Workshop({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.address,
    required this.phone,
    this.email = '',
    required this.specialties,
    required this.vehicleTypes,
    required this.services,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.website,
    this.additionalInfo,
    this.isOpen24Hours = false,
    this.workingHours = const [],
  });

  Workshop copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? location,
    String? address,
    String? phone,
    String? email,
    List<String>? specialties,
    List<String>? vehicleTypes,
    List<String>? services,
    double? rating,
    int? reviewCount,
    String? website,
    Map<String, dynamic>? additionalInfo,
    bool? isOpen24Hours,
    List<String>? workingHours,
  }) {
    return Workshop(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      specialties: specialties ?? this.specialties,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      services: services ?? this.services,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      website: website ?? this.website,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isOpen24Hours: isOpen24Hours ?? this.isOpen24Hours,
      workingHours: workingHours ?? this.workingHours,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': address,
      'phone': phone,
      'email': email,
      'specialties': specialties,
      'vehicleTypes': vehicleTypes,
      'services': services,
      'rating': rating,
      'reviewCount': reviewCount,
      'website': website,
      'additionalInfo': additionalInfo,
      'isOpen24Hours': isOpen24Hours,
      'workingHours': workingHours,
    };
  }

  factory Workshop.fromMap(Map<String, dynamic> map) {
    return Workshop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: LatLng(
        map['latitude']?.toDouble() ?? 0.0,
        map['longitude']?.toDouble() ?? 0.0,
      ),
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      vehicleTypes: List<String>.from(map['vehicleTypes'] ?? []),
      services: List<String>.from(map['services'] ?? []),
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] ?? 0,
      website: map['website'],
      additionalInfo: map['additionalInfo'] as Map<String, dynamic>?,
      isOpen24Hours: map['isOpen24Hours'] ?? false,
      workingHours: List<String>.from(map['workingHours'] ?? []),
    );
  }

  // Método para calcular distancia desde una ubicación
  double distanceFrom(LatLng fromLocation) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, fromLocation, location);
  }

  // Método para verificar si atiende un tipo de vehículo
  bool servesVehicleType(String vehicleType) {
    return vehicleTypes.contains(vehicleType.toLowerCase());
  }

  // Método para verificar si tiene una especialidad
  bool hasSpecialty(String specialty) {
    return specialties.any((s) => s.toLowerCase().contains(specialty.toLowerCase()));
  }
}


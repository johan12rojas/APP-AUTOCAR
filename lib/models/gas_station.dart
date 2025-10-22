class GasStation {
  final int id;
  final String name;
  final String brand;
  final String location;
  final double latitude;
  final double longitude;

  GasStation({
    required this.id,
    required this.name,
    required this.brand,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory GasStation.fromJson(Map<String, dynamic> json) {
    return GasStation(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'GasStation(id: $id, name: $name, brand: $brand, location: $location, lat: $latitude, lng: $longitude)';
  }
}

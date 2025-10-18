class VehicleImageService {
  static const Map<String, String> vehicleImages = {
    'carro': 'assets/images/vehicles/car_default.png',
    'carro_normal': 'assets/images/vehicles/car_default.png',
    'sedan': 'assets/images/vehicles/car_sedan.png',
    'suv': 'assets/images/vehicles/car_suv.png',
    'hatchback': 'assets/images/vehicles/car_hatchback.png',
    'moto': 'assets/images/vehicles/motorcycle.png',
    'motocicleta': 'assets/images/vehicles/motorcycle.png',
  };

  static String getVehicleImagePath(String tipo) {
    // Normalizar el tipo a minúsculas y sin espacios
    final normalizedType = tipo.toLowerCase().trim();
    
    // Buscar coincidencia exacta
    if (vehicleImages.containsKey(normalizedType)) {
      return vehicleImages[normalizedType]!;
    }
    
    // Buscar coincidencias parciales
    for (final key in vehicleImages.keys) {
      if (normalizedType.contains(key) || key.contains(normalizedType)) {
        return vehicleImages[key]!;
      }
    }
    
    // Si no encuentra coincidencia, usar imagen por defecto según si es moto o carro
    if (normalizedType.contains('moto') || normalizedType.contains('motor')) {
      return vehicleImages['moto']!;
    }
    
    return vehicleImages['carro']!;
  }

  static String getVehicleDisplayName(String tipo) {
    final normalizedType = tipo.toLowerCase().trim();
    
    switch (normalizedType) {
      case 'carro':
      case 'carro_normal':
        return 'Carro';
      case 'sedan':
        return 'Sedán';
      case 'suv':
        return 'SUV';
      case 'hatchback':
        return 'Hatchback';
      case 'moto':
      case 'motocicleta':
        return 'Motocicleta';
      default:
        if (normalizedType.contains('moto') || normalizedType.contains('motor')) {
          return 'Motocicleta';
        }
        return 'Carro';
    }
  }

  static List<String> getAvailableVehicleTypes() {
    return [
      'Carro',
      'Sedán', 
      'SUV',
      'Hatchback',
      'Motocicleta',
    ];
  }

  static String getVehicleTypeForImage(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'carro':
        return 'carro';
      case 'sedán':
        return 'sedan';
      case 'suv':
        return 'suv';
      case 'hatchback':
        return 'hatchback';
      case 'motocicleta':
        return 'moto';
      default:
        return 'carro';
    }
  }
}

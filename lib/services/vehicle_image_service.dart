class VehicleImageService {
  static const Map<String, String> vehicleImages = {
    'carro': 'assets/images/vehicles/car_default.png',
    'carro_normal': 'assets/images/vehicles/car_default.png',
    'sedan': 'assets/images/vehicles/car_sedan.png',
    'suv': 'assets/images/vehicles/car_suv.png',
    'hatchback': 'assets/images/vehicles/car_hatchback.png',
    'moto': 'assets/images/vehicles/motorcycle.png',
    'motocicleta': 'assets/images/vehicles/motorcycle.png',
    'camion': 'assets/images/vehicles/truck.png',
    'van': 'assets/images/vehicles/van.png',
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
      'Camión',
      'Van',
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
      case 'camión':
        return 'camion';
      case 'van':
        return 'van';
      default:
        return 'carro';
    }
  }

  // Sistema de marcas y modelos por tipo de vehículo
  static const Map<String, List<String>> vehicleBrands = {
    'Carro': ['Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Ford', 'Volkswagen', 'Mazda', 'Mitsubishi', 'Personalizado'],
    'Sedán': ['Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Ford', 'Volkswagen', 'Mazda', 'BMW', 'Mercedes-Benz', 'Audi', 'Personalizado'],
    'SUV': ['Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Ford', 'Volkswagen', 'Mazda', 'BMW', 'Mercedes-Benz', 'Audi', 'Personalizado'],
    'Hatchback': ['Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Ford', 'Volkswagen', 'Mazda', 'Peugeot', 'Renault', 'Personalizado'],
    'Motocicleta': ['Honda', 'Yamaha', 'Suzuki', 'Kawasaki', 'KTM', 'Ducati', 'Harley-Davidson', 'BMW', 'Aprilia', 'Personalizado'],
    'Camión': ['Ford', 'Chevrolet', 'GMC', 'Ram', 'Toyota', 'Nissan', 'Isuzu', 'Mitsubishi', 'Personalizado'],
    'Van': ['Ford', 'Chevrolet', 'Nissan', 'Toyota', 'Mercedes-Benz', 'Volkswagen', 'Renault', 'Peugeot', 'Personalizado'],
  };

  static const Map<String, Map<String, List<String>>> vehicleModels = {
    'Toyota': {
      'Carro': ['Corolla', 'Camry', 'Prius', 'Avalon'],
      'Sedán': ['Corolla', 'Camry', 'Prius', 'Avalon'],
      'SUV': ['RAV4', 'Highlander', '4Runner', 'Sequoia'],
      'Hatchback': ['Yaris', 'Prius C', 'Corolla Hatchback'],
      'Van': ['Sienna', 'Hiace'],
      'Camión': ['Tacoma', 'Tundra'],
    },
    'Honda': {
      'Carro': ['Civic', 'Accord', 'Insight'],
      'Sedán': ['Civic', 'Accord', 'Insight'],
      'SUV': ['CR-V', 'Pilot', 'Passport', 'HR-V'],
      'Hatchback': ['Civic Hatchback', 'Fit'],
      'Motocicleta': ['CBR', 'CB', 'CRF', 'GL', 'VFR', 'NC'],
      'Van': ['Odyssey'],
    },
    'Nissan': {
      'Carro': ['Sentra', 'Altima', 'Maxima'],
      'Sedán': ['Sentra', 'Altima', 'Maxima'],
      'SUV': ['Rogue', 'Murano', 'Pathfinder', 'Armada'],
      'Hatchback': ['Versa', 'Kicks'],
      'Camión': ['Frontier', 'Titan'],
      'Van': ['NV200', 'NV Cargo'],
    },
    'Hyundai': {
      'Carro': ['Elantra', 'Sonata', 'Ioniq'],
      'Sedán': ['Elantra', 'Sonata', 'Ioniq'],
      'SUV': ['Tucson', 'Santa Fe', 'Palisade', 'Kona'],
      'Hatchback': ['Veloster', 'Accent'],
      'Van': ['Transit'],
    },
    'Kia': {
      'Carro': ['Forte', 'Optima', 'Stinger'],
      'Sedán': ['Forte', 'Optima', 'Stinger'],
      'SUV': ['Sportage', 'Sorento', 'Telluride', 'Seltos'],
      'Hatchback': ['Rio', 'Soul'],
      'Van': ['Sedona'],
    },
    'Chevrolet': {
      'Carro': ['Cruze', 'Malibu', 'Impala'],
      'Sedán': ['Cruze', 'Malibu', 'Impala'],
      'SUV': ['Equinox', 'Traverse', 'Tahoe', 'Suburban'],
      'Hatchback': ['Sonic', 'Spark'],
      'Camión': ['Silverado', 'Colorado'],
      'Van': ['Express'],
    },
    'Ford': {
      'Carro': ['Focus', 'Fusion', 'Mustang'],
      'Sedán': ['Focus', 'Fusion', 'Mustang'],
      'SUV': ['Escape', 'Explorer', 'Expedition', 'Bronco'],
      'Hatchback': ['Fiesta', 'Focus Hatchback'],
      'Camión': ['F-150', 'F-250', 'F-350', 'Ranger'],
      'Van': ['Transit', 'E-Series'],
    },
    'Volkswagen': {
      'Carro': ['Jetta', 'Passat', 'Arteon'],
      'Sedán': ['Jetta', 'Passat', 'Arteon'],
      'SUV': ['Tiguan', 'Atlas', 'ID.4'],
      'Hatchback': ['Golf', 'Polo'],
      'Van': ['Transporter'],
    },
    'Mazda': {
      'Carro': ['Mazda3', 'Mazda6'],
      'Sedán': ['Mazda3', 'Mazda6'],
      'SUV': ['CX-3', 'CX-5', 'CX-9'],
      'Hatchback': ['Mazda3 Hatchback', 'MX-5'],
    },
    'BMW': {
      'Sedán': ['Serie 3', 'Serie 5', 'Serie 7'],
      'SUV': ['X1', 'X3', 'X5', 'X7'],
      'Motocicleta': ['R', 'K', 'G', 'F'],
    },
    'Mercedes-Benz': {
      'Sedán': ['Clase C', 'Clase E', 'Clase S'],
      'SUV': ['GLA', 'GLC', 'GLE', 'GLS'],
      'Van': ['Sprinter'],
    },
    'Audi': {
      'Sedán': ['A3', 'A4', 'A6', 'A8'],
      'SUV': ['Q3', 'Q5', 'Q7', 'Q8'],
    },
    'Yamaha': {
      'Motocicleta': ['YZF', 'FZ', 'MT', 'XT', 'WR', 'TMAX'],
    },
    'Suzuki': {
      'Motocicleta': ['GSX', 'GSF', 'DL', 'RM', 'DR'],
    },
    'Kawasaki': {
      'Motocicleta': ['Ninja', 'Z', 'KLR', 'Versys', 'Vulcan'],
    },
    'GMC': {
      'SUV': ['Terrain', 'Acadia', 'Yukon'],
      'Camión': ['Sierra'],
      'Van': ['Savana'],
    },
    'Ram': {
      'Camión': ['1500', '2500', '3500'],
      'Van': ['ProMaster'],
    },
    'Isuzu': {
      'Camión': ['D-Max', 'NPR'],
      'Van': ['NPR'],
    },
    'Mitsubishi': {
      'Carro': ['Mirage', 'Lancer'],
      'Sedán': ['Mirage', 'Lancer'],
      'SUV': ['Outlander', 'Eclipse Cross'],
      'Camión': ['L200'],
    },
    'Peugeot': {
      'Hatchback': ['208', '308'],
      'Van': ['Partner', 'Expert'],
    },
    'Renault': {
      'Hatchback': ['Clio', 'Megane'],
      'Van': ['Kangoo', 'Master'],
    },
    'KTM': {
      'Motocicleta': ['Duke', 'RC', 'Adventure', 'Enduro'],
    },
    'Ducati': {
      'Motocicleta': ['Monster', 'Panigale', 'Multistrada', 'Scrambler'],
    },
    'Harley-Davidson': {
      'Motocicleta': ['Sportster', 'Softail', 'Touring', 'CVO'],
    },
    'Aprilia': {
      'Motocicleta': ['RSV4', 'Tuono', 'Shiver', 'Dorsoduro'],
    },
  };

  static List<String> getBrandsForVehicleType(String vehicleType) {
    return vehicleBrands[vehicleType] ?? ['Personalizado'];
  }

  static List<String> getModelsForBrandAndType(String brand, String vehicleType) {
    if (brand == 'Personalizado') {
      return ['Personalizado'];
    }
    
    final brandModels = vehicleModels[brand];
    if (brandModels == null) {
      return ['Personalizado'];
    }
    
    return brandModels[vehicleType] ?? ['Personalizado'];
  }
}

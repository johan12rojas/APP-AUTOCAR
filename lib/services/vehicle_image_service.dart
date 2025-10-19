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

  static String getVehicleImagePath(String tipo, {String? imagenPersonalizada}) {
    // Si hay imagen personalizada, usarla
    if (imagenPersonalizada != null && imagenPersonalizada.isNotEmpty) {
      return imagenPersonalizada;
    }
    
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
    'Carro': [
      'Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Ford', 'Volkswagen', 'Mazda', 'Mitsubishi',
      'BMW', 'Mercedes-Benz', 'Audi', 'Lexus', 'Infiniti', 'Acura', 'Genesis', 'Subaru', 'Volvo', 'Jaguar',
      'Land Rover', 'Porsche', 'Bentley', 'Rolls-Royce', 'Ferrari', 'Lamborghini', 'Maserati', 'Alfa Romeo',
      'Fiat', 'Peugeot', 'Renault', 'Citroën', 'Seat', 'Skoda', 'Dacia', 'Opel', 'Saab', 'Lada',
      'Tata', 'Mahindra', 'BYD', 'Geely', 'Great Wall', 'Chery', 'JAC', 'Dongfeng', 'FAW', 'Personalizado'
    ],
    'Sedán': [
      'Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Ford', 'Volkswagen', 'Mazda', 'BMW',
      'Mercedes-Benz', 'Audi', 'Lexus', 'Infiniti', 'Acura', 'Genesis', 'Volvo', 'Jaguar', 'Porsche',
      'Bentley', 'Rolls-Royce', 'Ferrari', 'Lamborghini', 'Maserati', 'Alfa Romeo', 'Fiat', 'Peugeot',
      'Renault', 'Citroën', 'Seat', 'Skoda', 'Opel', 'Saab', 'Subaru', 'Mitsubishi', 'Personalizado'
    ],
    'SUV': [
      'Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Ford', 'Volkswagen', 'Mazda', 'BMW',
      'Mercedes-Benz', 'Audi', 'Lexus', 'Infiniti', 'Acura', 'Genesis', 'Volvo', 'Jaguar', 'Land Rover',
      'Porsche', 'Bentley', 'Rolls-Royce', 'Lamborghini', 'Maserati', 'Alfa Romeo', 'Fiat', 'Peugeot',
      'Renault', 'Citroën', 'Seat', 'Skoda', 'Opel', 'Subaru', 'Mitsubishi', 'Jeep', 'Ram', 'GMC',
      'Cadillac', 'Lincoln', 'Buick', 'Personalizado'
    ],
    'Hatchback': [
      'Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Ford', 'Volkswagen', 'Cupra', 'Mazda',
      'BMW', 'Mercedes-Benz', 'Audi', 'Mini', 'Fiat', 'Peugeot', 'Renault', 'Citroën', 'Seat', 'Skoda',
      'Opel', 'Saab', 'Subaru', 'Mitsubishi', 'Suzuki', 'Daihatsu', 'Smart', 'Abarth', 'Alfa Romeo', 'Personalizado'
    ],
    'Motocicleta': [
      'Honda', 'Yamaha', 'Suzuki', 'Kawasaki', 'KTM', 'Ducati', 'Harley-Davidson', 'BMW', 'Aprilia',
      'Triumph', 'Royal Enfield', 'Bajaj', 'TVS', 'Hero', 'Benelli', 'MV Agusta', 'Moto Guzzi', 'Piaggio',
      'Vespa', 'Husqvarna', 'GasGas', 'Beta', 'Sherco', 'Husaberg', 'Cagiva', 'Mondial', 'Personalizado'
    ],
    'Camión': [
      'Ford', 'Chevrolet', 'GMC', 'Ram', 'Toyota', 'Nissan', 'Isuzu', 'Mitsubishi', 'Hino', 'Fuso',
      'Freightliner', 'International', 'Kenworth', 'Peterbilt', 'Mack', 'Volvo', 'Scania', 'MAN',
      'Iveco', 'DAF', 'Renault Trucks', 'Mercedes-Benz', 'Volkswagen', 'Tata', 'Ashok Leyland', 'Personalizado'
    ],
    'Van': [
      'Fox', 'Chevrolet', 'Nissan', 'Toyota', 'Mercedes-Benz', 'Volkswagen', 'Renault', 'Peugeot',
      'Citroën', 'Fiat', 'Iveco', 'Ford Transit', 'Ram', 'GMC', 'Sprinter', 'Crafter', 'Daily',
      'Master', 'Boxer', 'Jumper', 'Ducato', 'ProMaster', 'NV200', 'NV Cargo', 'Hiace', 'Proace',
      'Transit', 'E-Series', 'Express', 'Savana', 'Personalizado'
    ],
  };

  static const Map<String, Map<String, List<String>>> vehicleModels = {
    'Toyota': {
      'Carro': ['Corolla', 'Camry', 'Prius', 'Avalon', 'Yaris', 'GR86', 'Supra', 'Mirai'],
      'Sedán': ['Corolla', 'Camry', 'Prius', 'Avalon'],
      'SUV': ['RAV4', 'Highlander', '4Runner', 'Sequoia', 'Land Cruiser', 'C-HR', 'Venza', 'bZ4X'],
      'Hatchback': ['Yaris', 'Prius C', 'Corolla Hatchback', 'GR Yaris'],
      'Van': ['Sienna', 'Hiace', 'Proace'],
      'Camión': ['Tacoma', 'Tundra'],
    },
    'Honda': {
      'Carro': ['Civic', 'Accord', 'Insight', 'Fit', 'HR-V'],
      'Sedán': ['Civic', 'Accord', 'Insight'],
      'SUV': ['CR-V', 'Pilot', 'Passport', 'HR-V', 'Ridgeline', 'Element'],
      'Hatchback': ['Civic Hatchback', 'Fit', 'CR-Z'],
      'Motocicleta': ['CBR', 'CB', 'CRF', 'GL', 'VFR', 'NC', 'Rebel', 'Shadow', 'Gold Wing', 'Africa Twin'],
      'Van': ['Odyssey'],
    },
    'Nissan': {
      'Carro': ['Sentra', 'Altima', 'Maxima', 'Versa', 'GT-R'],
      'Sedán': ['Sentra', 'Altima', 'Maxima'],
      'SUV': ['Rogue', 'Murano', 'Pathfinder', 'Armada', 'Kicks', 'Juke', 'Qashqai'],
      'Hatchback': ['Versa', 'Kicks', 'Leaf', 'Juke'],
      'Camión': ['Frontier', 'Titan', 'Navara'],
      'Van': ['NV200', 'NV Cargo', 'Quest'],
    },
    'Hyundai': {
      'Carro': ['Elantra', 'Sonata', 'Ioniq', 'Accent', 'Veloster'],
      'Sedán': ['Elantra', 'Sonata', 'Ioniq'],
      'SUV': ['Tucson', 'Santa Fe', 'Palisade', 'Kona', 'Venue', 'Nexo'],
      'Hatchback': ['Veloster', 'Accent', 'i20', 'i30'],
      'Van': ['Transit', 'H-1'],
    },
    'Kia': {
      'Carro': ['Forte', 'Optima', 'Stinger', 'Rio', 'Cerato'],
      'Sedán': ['Forte', 'Optima', 'Stinger'],
      'SUV': ['Sportage', 'Sorento', 'Telluride', 'Seltos', 'Niro', 'EV6'],
      'Hatchback': ['Rio', 'Soul', 'Picanto'],
      'Van': ['Sedona', 'Carnival'],
    },
    'Chevrolet': {
      'Carro': ['Cruze', 'Malibu', 'Impala', 'Sonic', 'Spark', 'Camaro'],
      'Sedán': ['Cruze', 'Malibu', 'Impala'],
      'SUV': ['Equinox', 'Traverse', 'Tahoe', 'Suburban', 'Blazer', 'Trax', 'Bolt EV'],
      'Hatchback': ['Sonic', 'Spark'],
      'Camión': ['Silverado', 'Colorado'],
      'Van': ['Express'],
    },
    'Ford': {
      'Carro': ['Focus', 'Fusion', 'Mustang', 'Fiesta'],
      'Sedán': ['Focus', 'Fusion', 'Mustang'],
      'SUV': ['Escape', 'Explorer', 'Expedition', 'Bronco', 'Edge', 'EcoSport'],
      'Hatchback': ['Fiesta', 'Focus Hatchback'],
      'Camión': ['F-150', 'F-250', 'F-350', 'Ranger'],
      'Van': ['Transit', 'E-Series'],
    },
    'Volkswagen': {
      'Carro': ['Jetta', 'Passat', 'Arteon', 'CC'],
      'Sedán': ['Jetta', 'Passat', 'Arteon'],
      'SUV': ['Tiguan', 'Atlas', 'ID.4', 'Touareg'],
      'Hatchback': ['Golf', 'Polo', 'Beetle', 'Up!'],
      'Van': ['Transporter', 'Crafter'],
    },
    'Mazda': {
      'Carro': ['Mazda3', 'Mazda6', 'MX-5'],
      'Sedán': ['Mazda3', 'Mazda6'],
      'SUV': ['CX-3', 'CX-5', 'CX-9', 'CX-30'],
      'Hatchback': ['Mazda3 Hatchback', 'MX-5'],
    },
    'BMW': {
      'Sedán': ['Serie 3', 'Serie 5', 'Serie 7', 'Serie 1', 'Serie 2'],
      'SUV': ['X1', 'X3', 'X5', 'X7', 'X2', 'X4', 'X6'],
      'Hatchback': ['Serie 1', 'Serie 2 Active Tourer'],
      'Motocicleta': ['R', 'K', 'G', 'F', 'C', 'S'],
    },
    'Mercedes-Benz': {
      'Sedán': ['Clase C', 'Clase E', 'Clase S', 'Clase A', 'Clase B'],
      'SUV': ['GLA', 'GLC', 'GLE', 'GLS', 'GLB', 'G-Class'],
      'Hatchback': ['Clase A', 'Clase B'],
      'Van': ['Sprinter', 'Vito', 'Citan'],
    },
    'Audi': {
      'Sedán': ['A3', 'A4', 'A6', 'A8', 'A1', 'A5'],
      'SUV': ['Q3', 'Q5', 'Q7', 'Q8', 'Q2', 'Q4', 'Q6'],
      'Hatchback': ['A1', 'A3 Sportback'],
    },
    'Lexus': {
      'Sedán': ['IS', 'ES', 'GS', 'LS'],
      'SUV': ['UX', 'NX', 'RX', 'GX', 'LX'],
    },
    'Infiniti': {
      'Sedán': ['Q50', 'Q60', 'M37', 'G37'],
      'SUV': ['QX30', 'QX50', 'QX60', 'QX80'],
    },
    'Acura': {
      'Sedán': ['ILX', 'TLX', 'RLX'],
      'SUV': ['CDX', 'RDX', 'MDX', 'ZDX'],
    },
    'Genesis': {
      'Sedán': ['G70', 'G80', 'G90'],
      'SUV': ['GV70', 'GV80'],
    },
    'Subaru': {
      'Sedán': ['Impreza', 'Legacy', 'WRX'],
      'SUV': ['Crosstrek', 'Forester', 'Outback', 'Ascent'],
      'Hatchback': ['Impreza', 'WRX'],
    },
    'Volvo': {
      'Sedán': ['S60', 'S90'],
      'SUV': ['XC40', 'XC60', 'XC90'],
      'Hatchback': ['V40', 'V60', 'V90'],
    },
    'Jaguar': {
      'Sedán': ['XE', 'XF', 'XJ'],
      'SUV': ['E-Pace', 'F-Pace', 'I-Pace'],
    },
    'Land Rover': {
      'SUV': ['Range Rover Evoque', 'Range Rover Velar', 'Range Rover Sport', 'Range Rover', 'Defender', 'Discovery'],
    },
    'Porsche': {
      'Sedán': ['Panamera', 'Taycan'],
      'SUV': ['Macan', 'Cayenne'],
    },
    'Yamaha': {
      'Motocicleta': ['YZF', 'FZ', 'MT', 'XT', 'WR', 'TMAX', 'XSR', 'FJR', 'VMAX', 'Bolt', 'Star'],
    },
    'Suzuki': {
      'Motocicleta': ['GSX', 'GSF', 'DL', 'RM', 'DR', 'V-Strom', 'Bandit', 'Katana'],
    },
    'Kawasaki': {
      'Motocicleta': ['Ninja', 'Z', 'KLR', 'Versys', 'Vulcan', 'Concours', 'W800', 'KLX'],
    },
    'KTM': {
      'Motocicleta': ['Duke', 'RC', 'Adventure', 'Enduro', 'Super Duke', 'Super Adventure'],
    },
    'Ducati': {
      'Motocicleta': ['Monster', 'Panigale', 'Multistrada', 'Scrambler', 'Diavel', 'Streetfighter'],
    },
    'Harley-Davidson': {
      'Motocicleta': ['Sportster', 'Softail', 'Touring', 'CVO', 'Street', 'LiveWire'],
    },
    'Aprilia': {
      'Motocicleta': ['RSV4', 'Tuono', 'Shiver', 'Dorsoduro', 'Caponord', 'Pegaso'],
    },
    'Triumph': {
      'Motocicleta': ['Speed Triple', 'Daytona', 'Tiger', 'Bonneville', 'Rocket', 'Scrambler'],
    },
    'Royal Enfield': {
      'Motocicleta': ['Classic', 'Bullet', 'Continental GT', 'Himalayan', 'Interceptor'],
    },
    'Bajaj': {
      'Motocicleta': ['Pulsar', 'Discover', 'Dominar', 'Avenger', 'CT'],
    },
    'TVS': {
      'Motocicleta': ['Apache', 'Jupiter', 'Scooty', 'Ntorq', 'Raider'],
    },
    'Hero': {
      'Motocicleta': ['Splendor', 'Passion', 'Karizma', 'Xtreme', 'Glamour'],
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
      'Camión': ['D-Max', 'NPR', 'FTR'],
      'Van': ['NPR'],
    },
    'Mitsubishi': {
      'Carro': ['Mirage', 'Lancer', 'Galant'],
      'Sedán': ['Mirage', 'Lancer', 'Galant'],
      'SUV': ['Outlander', 'Eclipse Cross', 'ASX', 'Montero'],
      'Camión': ['L200', 'Triton'],
    },
    'Peugeot': {
      'Hatchback': ['208', '308', '2008'],
      'Van': ['Partner', 'Expert'],
    },
    'Renault': {
      'Hatchback': ['Clio', 'Megane', 'Captur'],
      'Van': ['Kangoo', 'Master', 'Trafic'],
    },
    'Fiat': {
      'Hatchback': ['500', 'Punto', 'Tipo'],
      'Van': ['Ducato', 'Doblo'],
    },
    'Seat': {
      'Hatchback': ['Ibiza', 'Leon', 'Arona'],
      'SUV': ['Ateca', 'Tarraco'],
    },
    'Skoda': {
      'Hatchback': ['Fabia', 'Octavia', 'Kamiq'],
      'SUV': ['Kodiaq', 'Karoq'],
    },
    'Opel': {
      'Hatchback': ['Corsa', 'Astra', 'Crossland'],
      'SUV': ['Grandland', 'Mokka'],
    },
    'Jeep': {
      'SUV': ['Renegade', 'Compass', 'Cherokee', 'Grand Cherokee', 'Wrangler', 'Gladiator'],
    },
    'Cadillac': {
      'Sedán': ['ATS', 'CTS', 'XTS', 'CT6'],
      'SUV': ['XT4', 'XT5', 'XT6', 'Escalade'],
    },
    'Lincoln': {
      'Sedán': ['MKZ', 'Continental'],
      'SUV': ['Corsair', 'Nautilus', 'Aviator', 'Navigator'],
    },
    'Buick': {
      'Sedán': ['Regal', 'LaCrosse'],
      'SUV': ['Encore', 'Envision', 'Enclave'],
    },
    'Mini': {
      'Hatchback': ['Cooper', 'Cooper S', 'John Cooper Works', 'Clubman'],
      'SUV': ['Countryman'],
    },
    'Smart': {
      'Hatchback': ['Fortwo', 'Forfour'],
    },
    'Abarth': {
      'Hatchback': ['500', '124 Spider'],
    },
    'Alfa Romeo': {
      'Sedán': ['Giulia', 'Stelvio'],
      'SUV': ['Stelvio'],
      'Hatchback': ['Giulietta'],
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

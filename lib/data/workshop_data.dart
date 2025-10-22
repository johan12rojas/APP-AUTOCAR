import 'package:latlong2/latlong.dart';
import '../models/workshop.dart';

class WorkshopData {
  static const LatLng cucutaCenter = LatLng(7.8942, -72.5071); // Centro de Cúcuta

  static List<Workshop> get allWorkshops => [
    Workshop(
      id: 'serviautos_jairo',
      name: 'Serviautos Jairo',
      description: 'Aceite de motor, llantas, frenos, baterías, refrigerantes, filtros de aceite, alineación y balanceo',
      location: const LatLng(7.8849, -72.4962), // Corral de Piedra, Sevilla
      address: 'Corral de Piedra, Sevilla, Cúcuta',
      phone: '+57 300 123 4567',
      specialties: ['Aceite de Motor', 'Llantas', 'Frenos', 'Baterías', 'Refrigerantes', 'Filtros', 'Alineación', 'Balanceo'],
      vehicleTypes: ['carro'],
      services: ['Cambio de aceite', 'Llantas', 'Frenos', 'Baterías', 'Refrigerantes', 'Filtros de aceite', 'Alineación', 'Balanceo'],
      rating: 4.5,
      reviewCount: 28,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_el_motorista',
      name: 'Taller El Motorista',
      description: 'Cambio de aceite, frenos, baterías, revisión de motor, mantenimiento general',
      location: const LatLng(7.8935, -72.5074), // Av 7 con Calle 9, La Playa
      address: 'Av 7 con Calle 9, La Playa, Cúcuta',
      phone: '+57 300 234 5678',
      specialties: ['Cambio de Aceite', 'Frenos', 'Baterías', 'Revisión de Motor', 'Mantenimiento General'],
      vehicleTypes: ['moto'],
      services: ['Cambio de aceite', 'Frenos', 'Baterías', 'Revisión de motor', 'Mantenimiento general'],
      rating: 4.6,
      reviewCount: 35,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_la_10',
      name: 'Taller La 10',
      description: 'Cambio de aceite, filtros, frenos, refrigerantes, balanceo, mantenimiento preventivo',
      location: const LatLng(7.8881, -72.5052), // Calle 10 #2E-45, La Riviera
      address: 'Calle 10 #2E-45, La Riviera, Cúcuta',
      phone: '+57 300 345 6789',
      specialties: ['Cambio de Aceite', 'Filtros', 'Frenos', 'Refrigerantes', 'Balanceo', 'Mantenimiento Preventivo'],
      vehicleTypes: ['carro'],
      services: ['Cambio de aceite', 'Filtros', 'Frenos', 'Refrigerantes', 'Balanceo', 'Mantenimiento preventivo'],
      rating: 4.4,
      reviewCount: 42,
      workingHours: ['Lunes a Viernes: 7:30 AM - 6:30 PM', 'Sábados: 8:00 AM - 3:00 PM'],
    ),

    Workshop(
      id: 'moto_repuestos_la_union',
      name: 'Moto Repuestos La Union',
      description: 'Aceite de motor, filtros, llantas, frenos, baterías',
      location: const LatLng(7.8944, -72.5110), // Barrio La Union
      address: 'Barrio La Union, Cúcuta',
      phone: '+57 300 456 7890',
      specialties: ['Aceite de Motor', 'Filtros', 'Llantas', 'Frenos', 'Baterías'],
      vehicleTypes: ['moto'],
      services: ['Aceite de motor', 'Filtros', 'Llantas', 'Frenos', 'Baterías'],
      rating: 4.3,
      reviewCount: 28,
      workingHours: ['Lunes a Viernes: 8:00 AM - 6:00 PM', 'Sábados: 8:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_auto_plus',
      name: 'Taller Auto Plus',
      description: 'Aceite de motor, llantas, frenos, baterías, refrigerantes, filtros',
      location: const LatLng(7.8903, -72.5039), // Av Libertadores, Caobos
      address: 'Av Libertadores, Caobos, Cúcuta',
      phone: '+57 300 567 8901',
      specialties: ['Aceite de Motor', 'Llantas', 'Frenos', 'Baterías', 'Refrigerantes', 'Filtros'],
      vehicleTypes: ['carro'],
      services: ['Aceite de motor', 'Llantas', 'Frenos', 'Baterías', 'Refrigerantes', 'Filtros'],
      rating: 4.5,
      reviewCount: 39,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_el_paisa',
      name: 'Taller El Paisa',
      description: 'Frenos, suspensión, cambio de aceite, llantas, balanceo',
      location: const LatLng(7.8895, -72.5001), // Cl 2N #7E-12, Los Caobos
      address: 'Cl 2N #7E-12, Los Caobos, Cúcuta',
      phone: '+57 300 678 9012',
      specialties: ['Frenos', 'Suspensión', 'Cambio de Aceite', 'Llantas', 'Balanceo'],
      vehicleTypes: ['carro'],
      services: ['Frenos', 'Suspensión', 'Cambio de aceite', 'Llantas', 'Balanceo'],
      rating: 4.2,
      reviewCount: 31,
      workingHours: ['Lunes a Viernes: 7:30 AM - 6:00 PM', 'Sábados: 8:00 AM - 3:00 PM'],
    ),

    Workshop(
      id: 'moto_taller_sevilla',
      name: 'Moto Taller Sevilla',
      description: 'Aceite de motor, frenos, refrigerantes, filtros, llantas',
      location: const LatLng(7.8867, -72.4943), // Barrio Sevilla
      address: 'Barrio Sevilla, Cúcuta',
      phone: '+57 300 789 0123',
      specialties: ['Aceite de Motor', 'Frenos', 'Refrigerantes', 'Filtros', 'Llantas'],
      vehicleTypes: ['moto'],
      services: ['Aceite de motor', 'Frenos', 'Refrigerantes', 'Filtros', 'Llantas'],
      rating: 4.4,
      reviewCount: 26,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_don_luis',
      name: 'Taller Don Luis',
      description: 'Electricidad automotriz, baterías, aceite de motor, filtros, refrigerantes',
      location: const LatLng(7.8889, -72.4968), // Calle 11 con Av 5E, Blanco
      address: 'Calle 11 con Av 5E, Blanco, Cúcuta',
      phone: '+57 300 890 1234',
      specialties: ['Electricidad Automotriz', 'Baterías', 'Aceite de Motor', 'Filtros', 'Refrigerantes'],
      vehicleTypes: ['carro'],
      services: ['Electricidad automotriz', 'Baterías', 'Aceite de motor', 'Filtros', 'Refrigerantes'],
      rating: 4.6,
      reviewCount: 44,
      workingHours: ['Lunes a Viernes: 7:30 AM - 6:30 PM', 'Sábados: 8:00 AM - 3:00 PM'],
    ),

    Workshop(
      id: 'moto_servicio_el_amigo',
      name: 'Moto Servicio El Amigo',
      description: 'Aceite, llantas, frenos, filtros, baterías',
      location: const LatLng(7.8931, -72.5098), // Calle 8 con Av 2E
      address: 'Calle 8 con Av 2E, Cúcuta',
      phone: '+57 300 901 2345',
      specialties: ['Aceite', 'Llantas', 'Frenos', 'Filtros', 'Baterías'],
      vehicleTypes: ['moto'],
      services: ['Aceite', 'Llantas', 'Frenos', 'Filtros', 'Baterías'],
      rating: 4.3,
      reviewCount: 29,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_auto_express',
      name: 'Taller Auto Express',
      description: 'Aceite de motor, llantas, frenos, baterías, alineación y balanceo',
      location: const LatLng(7.8908, -72.5065), // Av 6E #12-45, La Playa
      address: 'Av 6E #12-45, La Playa, Cúcuta',
      phone: '+57 300 012 3456',
      specialties: ['Aceite de Motor', 'Llantas', 'Frenos', 'Baterías', 'Alineación', 'Balanceo'],
      vehicleTypes: ['carro'],
      services: ['Aceite de motor', 'Llantas', 'Frenos', 'Baterías', 'Alineación', 'Balanceo'],
      rating: 4.5,
      reviewCount: 37,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_turbo_diesel',
      name: 'Taller Turbo Diesel',
      description: 'Diesel, filtros, refrigerantes, aceite, frenos',
      location: const LatLng(7.9007, -72.5123), // Av 1 con Calle 3N, San Andresito
      address: 'Av 1 con Calle 3N, San Andresito, Cúcuta',
      phone: '+57 300 123 4567',
      specialties: ['Diesel', 'Filtros', 'Refrigerantes', 'Aceite', 'Frenos'],
      vehicleTypes: ['carro'],
      services: ['Diesel', 'Filtros', 'Refrigerantes', 'Aceite', 'Frenos'],
      rating: 4.7,
      reviewCount: 52,
      workingHours: ['Lunes a Viernes: 7:30 AM - 6:30 PM', 'Sábados: 8:00 AM - 3:00 PM'],
    ),

    Workshop(
      id: 'moto_center_norte',
      name: 'Moto Center Norte',
      description: 'Aceite de motor, frenos, llantas, filtros, mantenimiento general',
      location: const LatLng(7.8989, -72.5087), // Calle 5N #7E-20, San Luis
      address: 'Calle 5N #7E-20, San Luis, Cúcuta',
      phone: '+57 300 234 5678',
      specialties: ['Aceite de Motor', 'Frenos', 'Llantas', 'Filtros', 'Mantenimiento General'],
      vehicleTypes: ['moto'],
      services: ['Aceite de motor', 'Frenos', 'Llantas', 'Filtros', 'Mantenimiento general'],
      rating: 4.4,
      reviewCount: 33,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_la_rueda',
      name: 'Taller La Rueda',
      description: 'Alineación, balanceo, frenos, llantas, filtros',
      location: const LatLng(7.8922, -72.5059), // Cl 9 #2E-23, Loma de Bolivar
      address: 'Cl 9 #2E-23, Loma de Bolivar, Cúcuta',
      phone: '+57 300 345 6789',
      specialties: ['Alineación', 'Balanceo', 'Frenos', 'Llantas', 'Filtros'],
      vehicleTypes: ['carro'],
      services: ['Alineación', 'Balanceo', 'Frenos', 'Llantas', 'Filtros'],
      rating: 4.6,
      reviewCount: 41,
      workingHours: ['Lunes a Viernes: 7:30 AM - 6:00 PM', 'Sábados: 8:00 AM - 3:00 PM'],
    ),

    Workshop(
      id: 'moto_servicio_el_viejo',
      name: 'Moto Servicio El Viejo',
      description: 'Aceite de motor, frenos, refrigerantes, baterías',
      location: const LatLng(7.9143, -72.5081), // Barrio Aeropuerto
      address: 'Barrio Aeropuerto, Cúcuta',
      phone: '+57 300 456 7890',
      specialties: ['Aceite de Motor', 'Frenos', 'Refrigerantes', 'Baterías'],
      vehicleTypes: ['moto'],
      services: ['Aceite de motor', 'Frenos', 'Refrigerantes', 'Baterías'],
      rating: 4.2,
      reviewCount: 24,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_los_hermanos',
      name: 'Taller Los Hermanos',
      description: 'Aceite, frenos, baterías, refrigerantes, filtros de aceite',
      location: const LatLng(7.8897, -72.5034), // Av 9E #14-70, La Playa
      address: 'Av 9E #14-70, La Playa, Cúcuta',
      phone: '+57 300 567 8901',
      specialties: ['Aceite', 'Frenos', 'Baterías', 'Refrigerantes', 'Filtros de Aceite'],
      vehicleTypes: ['carro'],
      services: ['Aceite', 'Frenos', 'Baterías', 'Refrigerantes', 'Filtros de aceite'],
      rating: 4.3,
      reviewCount: 36,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_servi_motor',
      name: 'Taller Servi Motor',
      description: 'Aceite de motor, frenos, llantas, filtros, baterías',
      location: const LatLng(7.8927, -72.5062), // Av 2E con Calle 7, Blanco
      address: 'Av 2E con Calle 7, Blanco, Cúcuta',
      phone: '+57 300 678 9012',
      specialties: ['Aceite de Motor', 'Frenos', 'Llantas', 'Filtros', 'Baterías'],
      vehicleTypes: ['moto'],
      services: ['Aceite de motor', 'Frenos', 'Llantas', 'Filtros', 'Baterías'],
      rating: 4.4,
      reviewCount: 30,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_auto_norte',
      name: 'Taller Auto Norte',
      description: 'Aceite de motor, llantas, frenos, baterías, refrigerantes, alineación',
      location: const LatLng(7.8920, -72.5050), // Av Libertadores, frente a Ventura Plaza
      address: 'Av Libertadores, frente a Ventura Plaza, Cúcuta',
      phone: '+57 300 789 0123',
      specialties: ['Aceite de Motor', 'Llantas', 'Frenos', 'Baterías', 'Refrigerantes', 'Alineación'],
      vehicleTypes: ['carro'],
      services: ['Aceite de motor', 'Llantas', 'Frenos', 'Baterías', 'Refrigerantes', 'Alineación'],
      rating: 4.5,
      reviewCount: 43,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_moto_power',
      name: 'Taller Moto Power',
      description: 'Aceite de motor, frenos, refrigerantes, baterías, filtros',
      location: const LatLng(7.8911, -72.5071), // Av 5 con Cl 8, La Playa
      address: 'Av 5 con Cl 8, La Playa, Cúcuta',
      phone: '+57 300 890 1234',
      specialties: ['Aceite de Motor', 'Frenos', 'Refrigerantes', 'Baterías', 'Filtros'],
      vehicleTypes: ['moto'],
      services: ['Aceite de motor', 'Frenos', 'Refrigerantes', 'Baterías', 'Filtros'],
      rating: 4.3,
      reviewCount: 27,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),

    Workshop(
      id: 'taller_el_dieselero',
      name: 'Taller El Dieselero',
      description: 'Diesel, refrigerantes, frenos, filtros, aceite',
      location: const LatLng(7.9003, -72.5102), // Av 1E #3N-12, San Andresito
      address: 'Av 1E #3N-12, San Andresito, Cúcuta',
      phone: '+57 300 901 2345',
      specialties: ['Diesel', 'Refrigerantes', 'Frenos', 'Filtros', 'Aceite'],
      vehicleTypes: ['carro'],
      services: ['Diesel', 'Refrigerantes', 'Frenos', 'Filtros', 'Aceite'],
      rating: 4.6,
      reviewCount: 48,
      workingHours: ['Lunes a Viernes: 7:30 AM - 6:30 PM', 'Sábados: 8:00 AM - 3:00 PM'],
    ),

    Workshop(
      id: 'taller_servitec',
      name: 'Taller Servitec',
      description: 'Aceite, llantas, frenos, baterías, alineación y balanceo',
      location: const LatLng(7.8884, -72.5041), // Av 8E con Cl 12, Loma de Bolivar
      address: 'Av 8E con Cl 12, Loma de Bolivar, Cúcuta',
      phone: '+57 300 012 3456',
      specialties: ['Aceite', 'Llantas', 'Frenos', 'Baterías', 'Alineación', 'Balanceo'],
      vehicleTypes: ['carro'],
      services: ['Aceite', 'Llantas', 'Frenos', 'Baterías', 'Alineación', 'Balanceo'],
      rating: 4.4,
      reviewCount: 34,
      workingHours: ['Lunes a Viernes: 7:00 AM - 6:00 PM', 'Sábados: 7:00 AM - 4:00 PM'],
    ),
  ];

  /// Obtiene talleres por tipo de vehículo
  static List<Workshop> getWorkshopsByVehicleType(String vehicleType) {
    return allWorkshops.where((workshop) => 
      workshop.servesVehicleType(vehicleType)
    ).toList();
  }

  /// Obtiene talleres por especialidad
  static List<Workshop> getWorkshopsBySpecialty(String specialty) {
    return allWorkshops.where((workshop) => 
      workshop.hasSpecialty(specialty)
    ).toList();
  }

  /// Obtiene talleres cercanos a una ubicación
  static List<Workshop> getNearbyWorkshops(LatLng location, {double radiusKm = 10.0}) {
    return allWorkshops.where((workshop) => 
      workshop.distanceFrom(location) <= radiusKm
    ).toList();
  }

  /// Obtiene talleres ordenados por distancia
  static List<Workshop> getWorkshopsSortedByDistance(LatLng location) {
    final workshops = List<Workshop>.from(allWorkshops);
    workshops.sort((a, b) => 
      a.distanceFrom(location).compareTo(b.distanceFrom(location))
    );
    return workshops;
  }

  /// Busca talleres por nombre o descripción
  static List<Workshop> searchWorkshops(String query) {
    final lowerQuery = query.toLowerCase();
    return allWorkshops.where((workshop) => 
      workshop.name.toLowerCase().contains(lowerQuery) ||
      workshop.description.toLowerCase().contains(lowerQuery) ||
      workshop.address.toLowerCase().contains(lowerQuery) ||
      workshop.specialties.any((specialty) => 
        specialty.toLowerCase().contains(lowerQuery)
      )
    ).toList();
  }

  /// Obtiene talleres abiertos 24 horas
  static List<Workshop> get24HourWorkshops() {
    return allWorkshops.where((workshop) => workshop.isOpen24Hours).toList();
  }

  /// Obtiene talleres con mejor calificación
  static List<Workshop> getTopRatedWorkshops({double minRating = 4.5}) {
    return allWorkshops.where((workshop) => 
      workshop.rating >= minRating
    ).toList();
  }
}

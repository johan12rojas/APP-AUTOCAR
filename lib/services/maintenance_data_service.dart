class MaintenanceDataService {
  // Datos de mantenimientos específicos para Cúcuta, Colombia
  static Map<String, MaintenanceInfo> getMaintenanceData() {
    return {
      'oil': MaintenanceInfo(
        tipo: 'oil',
        tipoDisplayName: 'Cambio de Aceite',
        costoEstimado: 85000, // Pesos colombianos
        tallerRecomendado: 'Autoservicio El Motor',
        ubicacionTaller: 'Av. Libertadores #15-23, Cúcuta',
        descripcion: 'Cambio de aceite de motor y filtro',
        duracionEstimada: '30-45 minutos',
        kilometrajeIntervalo: 5000,
      ),
      'tires': MaintenanceInfo(
        tipo: 'tires',
        tipoDisplayName: 'Rotación de Llantas',
        costoEstimado: 45000,
        tallerRecomendado: 'Llantas del Norte',
        ubicacionTaller: 'Calle 10 #8-45, Cúcuta',
        descripcion: 'Rotación y balanceo de llantas',
        duracionEstimada: '45-60 minutos',
        kilometrajeIntervalo: 10000,
      ),
      'brakes': MaintenanceInfo(
        tipo: 'brakes',
        tipoDisplayName: 'Revisión de Frenos',
        costoEstimado: 120000,
        tallerRecomendado: 'Frenos y Embragues Cúcuta',
        ubicacionTaller: 'Av. 5 #12-67, Cúcuta',
        descripcion: 'Revisión y ajuste del sistema de frenos',
        duracionEstimada: '60-90 minutos',
        kilometrajeIntervalo: 15000,
      ),
      'battery': MaintenanceInfo(
        tipo: 'battery',
        tipoDisplayName: 'Revisión de Batería',
        costoEstimado: 35000,
        tallerRecomendado: 'Baterías del Norte',
        ubicacionTaller: 'Calle 15 #6-89, Cúcuta',
        descripcion: 'Revisión del estado de la batería',
        duracionEstimada: '20-30 minutos',
        kilometrajeIntervalo: 20000,
      ),
      'coolant': MaintenanceInfo(
        tipo: 'coolant',
        tipoDisplayName: 'Cambio de Líquido Refrigerante',
        costoEstimado: 95000,
        tallerRecomendado: 'Radiadores Cúcuta',
        ubicacionTaller: 'Av. 3 #18-34, Cúcuta',
        descripcion: 'Cambio de líquido refrigerante y revisión del radiador',
        duracionEstimada: '45-60 minutos',
        kilometrajeIntervalo: 30000,
      ),
      'airFilter': MaintenanceInfo(
        tipo: 'airFilter',
        tipoDisplayName: 'Cambio de Filtro de Aire',
        costoEstimado: 55000,
        tallerRecomendado: 'Filtros Automotrices',
        ubicacionTaller: 'Calle 7 #9-12, Cúcuta',
        descripcion: 'Cambio del filtro de aire del motor',
        duracionEstimada: '20-30 minutos',
        kilometrajeIntervalo: 15000,
      ),
      'alignment': MaintenanceInfo(
        tipo: 'alignment',
        tipoDisplayName: 'Alineación y Balanceo',
        costoEstimado: 80000,
        tallerRecomendado: 'Alineación del Norte',
        ubicacionTaller: 'Av. 2 #14-56, Cúcuta',
        descripcion: 'Alineación y balanceo de ruedas',
        duracionEstimada: '60-75 minutos',
        kilometrajeIntervalo: 20000,
      ),
      'chain': MaintenanceInfo(
        tipo: 'chain',
        tipoDisplayName: 'Ajuste de Cadena (Moto)',
        costoEstimado: 25000,
        tallerRecomendado: 'Taller de Motos El Rincón',
        ubicacionTaller: 'Calle 12 #5-78, Cúcuta',
        descripcion: 'Ajuste y lubricación de cadena',
        duracionEstimada: '15-25 minutos',
        kilometrajeIntervalo: 2000,
      ),
      'sparkPlug': MaintenanceInfo(
        tipo: 'sparkPlug',
        tipoDisplayName: 'Cambio de Bujías',
        costoEstimado: 75000,
        tallerRecomendado: 'Eléctricos Automotrices',
        ubicacionTaller: 'Av. 4 #11-45, Cúcuta',
        descripcion: 'Cambio de bujías y revisión del sistema eléctrico',
        duracionEstimada: '30-45 minutos',
        kilometrajeIntervalo: 25000,
      ),
      'transmission': MaintenanceInfo(
        tipo: 'transmission',
        tipoDisplayName: 'Servicio de Transmisión',
        costoEstimado: 180000,
        tallerRecomendado: 'Transmisiones del Norte',
        ubicacionTaller: 'Calle 8 #13-67, Cúcuta',
        descripcion: 'Servicio completo de transmisión',
        duracionEstimada: '90-120 minutos',
        kilometrajeIntervalo: 40000,
      ),
      'clutch': MaintenanceInfo(
        tipo: 'clutch',
        tipoDisplayName: 'Revisión de Embrague',
        costoEstimado: 150000,
        tallerRecomendado: 'Frenos y Embragues Cúcuta',
        ubicacionTaller: 'Av. 5 #12-67, Cúcuta',
        descripcion: 'Revisión y ajuste del sistema de embrague',
        duracionEstimada: '60-90 minutos',
        kilometrajeIntervalo: 50000,
      ),
      'timingBelt': MaintenanceInfo(
        tipo: 'timingBelt',
        tipoDisplayName: 'Cambio de Correa de Tiempo',
        costoEstimado: 250000,
        tallerRecomendado: 'Motor Center Cúcuta',
        ubicacionTaller: 'Av. 6 #16-89, Cúcuta',
        descripcion: 'Cambio de correa de tiempo y tensores',
        duracionEstimada: '120-150 minutos',
        kilometrajeIntervalo: 60000,
      ),
    };
  }

  static MaintenanceInfo? getMaintenanceInfo(String tipo) {
    return getMaintenanceData()[tipo];
  }

  static List<String> getAvailableMaintenanceTypes() {
    return getMaintenanceData().keys.toList();
  }

  static List<MaintenanceInfo> getAllMaintenanceInfo() {
    return getMaintenanceData().values.toList();
  }
}

class MaintenanceInfo {
  final String tipo;
  final String tipoDisplayName;
  final int costoEstimado; // En pesos colombianos
  final String tallerRecomendado;
  final String ubicacionTaller;
  final String descripcion;
  final String duracionEstimada;
  final int kilometrajeIntervalo;

  MaintenanceInfo({
    required this.tipo,
    required this.tipoDisplayName,
    required this.costoEstimado,
    required this.tallerRecomendado,
    required this.ubicacionTaller,
    required this.descripcion,
    required this.duracionEstimada,
    required this.kilometrajeIntervalo,
  });
}

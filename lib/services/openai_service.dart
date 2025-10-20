import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehiculo.dart';
import '../models/mantenimiento.dart';
import '../database/database_helper.dart';

class OpenAIService {
  static const String _apiKey = 'TU_API_KEY_AQUI'; // Reemplaza con tu API key de OpenAI
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getChatResponse({
    required String userMessage,
    Vehiculo? vehiculo,
    List<Mantenimiento>? mantenimientos,
  }) async {
    try {
      print('Iniciando solicitud a OpenAI...');
      print('Mensaje del usuario: $userMessage');
      print('Vehículo: ${vehiculo?.marca} ${vehiculo?.modelo}');
      
      // Construir el contexto del vehículo y mantenimientos
      String vehicleContext = _buildVehicleContext(vehiculo, mantenimientos);
      
      // Crear el mensaje del sistema con el contexto
      String systemMessage = '''Eres un asistente especializado en mantenimiento vehicular para la aplicación AutoCar. 
Tu función es ayudar exclusivamente con temas relacionados a vehículos y su mantenimiento.

CONTEXTO DEL VEHÍCULO ACTUAL:
$vehicleContext

INSTRUCCIONES:
1. Responde ÚNICAMENTE sobre temas relacionados a vehículos y mantenimiento
2. Usa la información del vehículo actual para dar consejos personalizados
3. Si no tienes información específica del vehículo, da consejos generales
4. Mantén un tono profesional pero amigable
5. Si el usuario pregunta algo no relacionado a vehículos, responde que solo puedes ayudar con temas automotrices
6. Responde en español
7. Sé conciso pero informativo
8. Si es necesario, pregunta por más detalles del vehículo

RESPUESTA:''';

      print('Enviando solicitud HTTP...');
      print('URL: $_baseUrl');
      print('API Key (primeros 10 caracteres): ${_apiKey.substring(0, 10)}...');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': systemMessage,
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        print('Error en la API de OpenAI: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        print('Headers: ${response.headers}');
        
        // Mensajes de error más específicos
        if (response.statusCode == 401) {
          return 'Error de autenticación con la API de OpenAI. Verifica la clave API.';
        } else if (response.statusCode == 429) {
          // Proporcionar respuesta básica cuando la cuota está excedida
          return _getBasicVehicleResponse(userMessage, vehiculo);
        } else if (response.statusCode == 500) {
          return 'Error interno del servidor de OpenAI. Intenta de nuevo más tarde.';
        } else {
          return 'Error en la API de OpenAI (${response.statusCode}). Intenta de nuevo más tarde.';
        }
      }
    } catch (e) {
      print('Error al conectar con OpenAI: $e');
      return 'Lo siento, hay un problema de conexión. Por favor, verifica tu conexión a internet e intenta de nuevo.';
    }
  }

  static String _buildVehicleContext(Vehiculo? vehiculo, List<Mantenimiento>? mantenimientos) {
    if (vehiculo == null) {
      return 'No hay información de vehículo disponible. El usuario puede no tener un vehículo registrado.';
    }

    String context = '''
VEHÍCULO ACTUAL:
- Marca: ${vehiculo.marca}
- Modelo: ${vehiculo.modelo}
- Año: ${vehiculo.ano}
- Kilometraje: ${vehiculo.kilometraje.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km
- Placa: ${vehiculo.placa}
- Tipo: ${vehiculo.tipo}
''';

    if (mantenimientos?.isNotEmpty == true) {
      context += '\nMANTENIMIENTOS RECIENTES:\n';
      for (var mantenimiento in mantenimientos!.take(5)) {
        context += '- ${mantenimiento.tipoDisplayName}: ${mantenimiento.notas} (${mantenimiento.fecha.toString().split(' ')[0]})\n';
        if (mantenimiento.costo > 0) {
          context += '  Costo: \$${mantenimiento.costo.toStringAsFixed(2)}\n';
        }
      }
    } else {
      context += '\nNo hay mantenimientos registrados recientemente.';
    }

    // Agregar información de mantenimientos programados
    if (vehiculo.maintenance.isNotEmpty) {
      context += '\nESTADO DE MANTENIMIENTOS PROGRAMADOS:\n';
      vehiculo.maintenance.forEach((key, value) {
        String status = value.percentage <= 30 ? 'VENCIDO' : 'AL DÍA';
        context += '- $key: $status (${value.percentage.toStringAsFixed(0)}% vida útil)\n';
      });
    }

    return context;
  }

  static Future<List<Mantenimiento>> getRecentMaintenances(int vehiculoId) async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'mantenimientos',
        where: 'vehiculoId = ?',
        whereArgs: [vehiculoId],
        orderBy: 'fecha DESC',
        limit: 10,
      );

      return List.generate(maps.length, (i) {
        return Mantenimiento(
          id: maps[i]['id'],
          vehiculoId: maps[i]['vehiculoId'],
          tipo: maps[i]['tipo'],
          fecha: DateTime.parse(maps[i]['fecha']),
          kilometraje: maps[i]['kilometraje'],
          notas: maps[i]['notas'] ?? '',
          costo: maps[i]['costo']?.toDouble() ?? 0.0,
          ubicacion: maps[i]['ubicacion'] ?? '',
          status: maps[i]['status'] ?? 'completed',
        );
      });
    } catch (e) {
      print('Error al obtener mantenimientos: $e');
      return [];
    }
  }

  // Función de respaldo para cuando la API no está disponible
  static String _getBasicVehicleResponse(String userMessage, Vehiculo? vehiculo) {
    final message = userMessage.toLowerCase();
    
    // Información del vehículo actual
    String vehicleInfo = '';
    if (vehiculo != null) {
      vehicleInfo = 'Tu ${vehiculo.marca} ${vehiculo.modelo} ${vehiculo.ano} (${vehiculo.kilometraje} km)';
    }
    
    // Saludos y presentación
    if (message.contains('hola') || message.contains('saludo') || message.contains('hi') || message.contains('hey')) {
      return '¡Hola! 👋 Soy CARLO, tu asistente mecánico de AutoCar.\n\nMe encanta ayudarte con todo lo relacionado con tu vehículo. Soy especialista en mantenimiento automotriz y conozco muy bien el mercado de Cúcuta.\n\n$vehicleInfo\n\n¿En qué puedo ayudarte hoy? Puedes preguntarme sobre:\n• Mantenimientos programados\n• Cambio de aceite\n• Sistema de frenos\n• Neumáticos\n• Batería\n• Costos en Cúcuta\n• Diagnósticos básicos\n• Estadísticas de mantenimiento';
    }
    
    // Aceite y lubricación
    else if (message.contains('aceite') || message.contains('oil') || message.contains('lubricante')) {
      return '🔧 Sistema de Lubricación\n\n¡Perfecto! El aceite es el alma de tu motor. Te explico todo lo que necesitas saber:\n\nFrecuencia de cambio:\n• Sintético: Cada 10,000-15,000 km\n• Semi-sintético: Cada 7,500-10,000 km\n• Convencional: Cada 5,000-7,500 km\n\nSeñales de cambio necesario:\n• Color oscuro y espeso\n• Ruido del motor aumentado\n• Consumo de combustible elevado\n• Luz de aceite encendida\n\nTipos de aceite recomendados:\n• 5W-30 (general)\n• 10W-40 (clima cálido como Cúcuta)\n• 0W-20 (vehículos modernos)\n\n$vehicleInfo\n\n¿Tu aceite necesita cambio pronto?';
    }
    
    // Sistema de frenos
    else if (message.contains('freno') || message.contains('brake') || message.contains('frenar')) {
      return '🛑 Sistema de Frenos\n\n¡Los frenos son tu seguridad! Déjame contarte todo sobre este sistema tan importante:\n\nRevisión cada: 20,000-30,000 km\n\nSeñales de desgaste:\n• Ruido al frenar (chirrido)\n• Vibración en el pedal\n• Pedal blando o que baja\n• Distancia de frenado mayor\n• Olor a quemado\n\nComponentes principales:\n• Pastillas de freno\n• Discos/rotors\n• Líquido de frenos\n• Calipers\n• Líneas hidráulicas\n\nCostos aproximados en Cúcuta:\n• Pastillas: \$120.000 - \$300.000 COP\n• Discos: \$250.000 - \$600.000 COP\n• Líquido: \$25.000 - \$80.000 COP\n\nTalleres especializados en frenos:\n• Tecnifrenos Ruz - Especialistas en frenos y suspensión\n• Serviautos Jairo - Frenos y alineación (Calle 16 N°5-110)\n• Taller Automotriz AJ - Suspensión y frenos (Av. 5 #25-66)\n\n$vehicleInfo\n\n¿Sientes algún problema con los frenos?';
    }
    
    // Neumáticos y llantas
    else if (message.contains('llanta') || message.contains('neumático') || message.contains('tire') || message.contains('rueda') || message.contains('goma')) {
      return '🛞 Neumáticos y Llantas\n\n¡Los neumáticos son el contacto con la carretera! Te cuento todo lo importante:\n\nMantenimiento:\n• Rotación: Cada 10,000 km\n• Alineación: Cada 20,000 km\n• Balanceo: Cuando notes vibración\n• Presión: Revisar mensualmente\n\nProfundidad del dibujo:\n• Mínimo legal: 1.6mm\n• Recomendado: 3mm\n• Peligroso: Menos de 1.6mm\n\nPresión correcta:\n• Consultar manual del vehículo\n• Generalmente: 30-35 PSI\n• Revisar en frío\n\nSeñales de desgaste:\n• Desgaste irregular\n• Vibración en el volante\n• Ruido excesivo\n• Pérdida de presión frecuente\n\nTalleres especializados en llantas:\n• Tecnillantas Cúcuta - Montaje y balanceo (Diagonal Santander N° 6A-10)\n• Serviautos Jairo - Alineación y balanceo (Calle 16 N°5-110)\n• Sincrolibertadores - Alineación especializada (Calle 2A N°13E-30)\n\n$vehicleInfo\n\n¿Necesitas revisar tus neumáticos?';
    }
    
    // Batería y sistema eléctrico
    else if (message.contains('batería') || message.contains('battery') || message.contains('arranque') || message.contains('eléctrico')) {
      return '🔋 Batería y Sistema Eléctrico\n\n¡La batería es el corazón eléctrico de tu auto! Te explico todo:\n\nDuración promedio: 3-5 años\n\nSeñales de desgaste:\n• Arranque lento o difícil\n• Luces tenues\n• Sistema eléctrico intermitente\n• Corrosión en terminales\n• Batería hinchada\n\nMantenimiento:\n• Limpiar terminales mensualmente\n• Verificar nivel de electrolito\n• Revisar alternador\n• No dejar luces encendidas\n\nEspecificaciones típicas:\n• 12V para la mayoría de vehículos\n• CCA (Cold Cranking Amps): 500-800\n• Capacidad: 50-100 Ah\n\nTalleres especializados en electricidad:\n• Electripartes La Frontera - Electricidad automotriz (Calle 1 #5-39)\n• Casa de Baterías Eléctricos T - Baterías y repuestos\n• Autolab - Diagnóstico eléctrico especializado\n\n$vehicleInfo\n\n¿Tu batería está dando problemas?';
    }
    
    // Mantenimiento general
    else if (message.contains('mantenimiento') || message.contains('service') || message.contains('revisión') || message.contains('cuidado')) {
      return '⚙️ Mantenimiento Preventivo\n\n¡El mantenimiento preventivo es la clave para un auto feliz! Te explico el programa completo:\n\nPrograma recomendado:\n\nCada 5,000 km:\n• Cambio de aceite\n• Filtro de aceite\n• Revisión de niveles\n\nCada 10,000 km:\n• Rotación de neumáticos\n• Filtro de aire\n• Revisión de frenos\n\nCada 20,000 km:\n• Alineación y balanceo\n• Filtro de combustible\n• Bujías (gasolina)\n\nCada 30,000 km:\n• Líquido de frenos\n• Refrigerante\n• Transmisión\n\nBeneficios:\n• Mayor duración del vehículo\n• Mejor rendimiento\n• Menor consumo de combustible\n• Prevención de averías costosas\n\nTalleres de mantenimiento general:\n• V.I.P. CAR\'S - Serviteca y mecánica (Av. 3 #14-80)\n• Taller Ecoautos - Lubricación y mantenimiento (Calle 1N #0a-85)\n• Taller Arteautos - Mantenimiento preventivo (Av. 4 #7-50)\n• Taller Bombillo - Servicios rápidos (Av. 8)\n\n$vehicleInfo\n\n¿Qué tipo de mantenimiento necesitas?';
    }
    
    // Costos y presupuestos
    else if (message.contains('costo') || message.contains('precio') || message.contains('gasto') || message.contains('presupuesto') || message.contains('dinero') || message.contains('cúcuta')) {
      return '💰 Costos de Mantenimiento en Cúcuta, Colombia\n\nMantenimiento básico:\n• Cambio de aceite: \$80.000 - \$180.000 COP\n• Filtro de aire: \$30.000 - \$80.000 COP\n• Filtro de combustible: \$40.000 - \$120.000 COP\n\nSistema de frenos:\n• Pastillas: \$120.000 - \$300.000 COP\n• Discos: \$250.000 - \$600.000 COP\n• Líquido de frenos: \$25.000 - \$80.000 COP\n\nNeumáticos:\n• Neumático individual: \$180.000 - \$450.000 COP\n• Juego completo: \$720.000 - \$1.800.000 COP\n• Alineación: \$80.000 - \$150.000 COP\n\nSistema eléctrico:\n• Batería: \$200.000 - \$500.000 COP\n• Alternador: \$300.000 - \$800.000 COP\n• Bujías: \$25.000 - \$80.000 c/u\n\nTalleres por zona y precio:\n• Zona Industrial (económicos): Los Wichos, Mekacoches\n• Centro de la ciudad (precios medios): V.I.P. CAR\'S, Taller Arteautos\n• Zona Norte (especializados): Cúcuta Motors, Autolab\n\nFactores que afectan el costo:\n• Marca del vehículo\n• Ubicación en la ciudad\n• Tipo de servicio\n• Repuestos originales vs. genéricos\n• Temporada del año\n\n$vehicleInfo\n\n¿Te interesa algún servicio específico?';
    }
    
    // Diagnósticos y problemas
    else if (message.contains('problema') || message.contains('falla') || message.contains('error') || message.contains('diagnóstico') || message.contains('ruido')) {
      return '🔍 Diagnóstico de Problemas\n\n¡No te preocupes! Soy experto en diagnosticar problemas. Te ayudo a identificar qué está pasando:\n\nRuidos comunes:\n• Chirrido al frenar: Pastillas desgastadas → Recomiendo Tecnifrenos Ruz\n• Ruido del motor: Aceite bajo o sucio → V.I.P. CAR\'S o Taller Ecoautos\n• Vibración: Neumáticos desbalanceados → Tecnillantas Cúcuta\n• Golpeteo: Problema en suspensión → Taller Automotriz AJ\n\nLuces de advertencia:\n• Check Engine: Problema en motor → Oriolicar Taller\n• ABS: Sistema de frenos → Serviautos Jairo\n• Batería: Sistema eléctrico → Electripartes La Frontera\n• Temperatura: Sobrecalentamiento → Sincrolibertadores\n\nProblemas de rendimiento:\n• Consumo alto: Filtros sucios, neumáticos → Taller Arteautos\n• Arranque difícil: Batería débil → Casa de Baterías Eléctricos T\n• Dirección pesada: Nivel de dirección → Multiservicios Saul\n• Frenado deficiente: Pastillas, líquido → Tecnifrenos Ruz\n\n$vehicleInfo\n\n¿Qué problema específico tienes?';
    }
    
    // Filtros
    else if (message.contains('filtro') || message.contains('filter')) {
      return '🔧 Sistema de Filtros\n\n¡Los filtros son como los pulmones de tu auto! Te explico cada uno:\n\nTipos de filtros:\n\nFiltro de aceite:\n• Cambio: Cada cambio de aceite\n• Función: Limpiar impurezas del aceite\n• Costo: \$30.000 - \$80.000 COP\n\nFiltro de aire:\n• Cambio: Cada 15,000-30,000 km\n• Función: Limpiar aire del motor\n• Costo: \$50.000 - \$120.000 COP\n\nFiltro de combustible:\n• Cambio: Cada 30,000-50,000 km\n• Función: Limpiar combustible\n• Costo: \$60.000 - \$150.000 COP\n\nFiltro de habitáculo:\n• Cambio: Cada 15,000-25,000 km\n• Función: Limpiar aire del A/C\n• Costo: \$40.000 - \$100.000 COP\n\nSeñales de filtros sucios:\n• Reducción de rendimiento\n• Mayor consumo de combustible\n• Ruidos anormales\n• Olores en el habitáculo\n\n$vehicleInfo\n\n¿Cuál filtro necesitas revisar?';
    }
    
    // Refrigerante y temperatura
    else if (message.contains('refrigerante') || message.contains('coolant') || message.contains('temperatura') || message.contains('calentamiento')) {
      return '🌡️ Sistema de Refrigeración\n\n¡El sistema de refrigeración es crucial en Cúcuta! Con este calor, tu auto necesita mantenerse fresco:\n\nFunción: Mantener temperatura óptima del motor\n\nComponentes principales:\n• Radiador\n• Termostato\n• Bomba de agua\n• Mangueras\n• Ventilador\n\nRefrigerante:\n• Cambio: Cada 2-3 años\n• Tipos: Anticongelante/Agua destilada\n• Proporción: 50/50\n\nSeñales de problemas:\n• Temperatura alta en el tablero\n• Vapor del capó\n• Nivel bajo de refrigerante\n• Ruido de bomba de agua\n• Mangueras hinchadas\n\nMantenimiento:\n• Revisar nivel mensualmente\n• Cambiar cada 2-3 años\n• Inspeccionar mangueras\n• Limpiar radiador\n\nCosto aproximado: \$80.000 - \$200.000 COP\n\n$vehicleInfo\n\n¿Tu vehículo se está calentando?';
    }
    
    // Transmisión
    else if (message.contains('transmisión') || message.contains('transmission') || message.contains('caja') || message.contains('cambio')) {
      return '⚙️ Sistema de Transmisión\n\n¡La transmisión es el cerebro de tu auto! Te explico todo sobre este sistema complejo:\n\nTipos:\n• Manual: Embrague, discos\n• Automática: Líquido, convertidor\n• CVT: Cadena/correa\n\nMantenimiento:\n• Manual: Cambio de aceite cada 60,000 km\n• Automática: Cambio cada 40,000-60,000 km\n• CVT: Cambio cada 30,000-50,000 km\n\nSeñales de problemas:\n• Cambios bruscos\n• Deslizamiento de marchas\n• Ruidos anormales\n• Líquido quemado\n• Tirones\n\nCosto de servicio:\n• Cambio de aceite: \$150.000 - \$400.000 COP\n• Reparación mayor: \$800.000 - \$3.000.000 COP\n\nPrevención:\n• Cambios suaves\n• No forzar la transmisión\n• Revisar niveles regularmente\n\n$vehicleInfo\n\n¿Tienes problemas con la transmisión?';
    }
    
    // Suspensión
    else if (message.contains('suspensión') || message.contains('suspension') || message.contains('amortiguador') || message.contains('rebote')) {
      return '🚗 Sistema de Suspensión\n\n¡La suspensión es lo que te mantiene cómodo en el camino! Te explico este sistema fundamental:\n\nComponentes principales:\n• Amortiguadores\n• Resortes\n• Bujes\n• Estabilizadores\n• Rótulas\n\nSeñales de desgaste:\n• Rebote excesivo\n• Ruidos al pasar baches\n• Desgaste irregular de neumáticos\n• Vehículo se inclina al frenar\n• Dirección imprecisa\n\nDuración típica:\n• Amortiguadores: 80,000-100,000 km\n• Resortes: 150,000+ km\n• Bujes: 100,000+ km\n\nMantenimiento:\n• Inspección cada 20,000 km\n• Revisar fugas de aceite\n• Comprobar desgaste de neumáticos\n• Alineación periódica\n\nCostos en Cúcuta:\n• Amortiguador: \$150.000 - \$400.000 COP c/u\n• Juego completo: \$600.000 - \$1.800.000 COP\n• Instalación: \$200.000 - \$400.000 COP\n\n$vehicleInfo\n\n¿Sientes que la suspensión no está bien?';
    }
    
    // Talleres y recomendaciones
    else if (message.contains('taller') || message.contains('talleres') || message.contains('mecánico') || message.contains('donde') || message.contains('dónde') || message.contains('recomendación') || message.contains('recomendaciones')) {
      return '🔧 Talleres Recomendados en Cúcuta\n\n¡Perfecto! Te recomiendo los mejores talleres según tu necesidad:\n\nFRENOS Y SUSPENSIÓN:\n• Tecnifrenos Ruz - Especialistas en frenos\n• Serviautos Jairo - Frenos y alineación (Calle 16 N°5-110)\n• Taller Automotriz AJ - Suspensión y frenos (Av. 5 #25-66)\n\nLLANTAS Y ALINEACIÓN:\n• Tecnillantas Cúcuta - Montaje y balanceo (Diagonal Santander N° 6A-10)\n• Sincrolibertadores - Alineación especializada (Calle 2A N°13E-30)\n• Serviautos Jairo - Alineación y balanceo\n\nMANTENIMIENTO GENERAL:\n• V.I.P. CAR\'S - Serviteca y mecánica (Av. 3 #14-80)\n• Taller Ecoautos - Lubricación y mantenimiento (Calle 1N #0a-85)\n• Taller Arteautos - Mantenimiento preventivo (Av. 4 #7-50)\n\nELECTRICIDAD Y BATERÍAS:\n• Electripartes La Frontera - Electricidad automotriz (Calle 1 #5-39)\n• Casa de Baterías Eléctricos T - Baterías y repuestos\n\nMOTORES Y DIAGNÓSTICO:\n• Oriolicar Taller - Mecánica gasolina/diésel\n• Autolab - Diagnóstico especializado\n• Sincrolibertadores - Sincronización\n\nEMERGENCIAS:\n• Maquiautos - Grúas y remolque (Av. 6)\n• Los Wichos - Mecánica y repuestos (Canal de Bogotá)\n\n$vehicleInfo\n\n¿Qué tipo de servicio necesitas?';
    }
    
    // Motos
    else if (message.contains('moto') || message.contains('motos') || message.contains('motocicleta') || message.contains('scooter')) {
      return '🏍️ Mantenimiento de Motos\n\n¡Las motos también necesitan cuidados especiales! Te explico todo sobre mantenimiento de motocicletas:\n\nMantenimiento básico de motos:\n• Cambio de aceite: Cada 3,000-5,000 km\n• Filtro de aire: Cada 6,000-10,000 km\n• Cadena: Lubricación cada 500 km\n• Neumáticos: Presión semanal\n• Bujías: Cada 10,000-15,000 km\n\nSeñales de problemas:\n• Arranque difícil\n• Ruidos anormales\n• Vibración excesiva\n• Pérdida de potencia\n• Consumo alto de combustible\n\nTalleres especializados en motos:\n• Estándar Motos - Taller especializado en motos\n• Full Motos Cúcuta - Venta y taller para motos\n• Serviautos Jairo - Atiende carros y motos (confirmar por teléfono)\n\nCostos aproximados para motos:\n• Cambio de aceite: \$40.000 - \$80.000 COP\n• Filtro de aire: \$25.000 - \$50.000 COP\n• Bujías: \$15.000 - \$35.000 COP c/u\n• Neumático: \$80.000 - \$200.000 COP\n\n$vehicleInfo\n\n¿Tu moto necesita algún servicio específico?';
    }
    
    // Estadísticas y análisis
    else if (message.contains('estadística') || message.contains('estadísticas') || message.contains('estadisticas') || message.contains('análisis') || message.contains('datos') || message.contains('reporte')) {
      return '📊 Estadísticas de Mantenimiento\n\n¡Me encanta hablar de datos! Te comparto estadísticas súper interesantes del mercado colombiano:\n\nDatos generales del mercado colombiano:\n• 78% de vehículos necesitan mantenimiento cada 5,000 km\n• 45% de averías son por falta de mantenimiento preventivo\n• 23% del costo total del vehículo es en mantenimiento\n\nEstadísticas por tipo de vehículo:\n• Sedanes: Promedio \$2.5M COP/año en mantenimiento\n• SUVs: Promedio \$3.2M COP/año en mantenimiento\n• Pickups: Promedio \$2.8M COP/año en mantenimiento\n\nFrecuencia de servicios en Cúcuta:\n• Cambio de aceite: 67% cada 5,000 km\n• Revisión de frenos: 45% cada 10,000 km\n• Alineación: 32% cada 15,000 km\n\nCostos promedio por servicio:\n• Mantenimiento menor: \$180.000 COP\n• Mantenimiento mayor: \$850.000 COP\n• Reparación de emergencia: \$1.200.000 COP\n\nFactores climáticos en Cúcuta:\n• Temperatura promedio: 28°C\n• Humedad: 65% (afecta corrosión)\n• Lluvia: 1,200mm/año (afecta frenos)\n\n$vehicleInfo\n\n¿Te interesa algún análisis específico?';
    }
    
    // Preguntas específicas sobre el vehículo
    else if (message.contains('mi auto') || message.contains('mi carro') || message.contains('mi moto') || message.contains('vehículo')) {
      return '🚗 Información de tu Vehículo\n\n¡Qué genial que quieras saber más de tu auto! Te cuento todo lo importante:\n\n$vehicleInfo\n\nEstado general recomendado:\n• Revisar aceite cada 1,000 km\n• Presión de neumáticos mensual\n• Niveles de fluidos semanal\n• Limpieza exterior regular\n\nPróximos mantenimientos sugeridos:\n• Basado en kilometraje actual\n• Revisar manual del propietario\n• Seguir programa del fabricante\n\nConsejos de cuidado:\n• Manejo suave prolonga la vida\n• Evitar aceleraciones bruscas\n• Calentar el motor antes de manejar\n• Estacionar a la sombra (importante en Cúcuta)\n\n¿Sobre qué aspecto específico te gustaría saber más?';
    }
    
    // Respuesta por defecto mejorada
    else {
      return '🤖 CARLO - Modo Básico\n\n¡Hola! Soy CARLO, tu asistente mecánico. Aunque estoy funcionando en modo básico, puedo ayudarte con mucha información valiosa.\n\n$vehicleInfo\n\nPuedo ayudarte con:\n\n🔧 Mantenimiento:\n• Cambio de aceite y filtros\n• Sistema de frenos\n• Neumáticos y llantas\n• Batería y eléctrico\n\n🔍 Diagnósticos:\n• Problemas comunes\n• Ruidos y señales\n• Luces de advertencia\n• Rendimiento del motor\n\n💰 Costos en Cúcuta:\n• Presupuestos en pesos colombianos\n• Precios de repuestos locales\n• Talleres recomendados\n\n🏪 Talleres Especializados:\n• Frenos: Tecnifrenos Ruz, Serviautos Jairo\n• Llantas: Tecnillantas Cúcuta, Sincrolibertadores\n• Electricidad: Electripartes La Frontera\n• Motos: Estándar Motos, Full Motos Cúcuta\n\n📊 Estadísticas:\n• Datos del mercado colombiano\n• Análisis de costos\n• Frecuencia de servicios\n\n⚙️ Especializados:\n• Suspensión\n• Transmisión\n• Sistema de refrigeración\n• Filtros y fluidos\n\n¿Sobre qué tema específico te gustaría información?';
    }
  }
}

import 'package:flutter/material.dart';
import '../models/workshop.dart';
import '../models/route_info.dart';

class WorkshopCard extends StatelessWidget {
  final Workshop workshop;
  final RouteInfo? routeInfo;
  final VoidCallback? onTap;
  final VoidCallback? onGetDirections;
  final int index;

  const WorkshopCard({
    super.key,
    required this.workshop,
    this.routeInfo,
    this.onTap,
    this.onGetDirections,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el color del badge según la posición (solo para los primeros 3)
    Color badgeColor;
    if (index < 3) {
      // Usar los mismos colores que las rutas para los primeros 3
      switch (index) {
        case 0:
          badgeColor = const Color(0xFF4CAF50);  // Verde vibrante para el más cercano
          break;
        case 1:
          badgeColor = const Color(0xFFFF9800);  // Naranja vibrante para el segundo
          break;
        case 2:
          badgeColor = const Color(0xFFE91E63);  // Rosa vibrante para el tercero
          break;
        default:
          badgeColor = const Color(0xFF9E9E9E);
      }
    } else {
      badgeColor = const Color(0xFF9E9E9E);
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Badge de posición
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del taller
                        Text(
                          workshop.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    
                    const SizedBox(height: 2),
                    
                    // Dirección
                    Text(
                      workshop.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Información de ruta
                    if (routeInfo != null)
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 12,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${routeInfo!.formattedDistance} • ${routeInfo!.formattedDuration}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // Icono de tipo de vehículo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: workshop.vehicleTypes.contains('moto') 
                      ? Colors.orange.withOpacity(0.1)
                      : const Color(0xFF1A1A2E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  workshop.vehicleTypes.contains('moto') 
                      ? Icons.motorcycle 
                      : Icons.directions_car,
                  color: workshop.vehicleTypes.contains('moto') 
                      ? Colors.orange 
                      : const Color(0xFF1A1A2E),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Ejemplo de cómo usar imágenes en la aplicación AUTOCAR
/// 
/// Este archivo muestra diferentes formas de cargar y usar imágenes
/// desde la carpeta de assets.
class ImageExamples extends StatelessWidget {
  const ImageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        title: const Text('Ejemplos de Imágenes'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Logos',
              [
                _buildImageExample(
                  'Logo Principal',
                  'assets/images/logos/logo_autocar.png',
                  'Logo principal de AUTOCAR',
                ),
                _buildImageExample(
                  'Logo Oscuro',
                  'assets/images/logos/logo_autocar_dark.png',
                  'Logo para tema oscuro',
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSection(
              'Iconos',
              [
                _buildImageExample(
                  'Icono de Vehículo',
                  'assets/images/icons/car_icon.png',
                  'Icono para vehículos',
                ),
                _buildImageExample(
                  'Icono de Mantenimiento',
                  'assets/images/icons/maintenance_icon.png',
                  'Icono para mantenimientos',
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSection(
              'Vehículos',
              [
                _buildImageExample(
                  'Sedán',
                  'assets/images/vehicles/car_sedan.png',
                  'Imagen de sedán',
                ),
                _buildImageExample(
                  'Motocicleta',
                  'assets/images/vehicles/motorcycle.png',
                  'Imagen de motocicleta',
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSection(
              'Mantenimiento',
              [
                _buildImageExample(
                  'Cambio de Aceite',
                  'assets/images/maintenance/oil_change.png',
                  'Icono de cambio de aceite',
                ),
                _buildImageExample(
                  'Servicio de Frenos',
                  'assets/images/maintenance/brake_service.png',
                  'Icono de servicio de frenos',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ...children,
      ],
    );
  }

  Widget _buildImageExample(String title, String imagePath, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        color: Colors.white70,
                        size: 30,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Código de ejemplo:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Image.asset('$imagePath')",
                        style: const TextStyle(
                          color: Color(0xFF32CD32),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget helper para cargar imágenes con manejo de errores
class SafeImageAsset extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeImageAsset({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(
          Icons.image_not_supported,
          color: Colors.white70,
        );
      },
    );
  }
}

/// Widget helper para logos con diferentes variantes
class LogoWidget extends StatelessWidget {
  final double size;
  final bool isDark;
  final String? customPath;

  const LogoWidget({
    super.key,
    this.size = 100,
    this.isDark = true,
    this.customPath,
  });

  @override
  Widget build(BuildContext context) {
    String logoPath = customPath ?? (isDark 
        ? 'assets/images/logos/logo_autocar_dark.png'
        : 'assets/images/logos/logo_autocar_light.png');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: SafeImageAsset(
          imagePath: logoPath,
          width: size,
          height: size,
          errorWidget: Icon(
            Icons.directions_car,
            size: size * 0.6,
            color: const Color(0xFFFF6B35),
          ),
        ),
      ),
    );
  }
}

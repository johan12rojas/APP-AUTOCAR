import 'package:flutter/material.dart';
import '../theme/autocar_theme.dart';

/// Widget para fondo con degradado moderno elegante
class BackgroundGradientWidget extends StatelessWidget {
  final Widget child;
  final bool showPattern;

  const BackgroundGradientWidget({
    super.key,
    required this.child,
    this.showPattern = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradiente principal
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF081126),
                Color(0xFF0E2242),
                Color(0xFF15335D),
                Color(0xFF1B3E75),
                Color(0xFF0A1A33),
              ],
              stops: [0.0, 0.25, 0.55, 0.8, 1.0],
            ),
          ),
        ),

        // Luz central difuminada (para efecto de profundidad)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.2),
                radius: 0.9,
                colors: [
                  Colors.white.withOpacity(0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),

        // Opcional: patrón de puntos
        if (showPattern)
          DottedBackgroundWidget(
            dotColor: Colors.white.withOpacity(0.08),
            dotSize: 1.2,
            spacing: 32.0,
            child: child,
          )
        else
          child,
      ],
    );
  }
}

/// Widget para fondo con imagen personalizada (mantenido por compatibilidad)
class BackgroundImageWidget extends StatelessWidget {
  final Widget child;
  final String? imagePath;
  final bool showGradient;
  final AlignmentGeometry alignment;

  const BackgroundImageWidget({
    super.key,
    required this.child,
    this.imagePath,
    this.showGradient = true,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Imagen de fondo
        image: imagePath != null
            ? DecorationImage(
                image: AssetImage(imagePath!),
                fit: BoxFit.cover,
                alignment: alignment,
                opacity: 0.3, // Transparencia para que no interfiera con el contenido
              )
            : null,
        // Gradiente de fondo
        gradient: showGradient
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AutocarTheme.darkBackground,
                  AutocarTheme.darkBackground.withValues(alpha: 0.8),
                  AutocarTheme.darkBackground,
                ],
                stops: const [0.0, 0.5, 1.0],
              )
            : null,
      ),
      child: child,
    );
  }
}

/// Widget para fondo con patrón de puntos
class DottedBackgroundWidget extends StatelessWidget {
  final Widget child;
  final Color dotColor;
  final double dotSize;
  final double spacing;

  const DottedBackgroundWidget({
    super.key,
    required this.child,
    this.dotColor = Colors.white,
    this.dotSize = 2.0,
    this.spacing = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedPatternPainter(
        dotColor: dotColor.withValues(alpha: 0.1),
        dotSize: dotSize,
        spacing: spacing,
      ),
      child: child,
    );
  }
}

/// Painter para crear patrón de puntos
class DottedPatternPainter extends CustomPainter {
  final Color dotColor;
  final double dotSize;
  final double spacing;

  DottedPatternPainter({
    required this.dotColor,
    required this.dotSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget para efectos de partículas animadas
class AnimatedParticlesWidget extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color particleColor;

  const AnimatedParticlesWidget({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor = Colors.white,
  });

  @override
  State<AnimatedParticlesWidget> createState() => _AnimatedParticlesWidgetState();
}

class _AnimatedParticlesWidgetState extends State<AnimatedParticlesWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        x: (index * 50.0) % 400,
        y: (index * 30.0) % 800,
        size: 1.0 + (index % 3),
        speed: 0.5 + (index % 2),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            particles: _particles,
            animationValue: _controller.value,
            particleColor: widget.particleColor.withValues(alpha: 0.3),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final Color particleColor;

  ParticlesPainter({
    required this.particles,
    required this.animationValue,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = (particle.x + animationValue * particle.speed * 100) % size.width;
      final y = (particle.y + animationValue * particle.speed * 50) % size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

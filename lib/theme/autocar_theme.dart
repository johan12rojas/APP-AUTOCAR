import 'package:flutter/material.dart';

/// Tema personalizado para AUTOCAR con colores más vivos y modernos
class AutocarTheme {
  // Colores principales más vivos
  static const Color primaryBlue = Color(0xFF1E40AF);      // Azul más vibrante
  static const Color secondaryBlue = Color(0xFF3B82F6);    // Azul brillante
  static const Color accentOrange = Color(0xFFFF6B35);    // Naranja vibrante
  static const Color accentPink = Color(0xFFEC4899);       // Rosa vibrante
  static const Color accentGreen = Color(0xFF10B981);     // Verde esmeralda
  static const Color accentPurple = Color(0xFF8B5CF6);    // Púrpura vibrante
  static const Color accentYellow = Color(0xFFF59E0B);    // Amarillo dorado
  
  // Colores de estado
  static const Color successGreen = Color(0xFF10B981);     // Verde éxito
  static const Color warningOrange = Color(0xFFF59E0B);   // Naranja advertencia
  static const Color errorRed = Color(0xFFEF4444);        // Rojo error
  static const Color infoBlue = Color(0xFF3B82F6);         // Azul información
  
  // Colores de fondo
  static const Color darkBackground = Color(0xFF1E3A8A);  // Fondo azul principal
  static const Color cardBackground = Color(0xFF3B82F6);  // Fondo de cards azul claro
  static const Color surfaceBackground = Color(0xFF1E40AF); // Fondo de superficie azul oscuro
  
  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);      // Texto principal
  static const Color textSecondary = Color(0xFFCBD5E1);    // Texto secundario
  static const Color textMuted = Color(0xFF94A3B8);       // Texto atenuado

  /// Tema oscuro personalizado
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentOrange,
        surface: cardBackground,
        error: errorRed,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBackground.withValues(alpha: 0.2),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: textPrimary,
          elevation: 4,
          shadowColor: accentOrange.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Roboto',
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  /// Gradientes personalizados
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, secondaryBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, accentPink],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, successGreen],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningOrange, accentYellow],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorRed, accentPink],
  );

  /// Sombras personalizadas
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: accentOrange.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Colores para componentes específicos
  static const Map<String, Color> componentColors = {
    'oil': accentYellow,
    'tires': accentGreen,
    'brakes': errorRed,
    'battery': accentPurple,
    'engine': accentOrange,
    'transmission': accentPink,
  };

  /// Obtener color por nombre de componente
  static Color getComponentColor(String component) {
    return componentColors[component.toLowerCase()] ?? accentOrange;
  }

  /// Obtener gradiente por nombre de componente
  static LinearGradient getComponentGradient(String component) {
    switch (component.toLowerCase()) {
      case 'oil':
        return warningGradient;
      case 'tires':
        return successGradient;
      case 'brakes':
        return errorGradient;
      case 'battery':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentPurple, accentPink],
        );
      default:
        return accentGradient;
    }
  }
}

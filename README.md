# 🚗 AUTOCAR - Bitácora de Mantenimiento Vehicular

Una aplicación móvil moderna desarrollada en Flutter para la gestión completa de vehículos y sus mantenimientos con una interfaz de usuario completamente rediseñada.

## ✨ Características Principales

- 📱 **Interfaz Moderna** con Material Design 3 y tema oscuro elegante
- 🗄️ **Base de datos local** SQLite para almacenamiento offline
- 📊 **Gestión completa** de vehículos y mantenimientos
- 🔍 **Sistema de alertas inteligente** con niveles de prioridad
- 📈 **Monitoreo en tiempo real** del estado de componentes
- ⚙️ **Configuración moderna** con Java 17 y Core Library Desugaring

## 🎨 Diseño Visual

### Paleta de Colores
- **Azul Principal**: `#1E3A8A` (Fondo oscuro elegante)
- **Azul Secundario**: `#3B82F6` (Cards y elementos)
- **Naranja Acento**: `#FF6B35` (Elementos destacados)
- **Verde**: `#32CD32` (Estado positivo)
- **Rojo**: `#FF4500` (Alertas críticas)

### Componentes Visuales
- **Cards redondeados** con efectos de transparencia
- **Barras de progreso** para estado de componentes
- **Iconos Material Design** consistentes
- **Navegación por tabs** en la parte inferior
- **Animaciones suaves** y transiciones fluidas

## 🏗️ Arquitectura de Pantallas

### 🏠 Pantalla de Inicio
- **Vista general del vehículo** con información principal
- **Kilometraje actual** con opción de edición
- **Próximo mantenimiento** programado
- **Estado de componentes** con barras de progreso:
  - 🛢️ Aceite de Motor
  - 🚗 Llantas
  - 🛑 Frenos
  - 🔋 Batería

### 📖 Pantalla de Bitácora
- **Historial completo** de mantenimientos
- **Estadísticas del vehículo** (total mantenimientos, último servicio)
- **Información detallada** de cada mantenimiento
- **Filtros por fecha** y tipo de servicio

### 🚨 Pantalla de Alertas
- **Sistema inteligente** de notificaciones
- **Niveles de prioridad** (Crítica, Media, Baja)
- **Alertas automáticas** basadas en:
  - Kilometraje próximo a mantenimiento
  - Estado crítico de componentes
  - Recordatorios programados

### 👤 Pantalla de Perfil
- **Información del usuario** y estadísticas
- **Gestión de vehículos** (agregar, editar, eliminar)
- **Opciones de configuración** y exportación
- **Información de la aplicación**

## 🛠️ Stack Tecnológico

- **Flutter SDK** >=3.0.0
- **Dart** - Lenguaje de programación
- **SQLite** (sqflite) - Base de datos local
- **Material Design 3** - Sistema de diseño moderno
- **Java 17** + Kotlin DSL - Configuración Android moderna
- **Gradle 8.12** - Sistema de construcción optimizado

## 📋 Requisitos

- Flutter SDK >=3.0.0
- Dart SDK
- Android Studio / VS Code
- Dispositivo Android o emulador

## 🚀 Instalación y Configuración

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/johan12rojas/APP-AUTOCAR.git
   cd APP-AUTOCAR
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🔧 Configuración Técnica

### Java 17 + Core Library Desugaring
El proyecto está configurado con Java 17 y Core Library Desugaring habilitado para máxima compatibilidad:

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### Base de Datos Mejorada
- **Esquema v2** con campos adicionales para estado de componentes
- **Migración automática** desde versiones anteriores
- **Relaciones optimizadas** entre vehículos y mantenimientos
- **Datos de ejemplo** incluidos para demostración

## 📱 Funcionalidades Detalladas

### Gestión de Vehículos
- ✅ Registrar nuevos vehículos con información completa
- ✅ Editar información de vehículos existentes
- ✅ Eliminar vehículos con confirmación
- ✅ Monitoreo del estado de componentes
- ✅ Cambio de tipo de vehículo (Auto/Moto)

### Gestión de Mantenimientos
- ✅ Registrar mantenimientos por vehículo
- ✅ Diferentes tipos de mantenimiento
- ✅ Fechas y kilometraje automático
- ✅ Notas y observaciones detalladas
- ✅ Historial completo por vehículo
- ✅ Costos y talleres registrados

### Sistema de Alertas
- ✅ Alertas automáticas por kilometraje
- ✅ Notificaciones de estado crítico
- ✅ Priorización inteligente de alertas
- ✅ Acciones rápidas desde las alertas
- ✅ Historial de alertas resueltas

## 📊 Estructura del Proyecto

```
lib/
├── database/
│   └── database_helper.dart    # Helper para SQLite con migración v2
├── models/
│   ├── vehiculo.dart           # Modelo Vehículo mejorado
│   └── mantenimiento.dart      # Modelo Mantenimiento
├── screens/
│   ├── main_navigation_screen.dart  # Navegación principal
│   ├── inicio_screen.dart           # Pantalla de inicio
│   ├── bitacora_screen.dart         # Historial de mantenimientos
│   ├── alertas_screen.dart          # Sistema de alertas
│   └── perfil_screen.dart           # Perfil del usuario
├── utils/
│   └── data_seeder.dart        # Datos de ejemplo
└── main.dart                   # Punto de entrada con datos de ejemplo
```

## 🔄 Flujo de Datos

1. **Usuario** interactúa con la interfaz moderna
2. **Pantalla** valida y procesa datos con animaciones
3. **DatabaseHelper** maneja operaciones SQLite optimizadas
4. **Modelos** estructuran los datos con nuevos campos
5. **UI** se actualiza con efectos visuales suaves

## 🎯 Próximas Funcionalidades

- [ ] Exportar datos a PDF con diseño profesional
- [ ] Notificaciones push para mantenimientos próximos
- [ ] Gráficos de gastos por vehículo y período
- [ ] Sincronización con servidor en la nube
- [ ] Modo oscuro/claro personalizable
- [ ] Backup automático en Google Drive
- [ ] Integración con calendario del sistema
- [ ] Reconocimiento de voz para notas rápidas

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**Johan Rojas**
- GitHub: [@johan12rojas](https://github.com/johan12rojas)

## 📞 Soporte

Si tienes preguntas o necesitas ayuda, puedes:
- Abrir un issue en GitHub
- Contactar al desarrollador

---

⭐ **¡Dale una estrella al proyecto si te gusta!** ⭐

## 🎉 Changelog

### v2.0.0 - MAJOR UI REDESIGN
- ✨ Interfaz completamente rediseñada con Material Design 3
- 🎨 Nuevo sistema de colores y tema oscuro elegante
- 📱 Navegación por tabs con 4 secciones principales
- 🚨 Sistema de alertas inteligente con prioridades
- 📊 Monitoreo en tiempo real del estado de componentes
- 🗄️ Base de datos mejorada con esquema v2
- 🔧 Configuración técnica actualizada a Java 17
- 📈 Optimizaciones de rendimiento y memoria
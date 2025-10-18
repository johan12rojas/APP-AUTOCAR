# 🚗 AUTOCAR - Bitácora de Mantenimiento Vehicular

Una aplicación móvil desarrollada en Flutter para la gestión completa de vehículos y sus mantenimientos.

## ✨ Características

- 📱 **Interfaz moderna** con Material Design
- 🗄️ **Base de datos local** SQLite para almacenamiento offline
- 📊 **Gestión completa** de vehículos y mantenimientos
- 🔍 **Búsqueda y filtrado** de registros
- 📈 **Historial detallado** de mantenimientos por vehículo
- ⚙️ **Configuración moderna** con Java 17

## 🏗️ Arquitectura

### Modelos de Datos
- **Vehículo**: Información básica del vehículo (marca, modelo, año, etc.)
- **Mantenimiento**: Registros de mantenimientos con fechas, tipos y detalles

### Pantallas
- **Home**: Vista principal con lista de vehículos
- **Detalle Vehículo**: Información completa del vehículo y sus mantenimientos
- **Agregar Vehículo**: Formulario para registrar nuevos vehículos
- **Detalle Mantenimiento**: Información detallada de cada mantenimiento
- **Agregar Mantenimiento**: Formulario para registrar nuevos mantenimientos

### Base de Datos
- **SQLite** con helper personalizado
- **Esquemas optimizados** para consultas rápidas
- **Relaciones** entre vehículos y mantenimientos

## 🛠️ Stack Tecnológico

- **Flutter SDK** >=3.0.0
- **Dart** - Lenguaje de programación
- **SQLite** (sqflite) - Base de datos local
- **Material Design** - Sistema de diseño
- **Java 17** + Kotlin DSL - Configuración Android moderna
- **Gradle 8.12** - Sistema de construcción

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

### Gradle Optimizado
Configuración optimizada para compilación rápida:
- **R8 Full Mode** habilitado
- **Compilación paralela**
- **Cache de Gradle** activado

## 📱 Funcionalidades

### Gestión de Vehículos
- ✅ Registrar nuevos vehículos
- ✅ Editar información de vehículos existentes
- ✅ Eliminar vehículos
- ✅ Ver lista completa de vehículos

### Gestión de Mantenimientos
- ✅ Registrar mantenimientos por vehículo
- ✅ Diferentes tipos de mantenimiento
- ✅ Fechas y kilometraje
- ✅ Notas y observaciones
- ✅ Historial completo por vehículo

### Base de Datos
- ✅ Esquema optimizado
- ✅ Relaciones entre tablas
- ✅ Consultas eficientes
- ✅ Migración automática

## 📊 Estructura del Proyecto

```
lib/
├── database/
│   └── database_helper.dart    # Helper para SQLite
├── models/
│   ├── vehiculo.dart           # Modelo Vehículo
│   └── mantenimiento.dart      # Modelo Mantenimiento
├── screens/
│   ├── home_screen.dart        # Pantalla principal
│   ├── vehiculo_detail_screen.dart
│   ├── add_vehiculo_screen.dart
│   ├── mantenimiento_detail_screen.dart
│   └── add_mantenimiento_screen.dart
└── main.dart                   # Punto de entrada
```

## 🔄 Flujo de Datos

1. **Usuario** interactúa con la interfaz
2. **Pantalla** valida y procesa datos
3. **DatabaseHelper** maneja operaciones SQLite
4. **Modelos** estructuran los datos
5. **UI** se actualiza con los resultados

## 🎯 Próximas Funcionalidades

- [ ] Exportar datos a PDF
- [ ] Notificaciones de mantenimientos próximos
- [ ] Gráficos de gastos por vehículo
- [ ] Sincronización con servidor
- [ ] Modo oscuro
- [ ] Backup automático

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
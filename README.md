# 🚗 AutoCar - Aplicación de Gestión de Mantenimiento Vehicular

Una aplicación móvil moderna desarrollada en Flutter para la gestión completa de vehículos y sus mantenimientos con una interfaz elegante y funcionalidades avanzadas.

## ✨ Características Principales

### 🎨 Interfaz Moderna
- **Diseño elegante** con gradientes diagonales y efectos de transparencia
- **Pantalla completa** immersive para una experiencia envolvente
- **Navegación fluida** con barra de navegación inferior estilizada
- **Tema oscuro** con colores cuidadosamente seleccionados

### 🚗 Sistema Completo de Vehículos
- **Gestión completa** de vehículos (agregar, editar, eliminar)
- **Tipos de vehículos**: Carro, Sedán, SUV, Hatchback, Motocicleta, Camión, Van
- **Sistema inteligente** de marcas y modelos predeterminados
- **Opción personalizada** para marcas/modelos no listados
- **Vista previa de imágenes** según el tipo de vehículo seleccionado
- **Formulario en pantalla completa** con diseño profesional

### 📊 Dashboard Inteligente
- **Estado de componentes** con barras de progreso mejoradas
- **Monitoreo en tiempo real** del estado del vehículo
- **Alertas inteligentes** con sistema de prioridades
- **Estadísticas detalladas** de gastos y mantenimientos

### 📝 Sistema de Mantenimiento
- **Bitácora completa** de mantenimientos
- **Registro de gastos** con acumulación automática
- **Exportación PDF** con diseño profesional
- **Seguimiento de costos** por categoría y período

### 👤 Perfil de Usuario
- **Gestión de imagen de perfil** desde galería
- **Recomendaciones inteligentes** basadas en gastos y estado del vehículo
- **Estadísticas personales** y resumen de gastos
- **Opciones de configuración** avanzadas

## 🛠️ Stack Tecnológico

- **Flutter SDK** >=3.0.0
- **Dart** - Lenguaje de programación
- **Provider** - Gestión de estado
- **SQLite** (sqflite) - Base de datos local
- **SharedPreferences** - Almacenamiento de preferencias
- **Image Picker** - Selección de imágenes
- **PDF Export** - Generación de reportes
- **Material Design 3** - Sistema de diseño moderno

## 🎨 Paleta de Colores

- **Gradiente Principal**: Azul oscuro elegante con efectos de luz
- **Naranja Acento**: `#FF6B35` (Elementos destacados)
- **Transparencias**: Efectos de cristal y profundidad
- **Contraste Optimizado**: Texto blanco sobre fondos oscuros

## 📱 Funcionalidades Detalladas

### Sistema de Vehículos
- ✅ **Agregar vehículos** con formulario completo
- ✅ **Editar información** de vehículos existentes
- ✅ **Eliminar vehículos** con confirmación
- ✅ **Cambiar vehículo activo** fácilmente
- ✅ **Sistema de marcas** predeterminadas por tipo
- ✅ **Modelos famosos** según la marca seleccionada

### Gestión de Mantenimientos
- ✅ **Registro completo** de mantenimientos
- ✅ **Seguimiento de gastos** automático
- ✅ **Alertas por kilometraje** y estado crítico
- ✅ **Exportación PDF** de reportes
- ✅ **Historial detallado** con filtros

### Interfaz de Usuario
- ✅ **Diseño responsive** para diferentes tamaños de pantalla
- ✅ **Animaciones suaves** y transiciones fluidas
- ✅ **Notificaciones mejoradas** con buen contraste
- ✅ **Formularios profesionales** con validación
- ✅ **Navegación intuitiva** entre secciones

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

3. **Configurar Android SDK** (si es necesario)
   - Crear archivo `android/local.properties` con:
   ```
   sdk.dir=C:\Users\[Usuario]\AppData\Local\Android\sdk
   flutter.sdk=C:\Users\[Usuario]\flutter
   flutter.buildMode=debug
   flutter.versionName=1.0.0
   flutter.versionCode=1
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📊 Estructura del Proyecto

```
lib/
├── database/
│   └── database_helper.dart          # Helper para SQLite
├── models/
│   ├── vehiculo.dart                 # Modelo Vehículo
│   └── mantenimiento.dart            # Modelo Mantenimiento
├── screens/
│   ├── main_navigation_screen.dart   # Navegación principal
│   ├── inicio_screen.dart            # Dashboard principal
│   ├── bitacora_screen.dart          # Historial de mantenimientos
│   ├── perfil_screen.dart            # Perfil del usuario
│   └── vehicle_form_screen.dart      # Formulario de vehículos
├── services/
│   ├── vehicle_image_service.dart    # Gestión de imágenes
│   ├── user_preferences_service.dart # Preferencias del usuario
│   ├── pdf_export_service.dart       # Exportación PDF
│   └── auto_maintenance_scheduler.dart # Programación automática
├── viewmodels/
│   └── vehiculo_viewmodel.dart       # Lógica de negocio
├── widgets/
│   └── background_widgets.dart       # Widgets de fondo
└── main.dart                         # Punto de entrada
```

## 🎯 Funcionalidades Avanzadas

### Sistema de Recomendaciones
- **Análisis de gastos** por categoría
- **Alertas críticas** para componentes en mal estado
- **Consejos de ahorro** basados en patrones de gasto
- **Predicciones de mantenimiento** próximos

### Gestión de Imágenes
- **Imágenes de perfil** desde galería o cámara
- **Vista previa en tiempo real** del vehículo seleccionado
- **Sistema de imágenes** por tipo de vehículo
- **Persistencia** de selecciones del usuario

### Exportación y Reportes
- **Reportes PDF** con diseño profesional
- **Estadísticas detalladas** de gastos
- **Historial completo** de mantenimientos
- **Formato exportable** para contabilidad

## 🔧 Configuración Técnica

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # Gestión de estado
  sqflite: ^2.3.0               # Base de datos SQLite
  shared_preferences: ^2.2.2    # Preferencias del usuario
  image_picker: ^1.0.4          # Selección de imágenes
  pdf: ^3.10.7                  # Generación de PDFs
  printing: ^5.11.1             # Impresión de documentos
  fl_chart: ^0.68.0             # Gráficos y estadísticas
```

### Configuración Android
- **Java 17** con Core Library Desugaring
- **Gradle 8.12** para construcción optimizada
- **Material Design 3** para interfaz moderna
- **Pantalla completa** immersive

## 📱 Capturas de Pantalla

### Dashboard Principal
- Vista general del vehículo con estado de componentes
- Barras de progreso para aceite, llantas, frenos, batería
- Información de kilometraje y próximo mantenimiento

### Gestión de Vehículos
- Formulario completo con vista previa de imagen
- Sistema de marcas y modelos predeterminados
- Opciones de personalización para casos especiales

### Perfil del Usuario
- Estadísticas detalladas de gastos
- Recomendaciones inteligentes
- Gestión de imagen de perfil

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

## 🎉 Changelog

### v2.1.0 - SISTEMA COMPLETO DE VEHÍCULOS
- ✨ **Formulario en pantalla completa** para agregar/editar vehículos
- 🚗 **Sistema inteligente** de marcas y modelos predeterminados
- 🎨 **Vista previa de imágenes** según tipo de vehículo
- 🔧 **Corrección de errores** en edición de vehículos
- 📱 **Notificaciones mejoradas** con mejor contraste visual
- 💾 **Persistencia de imágenes** de perfil del usuario
- 📊 **Recomendaciones inteligentes** basadas en gastos
- 🎯 **Gestión completa** de vehículos (CRUD completo)

### v2.0.0 - REDISEÑO COMPLETO
- 🎨 **Interfaz completamente rediseñada** con gradientes elegantes
- 📱 **Navegación moderna** con barra inferior estilizada
- 🚨 **Sistema de alertas** mejorado
- 📊 **Dashboard inteligente** con estadísticas
- 🗄️ **Base de datos optimizada** con nuevas funcionalidades

## 📞 Soporte

Si tienes preguntas o necesitas ayuda:
- Abrir un [issue en GitHub](https://github.com/johan12rojas/APP-AUTOCAR/issues)
- Contactar al desarrollador

---

⭐ **¡Dale una estrella al proyecto si te gusta!** ⭐

## 🚀 Próximas Funcionalidades

- [ ] **Sincronización en la nube** para respaldo automático
- [ ] **Notificaciones push** para recordatorios
- [ ] **Integración con calendario** del sistema
- [ ] **Modo offline** completo
- [ ] **Gráficos avanzados** de tendencias de gastos
- [ ] **Integración con talleres** locales
- [ ] **Sistema de respaldo** automático
- [ ] **Temas personalizables** adicionales
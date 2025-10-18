# Bitácora de Mantenimiento Vehicular

Una aplicación móvil desarrollada en Flutter para gestionar el mantenimiento de vehículos.

## Características

- **Gestión de Vehículos**: Registra y administra información de tus vehículos
- **Registro de Mantenimientos**: Lleva un control detallado de todos los mantenimientos realizados
- **Historial Completo**: Visualiza el historial de mantenimientos por vehículo
- **Persistencia de Datos**: Los datos se guardan localmente usando SQLite
- **Interfaz Intuitiva**: Diseño moderno y fácil de usar

## Funcionalidades

### Vehículos
- Agregar nuevos vehículos con información completa (marca, modelo, año, placa, color, kilometraje)
- Visualizar lista de vehículos registrados
- Ver detalles de cada vehículo

### Mantenimientos
- Registrar diferentes tipos de mantenimiento (Preventivo, Correctivo, Predictivo)
- Incluir información detallada (fecha, descripción, costo, kilometraje, taller)
- Agregar notas adicionales
- Visualizar historial completo de mantenimientos
- Eliminar registros de mantenimiento

## Instalación

1. Asegúrate de tener Flutter instalado en tu sistema
2. Clona o descarga este proyecto
3. Ejecuta `flutter pub get` para instalar las dependencias
4. Ejecuta `flutter run` para iniciar la aplicación

## Dependencias

- `sqflite`: Para la base de datos local
- `path`: Para manejo de rutas de archivos
- `intl`: Para formateo de fechas

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── vehiculo.dart
│   └── mantenimiento.dart
├── database/                 # Configuración de base de datos
│   └── database_helper.dart
└── screens/                  # Pantallas de la aplicación
    ├── home_screen.dart
    ├── add_vehiculo_screen.dart
    ├── vehiculo_detail_screen.dart
    ├── add_mantenimiento_screen.dart
    └── mantenimiento_detail_screen.dart
```

## Uso

1. **Agregar Vehículo**: Toca el botón "+" en la pantalla principal para agregar un nuevo vehículo
2. **Ver Detalles**: Toca cualquier vehículo para ver sus detalles y mantenimientos
3. **Agregar Mantenimiento**: Toca el botón "+" en la pantalla de detalles del vehículo
4. **Ver Historial**: Todos los mantenimientos se muestran ordenados por fecha
5. **Eliminar**: Puedes eliminar mantenimientos desde la pantalla de detalles

## Características Técnicas

- **Base de Datos**: SQLite local para persistencia de datos
- **Arquitectura**: Patrón MVC con separación clara de responsabilidades
- **UI**: Material Design 3 con tema personalizado
- **Validación**: Validación completa de formularios
- **Navegación**: Navegación fluida entre pantallas


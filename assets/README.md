# 📁 Assets - Recursos de AUTOCAR

Esta carpeta contiene todos los recursos visuales y multimedia de la aplicación AUTOCAR.

## 📂 Estructura de Carpetas

```
assets/
├── images/
│   ├── logos/          # Logos de la aplicación
│   ├── icons/          # Iconos específicos
│   ├── vehicles/       # Imágenes de vehículos
│   └── maintenance/    # Iconos de mantenimiento
└── fonts/             # Fuentes personalizadas
```

## 🎨 Guía de Uso

### 1. Logos (`assets/images/logos/`)
- **Propósito**: Logos principales de la aplicación
- **Archivos recomendados**:
  - `logo_autocar.png` - Logo principal
  - `logo_autocar_dark.png` - Logo para tema oscuro
  - `logo_autocar_light.png` - Logo para tema claro
  - `icon_app.png` - Icono de la app (512x512px)

### 2. Iconos (`assets/images/icons/`)
- **Propósito**: Iconos específicos para la aplicación
- **Archivos recomendados**:
  - `car_icon.png` - Icono de vehículo
  - `maintenance_icon.png` - Icono de mantenimiento
  - `alert_icon.png` - Icono de alerta
  - `profile_icon.png` - Icono de perfil

### 3. Vehículos (`assets/images/vehicles/`)
- **Propósito**: Imágenes de diferentes tipos de vehículos
- **Archivos recomendados**:
  - `car_default.png` - Vehículo por defecto
  - `car_sedan.png` - Sedán
  - `car_suv.png` - SUV
  - `motorcycle.png` - Motocicleta

### 4. Mantenimiento (`assets/images/maintenance/`)
- **Propósito**: Iconos para tipos de mantenimiento
- **Archivos recomendados**:
  - `oil_change.png` - Cambio de aceite
  - `tire_rotation.png` - Rotación de llantas
  - `brake_service.png` - Servicio de frenos
  - `battery_check.png` - Revisión de batería

### 5. Fuentes (`assets/fonts/`)
- **Propósito**: Fuentes personalizadas
- **Archivos recomendados**:
  - `Roboto-Regular.ttf` - Fuente principal
  - `Roboto-Bold.ttf` - Fuente en negrita
  - `Roboto-Light.ttf` - Fuente ligera

## 💻 Cómo Usar las Imágenes

### Carga Básica
```dart
Image.asset('assets/images/logos/logo_autocar.png')
```

### Con Manejo de Errores
```dart
Image.asset(
  'assets/images/logos/logo_autocar.png',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.directions_car);
  },
)
```

### Usando SafeImageAsset (Recomendado)
```dart
SafeImageAsset(
  imagePath: 'assets/images/logos/logo_autocar.png',
  width: 100,
  height: 100,
)
```

### Usando LogoWidget (Para logos)
```dart
LogoWidget(
  size: 120,
  isDark: true,
)
```

## 📐 Especificaciones Técnicas

### Imágenes
- **Formato**: PNG con transparencia
- **Resolución**: Mínimo 512x512px para logos principales
- **Colores**: Compatible con tema oscuro (#1E3A8A) y naranja (#FF6B35)
- **Estilo**: Moderno, minimalista, profesional

### Fuentes
- **Formato**: TTF o OTF
- **Licencia**: Verificar derechos de uso
- **Estilo**: Moderno, legible, profesional

## 🎨 Paleta de Colores

- **Azul Principal**: #1E3A8A (Fondo oscuro)
- **Azul Secundario**: #3B82F6 (Cards y elementos)
- **Naranja Acento**: #FF6B35 (Elementos destacados)
- **Verde**: #32CD32 (Estado positivo)
- **Rojo**: #FF4500 (Alertas críticas)
- **Blanco**: #FFFFFF (Texto principal)

## 📝 Notas Importantes

1. **Siempre incluye un `errorBuilder`** para manejar imágenes faltantes
2. **Usa `SafeImageAsset`** para carga segura de imágenes
3. **Mantén consistencia** en el estilo visual
4. **Verifica las licencias** de las fuentes utilizadas
5. **Optimiza las imágenes** para reducir el tamaño de la app

## 🔧 Configuración en pubspec.yaml

Las carpetas ya están configuradas en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/logos/
    - assets/images/icons/
    - assets/images/vehicles/
    - assets/images/maintenance/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

## 📱 Ejemplos de Uso

Ver `lib/examples/image_examples.dart` para ejemplos completos de cómo usar las imágenes en la aplicación.

## 🚀 Próximos Pasos

1. Agrega tus imágenes a las carpetas correspondientes
2. Ejecuta `flutter pub get` para actualizar los assets
3. Usa los widgets helper para cargar las imágenes
4. Personaliza los colores y estilos según necesites

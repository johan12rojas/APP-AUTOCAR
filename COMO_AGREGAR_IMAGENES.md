# 📸 Cómo Agregar Imágenes a AUTOCAR

## 🎯 Pasos para Agregar tu Logo

### 1. Preparar tu Imagen
- **Formato**: PNG con transparencia (recomendado)
- **Tamaño**: Mínimo 512x512px para logos principales
- **Colores**: Compatible con tema oscuro (#1E3A8A) y naranja (#FF6B35)

### 2. Ubicación de Archivos
Coloca tus imágenes en las siguientes carpetas:

```
assets/images/
├── logos/
│   ├── logo_autocar.png          # ← Tu logo principal aquí
│   ├── logo_autocar_dark.png     # ← Logo para tema oscuro
│   └── logo_autocar_light.png    # ← Logo para tema claro
├── icons/
│   ├── car_icon.png              # ← Iconos específicos
│   └── maintenance_icon.png
├── vehicles/
│   ├── car_default.png           # ← Imágenes de vehículos
│   └── motorcycle.png
└── maintenance/
    ├── oil_change.png            # ← Iconos de mantenimiento
    └── brake_service.png
```

### 3. Ejemplo de Conversión SVG a PNG

Si tienes un archivo SVG (como el ejemplo que creé), puedes convertirlo a PNG:

#### Opción 1: Herramientas Online
- **Convertio**: https://convertio.co/svg-png/
- **CloudConvert**: https://cloudconvert.com/svg-to-png
- **FreeConvert**: https://www.freeconvert.com/svg-to-png

#### Opción 2: Software Local
- **Inkscape** (gratuito): https://inkscape.org/
- **Adobe Illustrator**
- **GIMP** (gratuito): https://www.gimp.org/

### 4. Verificar la Configuración

El archivo `pubspec.yaml` ya está configurado para incluir las imágenes:

```yaml
flutter:
  assets:
    - assets/images/logos/
    - assets/images/icons/
    - assets/images/vehicles/
    - assets/images/maintenance/
```

### 5. Usar las Imágenes en el Código

#### Carga Básica
```dart
Image.asset('assets/images/logos/logo_autocar.png')
```

#### Con Manejo de Errores (Recomendado)
```dart
Image.asset(
  'assets/images/logos/logo_autocar.png',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.directions_car);
  },
)
```

#### Usando SafeImageAsset
```dart
SafeImageAsset(
  imagePath: 'assets/images/logos/logo_autocar.png',
  width: 100,
  height: 100,
)
```

#### Usando LogoWidget (Para logos)
```dart
LogoWidget(
  size: 120,
  isDark: true,
)
```

### 6. Probar la Aplicación

Después de agregar las imágenes:

1. Ejecuta `flutter pub get` para actualizar los assets
2. Ejecuta `flutter run` para probar la aplicación
3. Las imágenes aparecerán automáticamente en la interfaz

## 🎨 Especificaciones de Diseño

### Paleta de Colores
- **Azul Principal**: #1E3A8A (Fondo oscuro)
- **Azul Secundario**: #3B82F6 (Cards y elementos)
- **Naranja Acento**: #FF6B35 (Elementos destacados)
- **Verde**: #32CD32 (Estado positivo)
- **Rojo**: #FF4500 (Alertas críticas)
- **Blanco**: #FFFFFF (Texto principal)

### Estilo Recomendado
- **Moderno y minimalista**
- **Compatible con Material Design 3**
- **Transparencia cuando sea necesario**
- **Consistente con el tema oscuro**

## 📱 Dónde Aparecen las Imágenes

### Logo Principal
- Pantalla de inicio (cuando no hay vehículos)
- Header de la pantalla de inicio
- Pantalla de perfil

### Iconos
- Bottom Navigation Bar
- Cards de estado de componentes
- Botones de acción
- Indicadores de estado

### Imágenes de Vehículos
- Cards de vehículos
- Pantalla de perfil
- Selección de tipo de vehículo

### Iconos de Mantenimiento
- Tipos de mantenimiento
- Historial de servicios
- Alertas de mantenimiento

## 🔧 Solución de Problemas

### La imagen no aparece
1. Verifica que el archivo esté en la carpeta correcta
2. Ejecuta `flutter clean` y luego `flutter pub get`
3. Verifica que el nombre del archivo coincida exactamente

### Error de carga
1. Usa siempre `errorBuilder` para manejar errores
2. Verifica que el formato sea PNG o JPG
3. Asegúrate de que el archivo no esté corrupto

### La imagen se ve pixelada
1. Usa una resolución más alta (mínimo 512x512px)
2. Evita escalar imágenes pequeñas
3. Usa formatos vectoriales cuando sea posible

## 📝 Notas Importantes

- **Siempre incluye un `errorBuilder`** para manejar imágenes faltantes
- **Mantén consistencia** en el estilo visual
- **Optimiza las imágenes** para reducir el tamaño de la app
- **Usa transparencia** cuando sea necesario
- **Verifica las licencias** de las imágenes utilizadas

¡Ya tienes todo listo para agregar tus imágenes a AUTOCAR! 🚗✨

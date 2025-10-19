# 🔧 Configuración del Proyecto AutoCar

## 📋 Requisitos Previos

Antes de ejecutar el proyecto, asegúrate de tener instalado:

- **Flutter SDK** >=3.0.0
- **Dart SDK** (incluido con Flutter)
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Android SDK** configurado
- **Git** para clonar el repositorio

## 🚀 Pasos de Instalación

### 1. Clonar el Repositorio
```bash
git clone https://github.com/johan12rojas/APP-AUTOCAR.git
cd APP-AUTOCAR
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Configurar Android SDK
**IMPORTANTE**: Este paso es crucial para que el proyecto funcione.

1. **Copiar archivo de configuración**:
   ```bash
   # En Windows
   copy android\local.properties.example android\local.properties
   
   # En Linux/Mac
   cp android/local.properties.example android/local.properties
   ```

2. **Editar el archivo `android/local.properties`** con tus rutas:
   ```properties
   # Actualiza estas rutas según tu sistema
   sdk.dir=C:\\Users\\TU_USUARIO\\AppData\\Local\\Android\\sdk
   flutter.sdk=C:\\Users\\TU_USUARIO\\flutter
   flutter.buildMode=debug
   flutter.versionName=1.0.0
   flutter.versionCode=1
   ```

### 4. Encontrar las Rutas Correctas

#### Android SDK:
- Abre **Android Studio**
- Ve a **File > Settings** (o **Android Studio > Preferences** en Mac)
- Navega a **Appearance & Behavior > System Settings > Android SDK**
- Copia la ruta que aparece en "Android SDK Location"

#### Flutter SDK:
- Ejecuta en terminal: `flutter doctor`
- Busca la línea que dice "Flutter version" - ahí aparece la ruta

### 5. Verificar Configuración
```bash
flutter doctor
```

Deberías ver que Android SDK está configurado correctamente.

### 6. Ejecutar la Aplicación
```bash
flutter run
```

## 🐛 Solución de Problemas Comunes

### Error: "SDK location not found"
- Verifica que el archivo `android/local.properties` existe
- Confirma que las rutas en el archivo son correctas
- Asegúrate de que Android SDK está instalado

### Error: "Flutter SDK not found"
- Verifica que Flutter está instalado correctamente
- Confirma la ruta en `android/local.properties`
- Ejecuta `flutter doctor` para verificar la instalación

### Error: "Gradle build failed"
- Limpia el proyecto: `flutter clean`
- Reinstala dependencias: `flutter pub get`
- Verifica que tienes Java 17 instalado

### Error: "Device not found"
- Conecta un dispositivo Android o inicia un emulador
- Verifica con: `flutter devices`

## 📱 Configuración de Dispositivo

### Para Android:
1. **Habilita Opciones de Desarrollador** en tu dispositivo
2. **Activa Depuración USB**
3. **Conecta el dispositivo** por USB
4. **Autoriza la depuración** cuando aparezca el diálogo

### Para Emulador:
1. Abre **Android Studio**
2. Ve a **Tools > AVD Manager**
3. Crea un nuevo dispositivo virtual
4. Inicia el emulador

## 🔍 Verificación Final

Si todo está configurado correctamente, deberías poder:

1. ✅ Ejecutar `flutter doctor` sin errores críticos
2. ✅ Ejecutar `flutter devices` y ver tu dispositivo
3. ✅ Ejecutar `flutter run` y ver la aplicación funcionando

## 📞 Soporte

Si tienes problemas:

1. **Revisa los logs** de error en detalle
2. **Ejecuta `flutter doctor`** y comparte el resultado
3. **Verifica las rutas** en `android/local.properties`
4. **Abre un issue** en GitHub con detalles del error

---

¡Una vez configurado correctamente, podrás disfrutar de todas las funcionalidades de AutoCar! 🚗✨

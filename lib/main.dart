import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'utils/data_seeder.dart';
import 'theme/autocar_theme.dart';
import 'viewmodels/vehiculo_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataSeeder.seedData();
  runApp(const AUTOCARApp());
}

class AUTOCARApp extends StatelessWidget {
  const AUTOCARApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurar el color de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return ChangeNotifierProvider(
      create: (context) => VehiculoViewModel(),
      child: MaterialApp(
        title: 'AUTOCAR - Bitácora de Mantenimiento',
        theme: AutocarTheme.darkTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/data_seeder.dart';
import 'theme/autocar_theme.dart';

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

    return MaterialApp(
      title: 'AUTOCAR - Bitácora de Mantenimiento',
      theme: AutocarTheme.darkTheme,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


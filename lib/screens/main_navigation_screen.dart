import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'bitacora_screen.dart';
import 'alertas_screen.dart';
import 'perfil_screen.dart';
import '../theme/autocar_theme.dart';
import '../widgets/background_widgets.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const InicioScreen(),
    const BitacoraScreen(),
    const AlertasScreen(),
    const PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGradientWidget(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: AutocarTheme.primaryGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: AutocarTheme.cardShadow,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AutocarTheme.accentOrange,
          unselectedItemColor: AutocarTheme.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/car_icon.png',
                width: 24,
                height: 24,
                color: _currentIndex == 0 ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.home,
                  color: _currentIndex == 0 ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
                ),
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/maintenance_icon.png',
                width: 24,
                height: 24,
                color: _currentIndex == 1 ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.book,
                  color: _currentIndex == 1 ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
                ),
              ),
              label: 'Bitácora',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/alert_icon.png',
                width: 24,
                height: 24,
                color: _currentIndex == 2 ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.notifications,
                  color: _currentIndex == 2 ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
                ),
              ),
              label: 'Alertas',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/icons/profile_icon.png',
                width: 24,
                height: 24,
                color: _currentIndex == 3 ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  color: _currentIndex == 3 ? AutocarTheme.accentOrange : AutocarTheme.textSecondary,
                ),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'bitacora_screen.dart';
import 'alertas_screen.dart';
import 'perfil_screen.dart';
import '../widgets/background_widgets.dart';
import '../widgets/chatbot_floating_button.dart';

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
      body: Stack(
        children: [
          BackgroundGradientWidget(
            child: _screens[_currentIndex],
          ),
          const ChatbotFloatingButton(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.95),
              const Color(0xFF16213E).withValues(alpha: 0.98),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, -5),
              spreadRadius: 2,
            ),
          ],
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withValues(alpha: 0.4),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 10,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _currentIndex == 0 
                        ? const Color(0xFFFF6B35)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _currentIndex == 0 ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: 18,
                    color: _currentIndex == 0 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _currentIndex == 1 
                        ? const Color(0xFFFF6B35)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _currentIndex == 1 ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    Icons.book_rounded,
                    size: 18,
                    color: _currentIndex == 1 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                label: 'Bitácora',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _currentIndex == 2 
                        ? const Color(0xFFFF6B35)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _currentIndex == 2 ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    size: 18,
                    color: _currentIndex == 2 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                label: 'Alertas',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _currentIndex == 3 
                        ? const Color(0xFFFF6B35)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _currentIndex == 3 ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: _currentIndex == 3 ? Colors.white : Colors.white.withValues(alpha: 0.4),
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

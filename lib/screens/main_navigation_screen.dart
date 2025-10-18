import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'bitacora_screen.dart';
import 'alertas_screen.dart';
import 'perfil_screen.dart';
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
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
            unselectedItemColor: Colors.white.withValues(alpha: 0.6),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: _currentIndex == 0 
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFF6B35).withValues(alpha: 0.8),
                              const Color(0xFFFF8A65).withValues(alpha: 0.6),
                            ],
                          )
                        : null,
                    color: _currentIndex == 0 
                        ? null
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
                    color: _currentIndex == 0 ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: _currentIndex == 1 
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFF6B35).withValues(alpha: 0.8),
                              const Color(0xFFFF8A65).withValues(alpha: 0.6),
                            ],
                          )
                        : null,
                    color: _currentIndex == 1 
                        ? null
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
                    color: _currentIndex == 1 ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                label: 'Bitácora',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: _currentIndex == 2 
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFF6B35).withValues(alpha: 0.8),
                              const Color(0xFFFF8A65).withValues(alpha: 0.6),
                            ],
                          )
                        : null,
                    color: _currentIndex == 2 
                        ? null
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
                    color: _currentIndex == 2 ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                label: 'Alertas',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: _currentIndex == 3 
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFF6B35).withValues(alpha: 0.8),
                              const Color(0xFFFF8A65).withValues(alpha: 0.6),
                            ],
                          )
                        : null,
                    color: _currentIndex == 3 
                        ? null
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
                    color: _currentIndex == 3 ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

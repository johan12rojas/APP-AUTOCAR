import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _nombreUsuarioKey = 'nombre_usuario';
  static const String _emailUsuarioKey = 'email_usuario';
  
  static Future<void> guardarNombreUsuario(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nombreUsuarioKey, nombre);
  }
  
  static Future<String> obtenerNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nombreUsuarioKey) ?? 'Usuario AUTOCAR';
  }
  
  static Future<void> guardarEmailUsuario(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailUsuarioKey, email);
  }
  
  static Future<String> obtenerEmailUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailUsuarioKey) ?? 'usuario@autocar.com';
  }
}

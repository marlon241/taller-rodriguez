import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Map<String, dynamic>? _currentUser;
  static const String _key = 'session_user';

  static Map<String, dynamic>? get currentUser => _currentUser;
  static String get cargo => _currentUser?['cargo']?.toString() ?? '';
  static String get rolActual => cargo;
  static bool get esAdmin => cargo.toLowerCase() == 'administrador';
  static bool get esSecretaria => cargo.toLowerCase() == 'secretaria';
  static bool get esMecanico => ['mecanico', 'empleado'].contains(cargo.toLowerCase());

  // Llama esto al iniciar sesión
  static Future<void> iniciar(Map<String, dynamic> userData) async {
    _currentUser = userData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(userData));
  }

  // Llama esto en main.dart antes de runApp para restaurar sesión
  static Future<bool> restaurar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _currentUser = jsonDecode(raw) as Map<String, dynamic>;
        return true; // había sesión guardada
      }
    } catch (_) {}
    return false; // no había sesión
  }

  static Future<void> cerrar() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
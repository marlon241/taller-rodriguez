import 'package:flutter/material.dart';
import '../pages/clientes.dart';
import '../pages/login_pages.dart';
import '../screens/home_screen.dart';
import '../screens/admin_register.dart';
import '../pages/perfil.dart';

class AppRoutes {
  static const String clientes = '/clientes';
  static const String login = '/login';
  static const String home = '/dashboard';
  static const String adminRegister = '/registroAdmin';
  static const String perfil = '/perfil';

  static Map<String, WidgetBuilder> get routes => {
    adminRegister: (context) => const RegistroAdmin(),
    login: (context) => const LoginPage(),
    clientes: (context) => const ClientesPage(),
    home: (context) => const HomeScreen(),
    perfil: (context) => const PerfilPage(),
  };
}
import 'package:flutter/material.dart';
import '../pages/clientes.dart';
import '../pages/login_pages.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  static const String clientes = '/clientes';
  static const String login = '/login';
  static const String home = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    clientes: (context) => const ClientesPage(),
    home: (context) => const HomeScreen(),
  };
}
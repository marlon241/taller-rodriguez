import 'package:flutter/material.dart';

import '../pages/clientes.dart';
import '../pages/login_pages.dart';
import '../screens/home_screen.dart';
import '../screens/admin_register.dart';
import '../pages/perfil.dart';
import '../pages/ofertas.dart';
import '../pages/factura.dart';
import '../pages/inventario.dart';
import '../pages/caja.dart';
import '../pages/empleados.dart';
import '../pages/vehiculo.dart';


class AppRoutes {
  static const String clientes = '/clientes';
  static const String login = '/login';
  static const String home = '/dashboard';
  static const String adminRegister = '/registroAdmin';
  static const String perfil = '/perfil';
  static const String ofertas = '/ofertas';
  static const String facturacion = '/factura';
  static const String inventario = '/inventario';
  static const String caja = '/caja';
  static const String empleados = '/empleados';
  static const String vehiculo = '/vehiculo';

  static Map<String, WidgetBuilder> get routes => {
    adminRegister: (context) => const RegistroAdmin(),
    login: (context) => const LoginPage(),
    clientes: (context) => const ClientesPage(),
    home: (context) => const HomeScreen(),
    perfil: (context) => const PerfilPage(),
    ofertas: (context) => const OfertasScreen(),
    facturacion: (context) => const FacturacionScreen(),
    inventario: (context) => const InventarioPage(),
    caja: (context) => const CajaPage(),
    empleados: (context) => const EmpleadosPage(),
    vehiculo: (context) => const VehiculoPage(),
  };
}

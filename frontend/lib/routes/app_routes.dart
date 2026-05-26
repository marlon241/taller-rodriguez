import 'package:flutter/material.dart';
import 'package:frontend/services/session_service.dart';

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
import '../pages/vehiculos.dart';
import '../pages/proveedores.dart';
import '../pages/historialTurnos.dart';
import '../pages/reportes.dart';
import '../pages/historialFacturas.dart';

class AppRoutes {
  static const String clientes      = '/clientes';
  static const String login         = '/login';
  static const String home          = '/dashboard';
  static const String adminRegister = '/registroAdmin';
  static const String perfil        = '/perfil';
  static const String ofertas       = '/ofertas';
  static const String facturacion   = '/facturacion';
  static const String inventario    = '/inventario';
  static const String caja          = '/caja';
  static const String empleados     = '/empleados';
  static const String vehiculos     = '/vehiculos';
  static const String proveedores   = '/proveedores';
  static const String historialTurnos = '/historialTurnos';
  static const String reportes      = '/reportes';
  static const String historialFacturas = '/historialFacturas';


  // Rutas que cualquier empleado (no admin) puede acceder
  static const _rutasEmpleado = {vehiculos, perfil, home, login};

  /// Genera la ruta verificando permisos.
  /// Si el empleado intenta acceder a una ruta restringida
  /// lo redirige a /vehiculos.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? login;

    // Verificar acceso si ya hay sesión activa y no es admin
   if (SessionService.rolActual.isNotEmpty &&
        !SessionService.esAdmin &&
        !_rutasEmpleado.contains(name)) {
      return MaterialPageRoute(
        builder: (_) => const VehiculosPage(),
        settings: const RouteSettings(name: vehiculos),
      );
    }

    final builder = _builders[name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }

    // Ruta no encontrada → login
    return MaterialPageRoute(
      builder: (_) => const LoginPage(),
      settings: const RouteSettings(name: login),
    );
  }

  static final Map<String, WidgetBuilder> _builders = {
    historialFacturas: (_) => const HistorialFacturasPage(),
    adminRegister:  (_) => const RegistroAdmin(),
    login:          (_) => const LoginPage(),
    clientes:       (_) => const ClientesPage(),
    home:           (_) => const HomeScreen(),
    perfil:         (_) => const PerfilPage(),
    ofertas:        (_) => const OfertasScreen(),
    facturacion:    (_) => const FacturacionScreen(),
    inventario:     (_) => const InventarioPage(),
    caja:           (_) => const CajaPage(),
    empleados:      (_) => const EmpleadosPage(),
    vehiculos:      (_) => const VehiculosPage(),
    proveedores:    (_) => const ProveedoresScreen(),
    historialTurnos:(_) => const HistorialTurnosPage(),
    reportes:       (_) => const ReportesScreen(),
  };

  // Mantener el getter para compatibilidad con código existente
  static Map<String, WidgetBuilder> get routes => _builders;
}
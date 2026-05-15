import 'package:flutter/material.dart';
import 'sidebar_element.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    // En móvil el sidebar se usa como Drawer, no como widget directo
    return isWide ? _buildSidebar(context) : const SizedBox.shrink();
  }

  Widget _buildSidebar(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 5),
        SizedBox(
          width: 180,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/dashboard'),
                  child: Image.asset(
                    'assets/logo_taller.png',
                    width: 130,
                    height: 130,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _item(context, 'Vehiculos taller', 'coche', '/vehiculos'),
                      _item(context, 'Caja', 'caja', '/caja'),
                      _item(context, 'Clientes', 'cliente', '/clientes'),
                      _item(context, 'Ofertas', 'ofertas', '/ofertas'),
                      _item(context, 'Facturacion', 'facturacion', '/facturacion'),
                      _item(context, 'Inventario', 'inventario', '/inventario'),
                      _item(context, 'Bodega', 'bodega', '/bodega'),
                      _item(context, 'Proveedores', 'proveedores', '/proveedores'),
                      _item(context, 'Empleados', 'empleados', '/empleados'),
                      _item(context, 'Reportes', 'reportes', '/reportes'),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              // Perfil siempre fijo abajo
              SidebarElement(
                nombre: 'Mi perfil',
                icono: 'perfil',
                seleccionado: ModalRoute.of(context)?.settings.name == '/perfil',
                ruta: '/perfil',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(BuildContext context, String nombre, String icono, String ruta) {
    return Column(
      children: [
        SidebarElement(
          nombre: nombre,
          icono: icono,
          seleccionado: ModalRoute.of(context)?.settings.name == ruta,
          ruta: ruta,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

class SidebarDrawerContent extends StatelessWidget {
  const SidebarDrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
               child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/dashboard'),
                  child: Image.asset(
                    'assets/logo_taller.png',
                    width: 130,
                    height: 130,
                  ),
                ),
              ),
            ),
            // Items con scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _drawerItem(context, 'Vehiculos taller', 'coche', '/vehiculos'),
                    _drawerItem(context, 'Caja', 'caja', '/caja'),
                    _drawerItem(context, 'Clientes', 'cliente', '/clientes'),
                    _drawerItem(context, 'Ofertas', 'ofertas', '/ofertas'),
                    _drawerItem(context, 'Facturacion', 'facturacion', '/facturacion'),
                    _drawerItem(context, 'Inventario', 'inventario', '/inventario'),
                    _drawerItem(context, 'Bodega', 'bodega', '/bodega'),
                    _drawerItem(context, 'Proveedores', 'proveedores', '/proveedores'),
                    _drawerItem(context, 'Empleados', 'empleados', '/empleados'),
                    _drawerItem(context, 'Reportes', 'reportes', '/reportes'),
                  ],
                ),
              ),
            ),
            // Perfil fijo abajo
            _drawerItem(context, 'Mi perfil', 'perfil', '/perfil'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String nombre, String icono, String ruta) {
    return SidebarElement(
      nombre: nombre,
      icono: icono,
      seleccionado: ModalRoute.of(context)?.settings.name == ruta,
      ruta: ruta,
    );
  }
}
import 'package:flutter/material.dart';
import 'sidebar_element.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
    SizedBox(width: 8,),
    Container(
      width: 180,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Image.asset(  
              'assets/logo_taller.png',
              width: 130,
              height: 130,
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Vehiculos taller',
              icono: 'coche',
              seleccionado: ModalRoute.of(context)?.settings.name == '/vehiculos',
              ruta: '/vehiculos',
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Caja',
              icono: 'caja',
              seleccionado: ModalRoute.of(context)?.settings.name == '/caja',
              ruta: '/caja',
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Clientes',
              icono: 'cliente',
              seleccionado: ModalRoute.of(context)?.settings.name == '/clientes',
              ruta: '/clientes',
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Ofertas',
              icono: 'ofertas',
              seleccionado: ModalRoute.of(context)?.settings.name == '/ofertas',
              ruta: '/ofertas',
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Facturacion',
              icono: 'facturacion',
              seleccionado: ModalRoute.of(context)?.settings.name == '/facturacion',
              ruta: '/facturacion',
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Inventario',
              icono: 'inventario',
              seleccionado: ModalRoute.of(context)?.settings.name == '/inventario',
              ruta: '/inventario',
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Bodega',
              icono: 'bodega',
              seleccionado: ModalRoute.of(context)?.settings.name == '/bodega',
              ruta: '/bodega',
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Proveedores',
              icono: 'proveedores',
              seleccionado: ModalRoute.of(context)?.settings.name == '/proveedores',
              ruta: '/proveedores',
            ),
            const SizedBox(height: 5),
            SidebarElement(
              nombre: 'Empleados',
              icono: 'empleados',
              seleccionado: ModalRoute.of(context)?.settings.name == '/empleados',
              ruta: '/empleados',
            ),
            const SizedBox(height: 15),
            SidebarElement(
              nombre: 'NombreUsuario',
              icono: 'perfil',
              seleccionado: ModalRoute.of(context)?.settings.name == '/perfil',
              ruta: '/perfil',
            ),
        ],
      ),
    ),

    ],);
    
  }
}
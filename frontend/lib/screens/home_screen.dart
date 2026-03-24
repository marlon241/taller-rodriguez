import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../widgets/dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<MenuItemModel> menuItems = [
    MenuItemModel(label: 'Caja',        imagePath: 'assets/images/caja.png'),
    MenuItemModel(label: 'Clientes',    imagePath: 'assets/images/clientes.png'),
    MenuItemModel(label: 'Empleados',   imagePath: 'assets/images/empleados.png'),
    MenuItemModel(label: 'Ofertas',     imagePath: 'assets/images/ofertas.png'),
    MenuItemModel(label: 'Inventario',  imagePath: 'assets/images/inventario.png'),
    MenuItemModel(label: 'Facturación', imagePath: 'assets/images/facturacion.png'),
    MenuItemModel(label: 'Vehículos',   imagePath: 'assets/images/vehiculos.png'),
    MenuItemModel(label: 'Reportes',    imagePath: 'assets/images/reportes.png'),
    MenuItemModel(label: 'Proveedores', imagePath: 'assets/images/proveedores.png'),
    MenuItemModel(label: 'Mi perfil',   imagePath: 'assets/images/mi_perfil.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          children: [
           
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              color: const Color(0xFFF0F0F0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.settings,
                      size: 40,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Taller Rodriguez',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

           
       Expanded(
  child: Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000), // 👈 límite del ancho
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 👈 más columnas en escritorio
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return DashboardCard(item: menuItems[index]);
        },
      ),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}
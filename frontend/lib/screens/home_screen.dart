import 'package:flutter/material.dart';
import 'package:frontend/services/session_service.dart';
import '../models/menu_item_model.dart';
import '../widgets/dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Todos los módulos disponibles
  static final List<MenuItemModel> _allItems = [
    MenuItemModel(label: 'Caja', imagePath: 'assets/sidebar_false/caja.png'),
    MenuItemModel(label: 'Clientes', imagePath: 'assets/sidebar_false/cliente.png'),
    MenuItemModel(label: 'Empleados', imagePath: 'assets/sidebar_false/empleados.png'),
    MenuItemModel(label: 'Ofertas', imagePath: 'assets/sidebar_false/ofertas.png'),
    MenuItemModel(label: 'Inventario', imagePath: 'assets/sidebar_false/inventario.png'),
    MenuItemModel(label: 'Facturacion', imagePath: 'assets/sidebar_false/facturacion.png'),
    MenuItemModel(label: 'Vehiculos', imagePath: 'assets/sidebar_false/coche.png'),
    MenuItemModel(label: 'Reportes', imagePath: 'assets/sidebar_false/reportes.png'),
    MenuItemModel(label: 'Proveedores', imagePath: 'assets/sidebar_false/proveedores.png'),
    MenuItemModel(label: 'Perfil', imagePath: 'assets/sidebar_false/perfil.png'),
  ];

  List<MenuItemModel> get _visibleItems {
    if (SessionService.esAdmin || SessionService.esSecretaria) {
      return _allItems;
    } else {
      // Mecánicos y empleados normales
      return _allItems.where((item) {
        final label = item.label.toLowerCase();
        return label == 'vehiculos' || label == 'perfil';
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              color: const Color(0xFFF0F0F0),
              child: Row(
                children: [
                  // Logo centrado
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/logo_taller.png', width: 50, height: 50),
                        SizedBox(width: 12),
                        Text(
                          'Taller Rodriguez',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  // Avatar del usuario
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/perfil'),
                    child: _buildUserAvatar(),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No tienes permisos para ver módulos'))
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final ruta = '/${item.label.toLowerCase()}';
                            return DashboardCard(item: item, ruta: ruta);
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

  Widget _buildUserAvatar() {
    final userData = SessionService.currentUser ?? {};
    final fotoUrl = userData['foto_url'] as String?;
    final nombre = userData['nombre'] as String? ?? 'Usuario';

    return Row(
      children: [
        Text(
          nombre,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[300],
          backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
              ? NetworkImage(fotoUrl)
              : null,
          child: (fotoUrl == null || fotoUrl.isEmpty)
              ? const Icon(Icons.person, size: 24, color: Colors.white)
              : null,
        ),
      ],
    );
  }
}
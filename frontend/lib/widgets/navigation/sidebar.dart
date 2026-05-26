import 'package:flutter/material.dart';
import 'package:frontend/services/session_service.dart';
import 'sidebar_element.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;
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
            children: [
              const SizedBox(height: 20),
              // Logo
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/dashboard'),
                  child: Image.asset('assets/logo_taller.png', width: 130, height: 130),
                ),
              ),
              const SizedBox(height: 10),

              // Items del menú
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: _buildMenuItems(context)),
                ),
              ),

              // Perfil al final
              _buildPerfilItem(context),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final items = _getVisibleItems();

    return items.map((item) {
      final isSelected = ModalRoute.of(context)?.settings.name == item.ruta;
      return Column(
        children: [
          SidebarElement(
            nombre: item.nombre,
            icono: item.icono,
            seleccionado: isSelected,
            ruta: item.ruta,
          ),
          const SizedBox(height: 5),
        ],
      );
    }).toList();
  }

  Widget _buildPerfilItem(BuildContext context) {
    final userData = SessionService.currentUser ?? {};
    final fotoUrl = userData['foto_url'] as String?;
    final nombre = userData['nombre'] as String? ?? 'Mi perfil';
    final isSelected = ModalRoute.of(context)?.settings.name == '/perfil';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/perfil'),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color.fromRGBO(251, 238, 236, 1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color.fromARGB(255, 251, 219, 212),
                    width: 1,
                  ),
                )
              : null,
          width: 190,
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                    ? NetworkImage(fotoUrl)
                    : null,
                child: (fotoUrl == null || fotoUrl.isEmpty)
                    ? const Icon(Icons.person, size: 18, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nombre,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? const Color.fromARGB(255, 242, 51, 13)
                        : Colors.black,
                    fontFamily: 'Itim',
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LÓGICA DE PERMISOS ====================
  List<_ItemData> _getVisibleItems() {
    final allItems = [
      _ItemData('Vehiculos taller', 'coche', '/vehiculos'),
      _ItemData('Caja', 'caja', '/caja'),
      _ItemData('Clientes', 'cliente', '/clientes'),
      _ItemData('Ofertas', 'ofertas', '/ofertas'),
      _ItemData('Facturacion', 'facturacion', '/facturacion'),
      _ItemData('Inventario', 'inventario', '/inventario'),
      _ItemData('Proveedores', 'proveedores', '/proveedores'),
      _ItemData('Empleados', 'empleados', '/empleados'),
      _ItemData('Reportes', 'reportes', '/reportes'),
    ];

    if (SessionService.esAdmin || SessionService.esSecretaria) {
      return allItems;
    }

    // Solo mecánicos/empleados
    return allItems.where((i) => i.ruta == '/vehiculos').toList();
  }
}

// ==================== Drawer para móvil ====================
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
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/dashboard'),
                child: Image.asset('assets/logo_taller.png', width: 130, height: 130),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: _buildDrawerItems(context)),
              ),
            ),
            _buildPerfilDrawerItem(context),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    final items = Sidebar()._getVisibleItems(); // Reutilizamos la lógica

    return items.map((item) {
      return SidebarElement(
        nombre: item.nombre,
        icono: item.icono,
        seleccionado: ModalRoute.of(context)?.settings.name == item.ruta,
        ruta: item.ruta,
      );
    }).toList();
  }

  Widget _buildPerfilDrawerItem(BuildContext context) {
    // Mismo código que en _buildPerfilItem (podemos extraer a un widget común después)
    final userData = SessionService.currentUser ?? {};
    final fotoUrl = userData['foto_url'] as String?;
    final nombre = userData['nombre'] as String? ?? 'Mi perfil';
    final isSelected = ModalRoute.of(context)?.settings.name == '/perfil';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/perfil'),
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: const Color.fromRGBO(251, 238, 236, 1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color.fromARGB(255, 251, 219, 212)),
              )
            : null,
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                  ? NetworkImage(fotoUrl)
                  : null,
              child: (fotoUrl == null || fotoUrl.isEmpty)
                  ? const Icon(Icons.person, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nombre,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? const Color.fromARGB(255, 242, 51, 13) : Colors.black,
                  fontFamily: 'Itim',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemData {
  final String nombre, icono, ruta;
  const _ItemData(this.nombre, this.icono, this.ruta);
}
import 'package:flutter/material.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  static const double _mobileBreakpoint = 900;
  static const double _alturaItem = 48;
  static const double _alturaBarra = 60;

  final List<Map<String, dynamic>> _navLinks = [
    {'label': 'Vehiculos', 'icon': Icons.directions_car},
    {'label': 'Caja', 'icon': Icons.point_of_sale},
    {'label': 'Clientes', 'icon': Icons.people},
    {'label': 'Ofertas', 'icon': Icons.local_offer},
    {'label': 'Facturación', 'icon': Icons.receipt_long},
    {'label': 'Inventario', 'icon': Icons.inventory_2},
    {'label': 'Bodega', 'icon': Icons.warehouse},
    {'label': 'Proveedores', 'icon': Icons.local_shipping},
    {'label': 'Empleados', 'icon': Icons.badge},
  ];

  bool _menuAbierto = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < _mobileBreakpoint;
        return isMobile
            ? _buildMobileNavbar(context)
            : _buildDesktopNavbar(context);
      },
    );
  }

  Widget _buildDesktopNavbar(BuildContext context) {
    return Container(
      height: _alturaBarra,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {},
            child: Image.asset('assets/logo_taller.png', height: 46),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _navLinks.map((link) {
                return _NavLinkButton(
                  label: link['label'] as String,
                  onPressed: () {},
                );
              }).toList(),
            ),
          ),
          _ProfileButton(onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildMobileNavbar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: _alturaBarra,
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: _menuAbierto
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _menuAbierto = !_menuAbierto;
                        });
                      },
                      child: Icon(
                        _menuAbierto ? Icons.close : Icons.menu,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Image.asset('assets/logo_taller.png', height: 46),
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ProfileButton(onTap: () {}),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_menuAbierto)
          Container(
            color: Colors.white,
            child: Column(
              children: _navLinks.map((link) {
                return _NavMenuItem(
                  label: link['label'] as String,
                  icon: link['icon'] as IconData,
                  onTap: () => setState(() => _menuAbierto = false),
                  height: _alturaItem,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _NavMenuItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;

  const _NavMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.height,
  });

  @override
  State<_NavMenuItem> createState() => _NavMenuItemState();
}

class _NavMenuItemState extends State<_NavMenuItem> {
  bool _hovered = false;
  static const Color _colorHover = Color(0xFFDC2626);
  static const Color _colorHoverBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: _hovered ? _colorHoverBg : Colors.transparent,
            border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                widget.icon,
                size: 18,
                color: _hovered ? _colorHover : Colors.black54,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  color: _hovered ? _colorHover : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLinkButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _NavLinkButton({required this.label, required this.onPressed});

  @override
  State<_NavLinkButton> createState() => _NavLinkButtonState();
}

class _NavLinkButtonState extends State<_NavLinkButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          overlayColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            color: _hovered ? const Color(0xFFDC2626) : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ProfileButton({required this.onTap});

  @override
  State<_ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<_ProfileButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFFEE2E2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Mi perfil',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _hovered ? const Color(0xFFDC2626) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

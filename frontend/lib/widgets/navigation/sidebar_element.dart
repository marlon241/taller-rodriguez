import 'package:flutter/material.dart';

class SidebarElement extends StatefulWidget {
  final String nombre;
  final String icono;
  final bool seleccionado;
  final String ruta;

  const SidebarElement({
    super.key,
    required this.nombre,
    required this.icono,
    required this.seleccionado,
    required this.ruta,
  });

  @override
  State<SidebarElement> createState() => _SidebarElementState();
}

class _SidebarElementState extends State<SidebarElement> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
    child: GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, widget.ruta);
      },
    child: Container(
      decoration: widget.seleccionado ? BoxDecoration(
        color: const Color.fromRGBO(251, 238, 236, 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 251, 219, 212),
          width: 1,
        ),
      ) : null,
      width: 190,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Image(
            image: widget.seleccionado || isHovered ? AssetImage('../../../assets/sidebar_true/${widget.icono}.png') : AssetImage('../../../assets/sidebar_false/${widget.icono}.png'),
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 10),
          Text(
            widget.nombre,
            style: TextStyle(
              color: widget.seleccionado || isHovered ? Color.fromARGB(255, 242, 51, 13) : Color.fromARGB(255, 0, 0, 0),
              fontFamily: 'Itim',
              fontSize: 18,
            ),
          ),
        ],
      ),
    )
    )
    );
  }
}
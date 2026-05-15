import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      // Drawer solo en móvil, se desliza automático de izquierda a derecha
      drawer: isWide ? null : const SidebarDrawerContent(),

      appBar: isWide
          ? null
          : AppBar(
              // El ícono hamburguesa aparece automático al haber drawer
              title: const Text('Clientes'),
            ),

      body: Row(
        children: [
          // Sidebar fijo en desktop
          const Sidebar(),

          // Tu contenido de clientes
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Página de Clientes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Aquí iría tu lista o tabla de clientes
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
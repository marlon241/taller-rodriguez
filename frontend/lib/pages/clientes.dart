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
                  Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
                ),),
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
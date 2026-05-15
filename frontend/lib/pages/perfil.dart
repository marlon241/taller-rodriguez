import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final TextEditingController _nombreController = TextEditingController(text: 'Alejandro Rodríguez');
  final TextEditingController _duiController = TextEditingController(text: '07569561-8');
  final TextEditingController _fechaController = TextEditingController(text: '01/03/2023');
  final TextEditingController _telefonoController = TextEditingController(text: '7890-1234');
  final TextEditingController _sueldoController = TextEditingController(text: '\$800.00');
  final TextEditingController _porcentajeController = TextEditingController(text: '10%');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _duiController.dispose();
    _fechaController.dispose();
    _telefonoController.dispose();
    _sueldoController.dispose();
    _porcentajeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = true, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Itim')),
        const SizedBox(height: 6),
        TextField(
          readOnly: readOnly,
          obscureText: obscure,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      drawer: isWide ? null : const SidebarDrawerContent(),
      appBar: isWide ? null : AppBar(title: const Text('Perfil')),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Perfil',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Container del formulario
                  Container(
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila 1: Nombre y DUI
                        Row(
                          children: [
                            Expanded(child: _buildField('Nombre', _nombreController)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildField('DUI', _duiController)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Fila 2: Fecha y Teléfono
                        Row(
                          children: [
                            Expanded(child: _buildField('Fecha de contratación', _fechaController)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildField('Número de teléfono:', _telefonoController)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Fila 3: Sueldo y Porcentaje
                        Row(
                          children: [
                            Expanded(child: _buildField('Sueldo base', _sueldoController)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildField('Porcentaje de ganancia', _porcentajeController)),
                          ],
                        ),
                        const SizedBox(height: 36),

                        // Título cambiar contraseña
                        const Text(
                          'Cambiar contraseña',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                        ),
                        const SizedBox(height: 20),

                        // Fila 4: Contraseña, Confirmar y Botón
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: _buildField('Contraseña antigua', _passwordController, readOnly: false, obscure: true)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildField('Nueva contraseña', _confirmPasswordController, readOnly: false, obscure: true)),
                            const SizedBox(width: 20),
                            Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Cambiar contraseña',
                                  style: TextStyle(color: Colors.white, fontFamily: 'Itim'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
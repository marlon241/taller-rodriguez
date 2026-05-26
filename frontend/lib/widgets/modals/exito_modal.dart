import 'package:flutter/material.dart';

class ExitoModal extends StatelessWidget {
  const ExitoModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo actualizado
            Image.asset(
              'assets/logo_taller.png',
              height: 90,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),

            const Text(
              "Éxito al aplicar formulario",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Itim',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            const Text(
              "Se ha enviado las credenciales para el sistema a su empleado por correo electrónico.\n\nFavor revisar bandeja de entrada del correo \"Correo\".",
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Botón Aceptar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC0392B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Aceptar",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Itim',
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
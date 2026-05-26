import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ValidadorTelefono extends FilteringTextInputFormatter {
  ValidadorTelefono()
      : super(
          RegExp(r'^[0-9+\s\-\(\)]+$'),
          allow: true,
        );
}

class ValidadorCorreo extends FilteringTextInputFormatter {
  ValidadorCorreo()
      : super(
          RegExp(r'^[a-zA-Z0-9._%@\-]+$'),
          allow: true,
        );
}

class ValidadorNIT extends FilteringTextInputFormatter {
  ValidadorNIT()
      : super(
          RegExp(r'^[0-9\-]+$'),
          allow: true,
        );
}

class ValidadorPrecio extends FilteringTextInputFormatter {
  ValidadorPrecio()
      : super(
          RegExp(r'^[0-9.\-]+$'),
          allow: true,
        );
}

String? validarTelefono(String? valor) {
  if (valor == null || valor.isEmpty) return null;
  final soloNumeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
  if (soloNumeros.length < 8 || soloNumeros.length > 15) {
    return 'Teléfono inválido';
  }
  return null;
}

String? validarCorreo(String? valor) {
  if (valor == null || valor.isEmpty) return null;
  final regex = RegExp(r'^[a-zA-Z0-9._%@\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(valor)) {
    return 'Correo electrónico inválido';
  }
  return null;
}

String? validarNIT(String? valor) {
  if (valor == null || valor.isEmpty) return null;
  final soloNumeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
  if (soloNumeros.length != 14) {
    return 'NIT debe tener 14 dígitos (formato: 0000-000000-000-0)';
  }
  return null;
}

String formatearTelefono(String valor) {
  final soloNumeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
  if (soloNumeros.length == 8) {
    return '${soloNumeros.substring(0, 4)}-${soloNumeros.substring(4)}';
  }
  if (soloNumeros.length == 10 && !soloNumeros.startsWith('1')) {
    return '(${soloNumeros.substring(0, 3)}) ${soloNumeros.substring(3, 6)}-${soloNumeros.substring(6)}';
  }
  if (soloNumeros.length == 11 && soloNumeros.startsWith('1')) {
    return '+1 (${soloNumeros.substring(1, 4)}) ${soloNumeros.substring(4, 7)}-${soloNumeros.substring(7)}';
  }
  return valor;
}

String formatearNIT(String valor) {
  final soloNumeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
  if (soloNumeros.length >= 13) {
    return '${soloNumeros.substring(0, 4)}-${soloNumeros.substring(4, 10)}-${soloNumeros.substring(10, 13)}-${soloNumeros.substring(13)}';
  }
  return valor;
}

void formatearYLimitarTelefono(TextEditingController controller) {
  final texto = controller.text;
  final soloNumeros = texto.replaceAll(RegExp(r'[^0-9]'), '');
  if (soloNumeros.length > 11) {
    controller.text = soloNumeros.substring(0, 11);
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }
}

void formatearYLimitarNIT(TextEditingController controller) {
  final texto = controller.text;
  final soloNumeros = texto.replaceAll(RegExp(r'[^0-9]'), '');
  if (soloNumeros.length > 14) {
    controller.text = soloNumeros.substring(0, 14);
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }
}

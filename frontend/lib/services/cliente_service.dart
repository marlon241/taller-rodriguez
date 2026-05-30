import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/models/cliente.dart';

class ClienteService {
  static final _db = Supabase.instance.client.from('clientes');

  static Future<List<Cliente>> getAll() async {
    final data = await _db.select().order('nombre', ascending: true);
    final List<Cliente> clientes = [];
    for (final item in data as List) {
      try {
        clientes.add(Cliente.fromJson(item));
      } catch (e) {
        debugPrint('Error al parsear cliente: $e - datos: $item');
      }
    }
    return clientes;
  }

  static Future<void> create(Cliente cliente) async {
    await _db.insert(cliente.toJson());
  }

  static Future<void> update(Cliente cliente) async {
    await _db.update(cliente.toJson()).eq('id', cliente.id!);
  }

  static Future<void> delete(int id) async {
    await _db.delete().eq('id', id);
  }
}
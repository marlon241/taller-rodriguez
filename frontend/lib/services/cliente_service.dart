import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/models/cliente.dart';

class ClienteService {
  static final _db = Supabase.instance.client.from('clientes');

  static Future<List<Cliente>> getAll() async {
    final data = await _db.select().order('nombre', ascending: true);
    return (data as List).map((e) => Cliente.fromJson(e)).toList();
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
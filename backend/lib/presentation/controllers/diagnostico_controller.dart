import 'dart:convert';
import '../../data/datasources/supabase_datasource.dart';
import '../../injection.dart';

class DiagnosticoController {
  final SupabaseDataSource _dataSource;

  DiagnosticoController() : _dataSource = getIt<SupabaseDataSource>();

  Future<String> diagnosticarTablaClientes() async {
    try {
      final resultado = await _dataSource.select('clientes', limit: 5);

      if (resultado.isEmpty) {
        return json.encode({
          'success': true,
          'data': {
            'mensaje': 'La tabla existe pero no hay datos',
            'total_registros': 0,
            'columnas': [],
            'muestra': [],
          },
        });
      }

      final columnas = resultado.first.keys.toList();
      final muestra = resultado.take(3).toList();

      return json.encode({
        'success': true,
        'data': {
          'mensaje': 'Tabla encontrada',
          'total_registros': resultado.length,
          'columnas': columnas,
          'muestra': muestra,
        },
      });
    } catch (e) {
      return json.encode({
        'success': false,
        'message': 'Error al diagnosticar: $e',
        'posibles_causas': [
          'La tabla "clientes" no existe',
          'El nombre de la tabla cambio',
          'Permisos insuficientes',
        ],
      });
    }
  }

  Future<String> diagnosticarEstructura() async {
    try {
      final tablas = ['clientes', 'Clientes', 'CLIENTES', 'cliente'];
      final resultados = <Map<String, dynamic>>[];

      for (final tabla in tablas) {
        try {
          final datos = await _dataSource.select(tabla, limit: 2);
          resultados.add({
            'nombre_tabla': tabla,
            'encontrada': true,
            'columnas': datos.isNotEmpty ? datos.first.keys.toList() : [],
            'cantidad': datos.length,
          });
        } catch (_) {
          resultados.add({
            'nombre_tabla': tabla,
            'encontrada': false,
          });
        }
      }

      return json.encode({
        'success': true,
        'data': resultados,
      });
    } catch (e) {
      return json.encode({
        'success': false,
        'message': 'Error: $e',
      });
    }
  }

  Future<String> diagnosticarTablaProveedores() async {
    try {
      final resultado = await _dataSource.select('proveedores', limit: 5);

      if (resultado.isEmpty) {
        return json.encode({
          'success': true,
          'data': {
            'mensaje': 'La tabla existe pero no hay datos',
            'columnas': [],
            'muestra': [],
          },
        });
      }

      final columnas = resultado.first.keys.toList();
      final muestra = resultado.take(3).toList();

      return json.encode({
        'success': true,
        'data': {
          'mensaje': 'Tabla encontrada',
          'columnas': columnas,
          'muestra': muestra,
        },
      });
    } catch (e) {
      return json.encode({
        'success': false,
        'message': 'Error: $e',
      });
    }
  }
}
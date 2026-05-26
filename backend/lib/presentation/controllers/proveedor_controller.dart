import 'dart:convert';
import 'dart:async';
import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/proveedor_repository.dart';

class ProveedorController {
  final ProveedorRepository _repository;

  final List<StreamSubscription> _suscripciones = [];

  ProveedorController({required ProveedorRepository repository})
      : _repository = repository;

  Future<String> obtenerProveedores({String? busqueda}) async {
    try {
      Stream<List<Proveedor>> stream;

      if (busqueda != null && busqueda.isNotEmpty) {
        stream = _repository.buscarProveedores(busqueda);
      } else {
        stream = _repository.obtenerProveedores();
      }

      final proveedores = await stream.first;

      return _respuestaExitosa(
        proveedores.map((p) => {
          'id': p.id,
          'nombre': p.nombre,
          'telefono': p.telefono,
          'correo': p.correo,
          'locacion': p.locacion,
          'nit': p.nit,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener proveedores: $e');
    }
  }

  Future<String> obtenerProveedorPorId(int id) async {
    try {
      final proveedor = await _repository.obtenerProveedorPorId(id);

      if (proveedor == null) {
        return _respuestaError('Proveedor no encontrado');
      }

      return _respuestaExitosa({
        'id': proveedor.id,
        'nombre': proveedor.nombre,
        'telefono': proveedor.telefono,
        'correo': proveedor.correo,
        'locacion': proveedor.locacion,
        'nit': proveedor.nit,
      });
    } catch (e) {
      return _respuestaError('Error al obtener proveedor: $e');
    }
  }

  Future<String> crearProveedor(Map<String, dynamic> data) async {
    try {
      final proveedor = Proveedor(
        nombre: data['nombre'] as String? ?? '',
        telefono: data['telefono'] as String? ?? '',
        correo: data['correo'] as String? ?? '',
        locacion: data['locacion'] as String? ?? 'Nacional',
        nit: data['nit'] as String?,
      );

      final proveedorCreado = await _repository.crearProveedor(proveedor);

      return _respuestaExitosa({
        'id': proveedorCreado.id,
        'mensaje': 'Proveedor creado exitosamente',
      });
    } catch (e) {
      return _respuestaError('Error al crear proveedor: $e');
    }
  }

  Future<String> actualizarProveedor(int id, Map<String, dynamic> data) async {
    try {
      final proveedorExistente = await _repository.obtenerProveedorPorId(id);

      if (proveedorExistente == null) {
        return _respuestaError('Proveedor no encontrado');
      }

      final proveedor = Proveedor(
        id: id,
        nombre: data['nombre'] as String? ?? proveedorExistente.nombre,
        telefono: data['telefono'] as String? ?? proveedorExistente.telefono,
        correo: data['correo'] as String? ?? proveedorExistente.correo,
        locacion: data['locacion'] as String? ?? proveedorExistente.locacion,
        nit: data['nit'] as String? ?? proveedorExistente.nit,
      );

      await _repository.actualizarProveedor(proveedor);

      return _respuestaExitosa({'mensaje': 'Proveedor actualizado exitosamente'});
    } catch (e) {
      return _respuestaError('Error al actualizar proveedor: $e');
    }
  }

  Future<String> eliminarProveedor(int id) async {
    try {
      final tieneInventario = await _repository.tieneInventario(id);
      if (tieneInventario) {
        return _respuestaError('No se puede eliminar. Este proveedor tiene productos asociados en el inventario.');
      }
      
      final resultado = await _repository.eliminarProveedor(id);

      if (resultado) {
        return _respuestaExitosa({'mensaje': 'Proveedor eliminado exitosamente'});
      }

      return _respuestaError('No se pudo eliminar el proveedor');
    } catch (e) {
      return _respuestaError('Error al eliminar proveedor: $e');
    }
  }

  String _respuestaExitosa(dynamic data) {
    return json.encode({
      'success': true,
      'data': data,
    });
  }

  String _respuestaError(String mensaje) {
    return json.encode({
      'success': false,
      'message': mensaje,
    });
  }

  void dispose() {
    for (final suscripcion in _suscripciones) {
      suscripcion.cancel();
    }
    _suscripciones.clear();
  }
}
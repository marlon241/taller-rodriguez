import 'dart:convert';
import '../../domain/entities/oferta.dart';
import '../../domain/repositories/oferta_repository.dart';

class OfertaController {
  final OfertaRepository _repository;

  OfertaController({required OfertaRepository repository})
      : _repository = repository;

  Future<String> obtenerOfertas() async {
    try {
      final ofertas = await _repository.obtenerTodasLasOfertas().first;
      return _respuestaExitosa(
        ofertas.map((o) => {
          'id': o.id,
          'nombre_oferta': o.nombre_oferta,
          'descripcion': o.descripcion,
          'porcentaje_descuento': o.porcentaje_descuento,
          'fecha_inicio': o.fecha_inicio.toIso8601String(),
          'fecha_fin': o.fecha_fin.toIso8601String(),
          'estado_oferta': o.estado_oferta.valor,
          'id_producto_firebase': o.id_producto_firebase,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener ofertas: $e');
    }
  }

  Future<String> obtenerOfertaPorId(int id) async {
    try {
      final oferta = await _repository.obtenerOfertaPorId(id);
      if (oferta == null) {
        return _respuestaError('Oferta no encontrada');
      }
      return _respuestaExitosa({
        'id': oferta.id,
        'nombre_oferta': oferta.nombre_oferta,
        'descripcion': oferta.descripcion,
        'porcentaje_descuento': oferta.porcentaje_descuento,
        'fecha_inicio': oferta.fecha_inicio.toIso8601String(),
        'fecha_fin': oferta.fecha_fin.toIso8601String(),
        'estado_oferta': oferta.estado_oferta.valor,
        'id_producto_firebase': oferta.id_producto_firebase,
      });
    } catch (e) {
      return _respuestaError('Error al obtener oferta: $e');
    }
  }

  Future<String> crearOferta(Map<String, dynamic> data) async {
    try {
      final porcentaje = (data['porcentaje_descuento'] as num?)?.toDouble() ?? 0;
      if (porcentaje <= 0 || porcentaje > 100) {
        return _respuestaError('El descuento debe ser entre 1 y 100');
      }

      final idProd = data['id_producto_firebase'] as String?;
      if (idProd != null && idProd.isNotEmpty) {
        final chars = idProd.replaceAll(RegExp(r'[^0-9]'), '');
        if (chars != idProd) {
          return _respuestaError('El ID del producto debe contener solo numeros');
        }
      }

      final ahora = DateTime.now();
      final fechaInicio = data['fecha_inicio'] != null 
          ? DateTime.parse(data['fecha_inicio'].toString())
          : ahora;
      final fechaFin = data['fecha_fin'] != null 
          ? DateTime.parse(data['fecha_fin'].toString())
          : ahora.add(const Duration(days: 30));

      String estadoOferta = 'Activa';
      if (ahora.isAfter(fechaFin)) {
        estadoOferta = 'Expirada';
      } else if (fechaInicio.isAfter(ahora)) {
        estadoOferta = 'Activa';
      }

      final oferta = Oferta(
        nombre_oferta: data['nombre_oferta'] as String? ?? '',
        descripcion: data['descripcion'] as String? ?? '',
        porcentaje_descuento: (data['porcentaje_descuento'] as num?)?.toDouble() ?? 0,
        fecha_inicio: fechaInicio,
        fecha_fin: fechaFin,
        estado_oferta: EstadoOfertaExtension.fromString(estadoOferta),
        id_producto_firebase: data['id_producto_firebase'] as String?,
      );

      final ofertaCreada = await _repository.crearOferta(oferta);
      return _respuestaExitosa({
        'id': ofertaCreada.id,
        'mensaje': 'Oferta creada exitosamente',
      });
    } catch (e) {
      return _respuestaError('Error al crear oferta: $e');
    }
  }

  Future<String> actualizarOferta(int id, Map<String, dynamic> data) async {
    try {
      final ofertaExistente = await _repository.obtenerOfertaPorId(id);
      if (ofertaExistente == null) {
        return _respuestaError('Oferta no encontrada');
      }

      final porcentaje = (data['porcentaje_descuento'] as num?)?.toDouble() ?? ofertaExistente.porcentaje_descuento;
      if (porcentaje <= 0 || porcentaje > 100) {
        return _respuestaError('El descuento debe ser entre 1 y 100');
      }

      final idProd = data['id_producto_firebase'] as String? ?? ofertaExistente.id_producto_firebase;
      if (idProd != null && idProd.isNotEmpty) {
        final chars = idProd.replaceAll(RegExp(r'[^0-9]'), '');
        if (chars != idProd) {
          return _respuestaError('El ID del producto debe contener solo numeros');
        }
      }

      final ahora = DateTime.now();
      final fechaInicio = data['fecha_inicio'] != null 
          ? DateTime.parse(data['fecha_inicio'].toString())
          : ofertaExistente.fecha_inicio;
      final fechaFin = data['fecha_fin'] != null 
          ? DateTime.parse(data['fecha_fin'].toString())
          : ofertaExistente.fecha_fin;

      String estadoOferta = ofertaExistente.estado_oferta.valor;
      if (ahora.isAfter(fechaFin)) {
        estadoOferta = 'Expirada';
      } else if (ahora.isAfter(fechaInicio) && ahora.isBefore(fechaFin)) {
        estadoOferta = 'Activa';
      }

      final oferta = Oferta(
        id: id,
        nombre_oferta: data['nombre_oferta'] as String? ?? ofertaExistente.nombre_oferta,
        descripcion: data['descripcion'] as String? ?? ofertaExistente.descripcion,
        porcentaje_descuento: (data['porcentaje_descuento'] as num?)?.toDouble() ?? ofertaExistente.porcentaje_descuento,
        fecha_inicio: fechaInicio,
        fecha_fin: fechaFin,
        estado_oferta: EstadoOfertaExtension.fromString(estadoOferta),
        id_producto_firebase: data['id_producto_firebase'] as String? ?? ofertaExistente.id_producto_firebase,
      );

      await _repository.actualizarOferta(oferta);
      return _respuestaExitosa({'mensaje': 'Oferta actualizada exitosamente'});
    } catch (e) {
      return _respuestaError('Error al actualizar oferta: $e');
    }
  }

  Future<String> eliminarOferta(int id) async {
    try {
      final tieneFacturas = await _repository.tieneFacturasAsociadas(id);
      if (tieneFacturas) {
        return _respuestaError('Esta oferta tiene facturas asociadas. No se puede eliminar.');
      }
      final resultado = await _repository.eliminarOferta(id);
      if (resultado) {
        return _respuestaExitosa({'mensaje': 'Oferta eliminada exitosamente'});
      }
      return _respuestaError('No se pudo eliminar la oferta');
    } catch (e) {
      return _respuestaError('Error al eliminar oferta: $e');
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
}
import 'dart:convert';
import '../../domain/repositories/vehiculo_repository.dart';
import '../../domain/entities/vehiculo.dart';

class VehiculoController {
  final VehiculoRepository _vehiculoRepository;

  VehiculoController({required VehiculoRepository vehiculoRepository})
      : _vehiculoRepository = vehiculoRepository;

  Future<String> obtenerVehiculos({String? estado, bool entregados = false}) async {
    try {
      final stream = _vehiculoRepository.obtenerVehiculos();
      final vehiculos = await stream.first;

      final filtrados = vehiculos.where((v) {
        if (entregados) {
          return v.estado == 'Entregado';
        } else {
          return v.estado != 'Entregado';
        }
      }).toList();

      return _respuestaExitosa(
        filtrados.map((v) => {
          'id': v.id,
          'modelo': v.modelo,
          'marca': v.marca,
          'placa': v.placa,
          'anio': v.anio,
          'diagnostico': v.diagnostico,
          'estado': v.estado,
          'fecha_ingreso': v.fecha_ingreso?.toIso8601String(),
          'fecha_salida': v.fecha_salida?.toIso8601String(),
          'id_cliente': v.id_cliente,
          'id_empleado': v.id_empleado,
          'url_imagen_vehiculo': v.urlImagenVehiculo,
          'url_tarjeta_circulacion': v.urlTarjetaCirculacion,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener vehículos: $e');
    }
  }

  Future<String> obtenerVehiculoPorId(int id) async {
    try {
      final vehiculo = await _vehiculoRepository.obtenerVehiculoPorId(id);
      if (vehiculo == null) {
        return _respuestaError('Vehículo no encontrado');
      }
      return _respuestaExitosa({
        'id': vehiculo.id,
        'modelo': vehiculo.modelo,
        'marca': vehiculo.marca,
        'placa': vehiculo.placa,
        'anio': vehiculo.anio,
        'diagnostico': vehiculo.diagnostico,
        'estado': vehiculo.estado,
        'fecha_ingreso': vehiculo.fecha_ingreso?.toIso8601String(),
        'fecha_salida': vehiculo.fecha_salida?.toIso8601String(),
        'id_cliente': vehiculo.id_cliente,
        'id_empleado': vehiculo.id_empleado,
        'url_imagen_vehiculo': vehiculo.urlImagenVehiculo,
        'url_tarjeta_circulacion': vehiculo.urlTarjetaCirculacion,
      });
    } catch (e) {
      return _respuestaError('Error al obtener vehículo: $e');
    }
  }

  Future<String> crearVehiculo(Map<String, dynamic> body) async {
    try {
      if (body['modelo'] == null || body['marca'] == null ||
          body['placa'] == null || body['anio'] == null) {
        return _respuestaError('Modelo, marca, placa y año son requeridos');
      }

      final vehiculo = Vehiculo(
        modelo: body['modelo'] as String,
        marca: body['marca'] as String,
        placa: body['placa'] as String,
        anio: (body['anio'] as num).toInt(),
        diagnostico: body['diagnostico'] as String? ?? '',
        estado: body['estado'] as String? ?? 'Pendiente',
        fecha_ingreso: body['fecha_ingreso'] != null
            ? DateTime.tryParse(body['fecha_ingreso'])
            : DateTime.now(),
        fecha_salida: body['fecha_salida'] != null
            ? DateTime.tryParse(body['fecha_salida'])
            : null,
        id_cliente: body['id_cliente'] as int?,
        id_empleado: body['id_empleado'] as int?,
        urlImagenVehiculo: body['url_imagen_vehiculo'] as String?,
        urlTarjetaCirculacion: body['url_tarjeta_circulacion'] as String?,
      );

      final creado = await _vehiculoRepository.crearVehiculo(vehiculo);
      return _respuestaExitosa({
        'id': creado.id,
        'mensaje': 'Vehículo creado exitosamente',
      });
    } catch (e) {
      return _respuestaError('Error al crear vehículo: $e');
    }
  }

  Future<String> actualizarVehiculo(int id, Map<String, dynamic> body) async {
    try {
      final vehiculoExistente = await _vehiculoRepository.obtenerVehiculoPorId(id);
      if (vehiculoExistente == null) {
        return _respuestaError('Vehículo no encontrado');
      }

      final vehiculoActualizado = Vehiculo(
        id: id,
        modelo: body['modelo'] as String? ?? vehiculoExistente.modelo,
        marca: body['marca'] as String? ?? vehiculoExistente.marca,
        placa: body['placa'] as String? ?? vehiculoExistente.placa,
        anio: (body['anio'] as num?)?.toInt() ?? vehiculoExistente.anio,
        diagnostico: body['diagnostico'] as String? ?? vehiculoExistente.diagnostico,
        estado: body['estado'] as String? ?? vehiculoExistente.estado,
        fecha_ingreso: body['fecha_ingreso'] != null
            ? DateTime.tryParse(body['fecha_ingreso'])
            : vehiculoExistente.fecha_ingreso,
        fecha_salida: body['fecha_salida'] != null
            ? DateTime.tryParse(body['fecha_salida'])
            : vehiculoExistente.fecha_salida,
        id_cliente: body['id_cliente'] as int? ?? vehiculoExistente.id_cliente,
        id_empleado: body['id_empleado'] as int? ?? vehiculoExistente.id_empleado,
        urlImagenVehiculo: body['url_imagen_vehiculo'] as String? ?? vehiculoExistente.urlImagenVehiculo,
        urlTarjetaCirculacion: body['url_tarjeta_circulacion'] as String? ?? vehiculoExistente.urlTarjetaCirculacion,
      );

      await _vehiculoRepository.actualizarVehiculo(vehiculoActualizado);
      return _respuestaExitosa({'mensaje': 'Vehículo actualizado exitosamente'});
    } catch (e) {
      return _respuestaError('Error al actualizar vehículo: $e');
    }
  }

  Future<String> eliminarVehiculo(int id) async {
    try {
      final resultado = await _vehiculoRepository.eliminarVehiculo(id);
      if (resultado) {
        return _respuestaExitosa({'mensaje': 'Vehículo eliminado exitosamente'});
      }
      return _respuestaError('No se pudo eliminar el vehículo');
    } catch (e) {
      return _respuestaError('Error al eliminar vehículo: $e');
    }
  }

  Future<String> buscarVehiculos(String query) async {
    try {
      final stream = _vehiculoRepository.buscarVehiculos(query);
      final vehiculos = await stream.first;
      return _respuestaExitosa(
        vehiculos.map((v) => {
          'id': v.id,
          'modelo': v.modelo,
          'marca': v.marca,
          'placa': v.placa,
          'estado': v.estado,
          'fecha_ingreso': v.fecha_ingreso?.toIso8601String(),
          'id_cliente': v.id_cliente,
          'url_imagen_vehiculo': v.urlImagenVehiculo,
          'url_tarjeta_circulacion': v.urlTarjetaCirculacion,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al buscar vehículos: $e');
    }
  }

  String _respuestaExitosa(dynamic data) {
    return json.encode({'success': true, 'data': data});
  }

  String _respuestaError(String mensaje) {
    return json.encode({'success': false, 'message': mensaje});
  }
}
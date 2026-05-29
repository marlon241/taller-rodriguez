import 'dart:async';
import '../../domain/entities/factura.dart';
import '../../domain/entities/detalle_factura.dart';
import '../../domain/repositories/factura_repository.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../datasources/supabase_datasource.dart';

class FacturaRepositoryImpl implements FacturaRepository {
  final SupabaseDataSource _dataSource;
  final InventarioRepository _inventarioRepository;

  final _facturasController = StreamController<List<Factura>>.broadcast();

  FacturaRepositoryImpl(this._dataSource, this._inventarioRepository);
  
  @override
  Stream<List<Factura>> obtenerFacturas() {
    _cargarFacturas();
    return _facturasController.stream;
  }
  
  Future<void> _cargarFacturas() async {
    try {
      final datos = await _dataSource.select(
        'facturacion',
        orderBy: 'fecha.desc',
      );
      
      final facturas = <Factura>[];
      for (final json in datos) {
        final factura = Factura.fromJson(json);
        final detalles = await _obtenerDetallesPorFactura(factura.id!);
        facturas.add(Factura(
          id: factura.id,
          fecha: factura.fecha,
          tipo_factura: factura.tipo_factura,
          subtotal: factura.subtotal,
          iva: factura.iva,
          descuentoPorcentaje: factura.descuentoPorcentaje,
          descuento: factura.descuento,
          total: factura.total,
          id_cliente: factura.id_cliente,
          nombre_cliente: factura.nombre_cliente,
          telefono_cliente: factura.telefono_cliente,
          dui_cliente: factura.dui_cliente,
          correo_cliente: factura.correo_cliente,
          id_vehiculo: factura.id_vehiculo,
          modelo_vehiculo: factura.modelo_vehiculo,
          marca_vehiculo: factura.marca_vehiculo,
          placa_vehiculo: factura.placa_vehiculo,
          anio_vehiculo: factura.anio_vehiculo,
          id_oferta: factura.id_oferta,
          nombre_oferta: factura.nombre_oferta,
          porcentaje_oferta: factura.porcentaje_oferta,
          id_caja: factura.id_caja,
          detalles: detalles,
        ));
      }
      
      _facturasController.add(facturas);
    } catch (e) {
      _facturasController.addError(e);
    }
  }
  
  Future<List<DetalleFactura>> _obtenerDetallesPorFactura(int idFactura) async {
    try {
      final datos = await _dataSource.select(
        'detalles_factura',
        filtros: 'id_factura=eq.$idFactura',
      );
      
      return datos.map((json) => DetalleFactura.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<Factura?> obtenerFacturaPorId(int id) async {
    try {
      final datos = await _dataSource.select(
        'facturacion',
        filtros: 'id=eq.$id',
      );
      
      if (datos.isEmpty) return null;
      
      final factura = Factura.fromJson(datos.first);
      final detalles = await _obtenerDetallesPorFactura(id);
      
      return Factura(
        id: factura.id,
        fecha: factura.fecha,
        tipo_factura: factura.tipo_factura,
        subtotal: factura.subtotal,
        iva: factura.iva,
        descuentoPorcentaje: factura.descuentoPorcentaje,
        descuento: factura.descuento,
        total: factura.total,
        id_cliente: factura.id_cliente,
        nombre_cliente: factura.nombre_cliente,
        telefono_cliente: factura.telefono_cliente,
        dui_cliente: factura.dui_cliente,
        correo_cliente: factura.correo_cliente,
        id_vehiculo: factura.id_vehiculo,
        modelo_vehiculo: factura.modelo_vehiculo,
        marca_vehiculo: factura.marca_vehiculo,
        placa_vehiculo: factura.placa_vehiculo,
        anio_vehiculo: factura.anio_vehiculo,
        id_oferta: factura.id_oferta,
        nombre_oferta: factura.nombre_oferta,
        porcentaje_oferta: factura.porcentaje_oferta,
        id_caja: factura.id_caja,
        detalles: detalles,
      );
    } catch (e) {
      return null;
    }
  }
  
  @override
  Stream<List<Factura>> obtenerFacturasPorCliente(int idCliente) {
    _cargarFacturasPorCliente(idCliente);
    return _facturasController.stream;
  }
  
  Future<void> _cargarFacturasPorCliente(int idCliente) async {
    try {
      final datos = await _dataSource.select(
        'facturacion',
        filtros: 'id_cliente=eq.$idCliente',
        orderBy: 'fecha.desc',
      );
      
      final facturas = datos.map((json) => Factura.fromJson(json)).toList();
      _facturasController.add(facturas);
    } catch (e) {
      _facturasController.addError(e);
    }
  }
  
  @override
  Stream<List<Factura>> obtenerFacturasPorVehiculo(int idVehiculo) {
    _cargarFacturasPorVehiculo(idVehiculo);
    return _facturasController.stream;
  }
  
  Future<void> _cargarFacturasPorVehiculo(int idVehiculo) async {
    try {
      final datos = await _dataSource.select(
        'facturacion',
        filtros: 'id_vehiculo=eq.$idVehiculo',
        orderBy: 'fecha.desc',
      );
      
      final facturas = datos.map((json) => Factura.fromJson(json)).toList();
      _facturasController.add(facturas);
    } catch (e) {
      _facturasController.addError(e);
    }
  }
  
  @override
  Future<Factura> crearFactura(Factura factura) async {
    final parametros = {
      'p_fecha': factura.fecha.toIso8601String(),
      'p_tipo_factura': factura.tipo_factura.valor,
      'p_subtotal': factura.subtotal,
      'p_iva': factura.iva,
      'p_descuento_porcentaje': factura.descuentoPorcentaje,
      'p_descuento': factura.descuento,
      'p_total': factura.total,
      'p_id_cliente': factura.id_cliente,
      'p_id_oferta': factura.id_oferta,
      'p_id_caja': factura.id_caja,
      'p_detalles': factura.detalles.map((d) => {
        'id_producto': d.id_producto,
        'nombre_producto': d.nombre_producto,
        'tipo_producto': d.tipo_producto,
        'clasificacion': d.clasificacion,
        'descripcion': d.descripcion,
        'sku': d.sku,
        'cantidad': d.cantidad,
        'precio_unitario': d.precio_unitario,
        'subtotal': d.subtotal,
      }).toList(),
    };

    final idFactura = await _dataSource.rpc('crear_factura_completa', parametros);

    for (final detalle in factura.detalles) {
      if (detalle.esProducto) {
        await _inventarioRepository.restarStockProducto(detalle.id_producto, detalle.cantidad);
      }
    }

    _cargarFacturas();

    return Factura(
        id: idFactura,
        fecha: factura.fecha,
        tipo_factura: factura.tipo_factura,
        subtotal: factura.subtotal,
        iva: factura.iva,
        descuentoPorcentaje: factura.descuentoPorcentaje,
        descuento: factura.descuento,
        total: factura.total,
        id_cliente: factura.id_cliente,
        nombre_cliente: factura.nombre_cliente,
        telefono_cliente: factura.telefono_cliente,
        dui_cliente: factura.dui_cliente,
        correo_cliente: factura.correo_cliente,
        id_vehiculo: factura.id_vehiculo,
        modelo_vehiculo: factura.modelo_vehiculo,
        marca_vehiculo: factura.marca_vehiculo,
        placa_vehiculo: factura.placa_vehiculo,
        anio_vehiculo: factura.anio_vehiculo,
        id_oferta: factura.id_oferta,
        nombre_oferta: factura.nombre_oferta,
        porcentaje_oferta: factura.porcentaje_oferta,
        id_caja: factura.id_caja,
        detalles: factura.detalles,
      );
  }
  
  @override
  Future<bool> eliminarFactura(int id) async {
    try {
      await _dataSource.delete('detalles_factura', 'id_factura=eq.$id');
      
      final resultado = await _dataSource.delete('facturacion', 'id=eq.$id');
      
      _cargarFacturas();
      
      return resultado;
    } catch (e) {
      return false;
    }
  }
  
  void dispose() {
    _facturasController.close();
  }
}
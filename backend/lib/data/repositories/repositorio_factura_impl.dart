import 'dart:async';
import '../../domain/entities/factura.dart';
import '../../domain/entities/detalle_factura.dart';
import '../../domain/repositories/factura_repository.dart';
import '../datasources/supabase_datasource.dart';

class FacturaRepositoryImpl implements FacturaRepository {
  final SupabaseDataSource _dataSource;
  
  final _facturasController = StreamController<List<Factura>>.broadcast();
  
  FacturaRepositoryImpl(this._dataSource);
  
  @override
  Stream<List<Factura>> obtenerFacturas() {
    _cargarFacturas();
    return _facturasController.stream;
  }
  
  Future<void> _cargarFacturas() async {
    try {
      final datos = await _dataSource.select(
        'facturacion',
        orderBy: 'order=fecha.desc',
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
          descuento: factura.descuento,
          total: factura.total,
          id_cliente: factura.id_cliente,
          id_vehiculo: factura.id_vehiculo,
          id_oferta: factura.id_oferta,
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
        descuento: factura.descuento,
        total: factura.total,
        id_cliente: factura.id_cliente,
        id_vehiculo: factura.id_vehiculo,
        id_oferta: factura.id_oferta,
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
        orderBy: 'order=fecha.desc',
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
        orderBy: 'order=fecha.desc',
      );
      
      final facturas = datos.map((json) => Factura.fromJson(json)).toList();
      _facturasController.add(facturas);
    } catch (e) {
      _facturasController.addError(e);
    }
  }
  
  @override
  Future<Factura> crearFactura(Factura factura) async {
    final Map<String, dynamic> facturaData = {
      'fecha': factura.fecha.toIso8601String(),
      'tipo_factura': factura.tipo_factura.valor,
      'subtotal': factura.subtotal,
      'iva': factura.iva,
      'descuento': factura.descuento,
      'total': factura.total,
      'id_cliente': factura.id_cliente,
    };
    
    if (factura.id_vehiculo != null) {
      facturaData['id_vehiculo'] = factura.id_vehiculo;
    }
    if (factura.id_oferta != null) {
      facturaData['id_oferta'] = factura.id_oferta;
    }
    if (factura.id_caja != null) {
      facturaData['id_caja'] = factura.id_caja;
    }
    
    final facturaInsertada = await _dataSource.insert('facturacion', facturaData);
    int? idFactura = facturaInsertada['id'] as int?;
    
    if (idFactura == null) {
      final facturasRecientes = await _dataSource.select(
        'facturacion',
        filtros: 'id_cliente=eq.${factura.id_cliente}',
        orderBy: 'order=fecha.desc',
        limit: 1,
      );
      if (facturasRecientes.isNotEmpty) {
        idFactura = facturasRecientes.first['id'] as int;
      }
    }
    
    if (idFactura == null) {
      throw Exception('No se pudo obtener el ID de la factura insertada');
    }
    
    final detallesData = factura.detalles.map((detalle) => {
      'id_factura': idFactura,
      'id_producto_firebase': detalle.id_producto_firebase,
      'nombre_producto': detalle.nombre_producto,
      'tipo_producto': detalle.tipo_producto.valor,
      'cantidad': detalle.cantidad,
      'precio_unitario': detalle.precio_unitario,
      'subtotal': detalle.subtotal,
    }).toList();
    
    await _dataSource.insertMultiple('detalles_factura', detallesData);
    
    _cargarFacturas();
    
    return Factura(
      id: idFactura,
      fecha: factura.fecha,
      tipo_factura: factura.tipo_factura,
      subtotal: factura.subtotal,
      iva: factura.iva,
      descuento: factura.descuento,
      total: factura.total,
      id_cliente: factura.id_cliente,
      id_vehiculo: factura.id_vehiculo,
      id_oferta: factura.id_oferta,
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
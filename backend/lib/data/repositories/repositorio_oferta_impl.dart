import 'dart:async';
import '../../domain/entities/oferta.dart';
import '../../domain/repositories/oferta_repository.dart';
import '../datasources/supabase_datasource.dart';

class OfertaRepositoryImpl implements OfertaRepository {
  final SupabaseDataSource _dataSource;
  
  final _ofertasController = StreamController<List<Oferta>>.broadcast();
  
  OfertaRepositoryImpl(this._dataSource);
  
  @override
  Stream<List<Oferta>> obtenerOfertasActivas() {
    _cargarOfertasActivas();
    return _ofertasController.stream;
  }
  
  Future<void> _cargarOfertasActivas() async {
    try {
      final ahora = DateTime.now().toIso8601String();
      final datos = await _dataSource.select(
        'ofertas',
        filtros: "estado_oferta=eq.Activa&fecha_inicio=lte.$ahora&fecha_fin=gte.$ahora",
        orderBy: 'order=fecha_fin.asc',
      );
      
      final ofertas = datos.map((json) => Oferta.fromJson(json)).toList();
      _ofertasController.add(ofertas);
    } catch (e) {
      _ofertasController.addError(e);
    }
  }
  
  @override
  Stream<List<Oferta>> obtenerTodasLasOfertas() {
    _cargarTodasLasOfertas();
    return _ofertasController.stream;
  }
  
  Future<void> _cargarTodasLasOfertas() async {
    try {
      final datos = await _dataSource.select(
        'ofertas',
        orderBy: 'order=fecha_fin.desc',
      );
      
      final ofertas = datos.map((json) => Oferta.fromJson(json)).toList();
      _ofertasController.add(ofertas);
    } catch (e) {
      _ofertasController.addError(e);
    }
  }
  
  @override
  Future<Oferta?> obtenerOfertaPorId(int id) async {
    try {
      final datos = await _dataSource.select(
        'ofertas',
        filtros: 'id=eq.$id',
      );
      
      if (datos.isEmpty) return null;
      return Oferta.fromJson(datos.first);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Oferta?> obtenerOfertaPorProducto(String idProductoFirebase) async {
    try {
      final datos = await _dataSource.select(
        'ofertas',
        filtros: "id_producto_firebase=eq.$idProductoFirebase&estado_oferta=eq.Activa",
      );
      
      if (datos.isEmpty) return null;
      return Oferta.fromJson(datos.first);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Oferta> crearOferta(Oferta oferta) async {
    final datos = await _dataSource.insert('ofertas', oferta.toJson());
    _cargarOfertasActivas();
    return Oferta.fromJson(datos);
  }
  
  @override
  Future<Oferta> actualizarOferta(Oferta oferta) async {
    await _dataSource.update('ofertas', oferta.toJson(), 'id=eq.${oferta.id}');
    _cargarOfertasActivas();
    return oferta;
  }
  
  @override
  Future<bool> eliminarOferta(int id) async {
    return await _dataSource.delete('ofertas', 'id=eq.$id');
  }
  
  void dispose() {
    _ofertasController.close();
  }
}
import 'package:get_it/get_it.dart';
import 'data/datasources/supabase_datasource.dart';
import 'data/datasources/firebase_datasource.dart';
import 'data/repositories/repositorio_cliente_impl.dart';
import 'data/repositories/repositorio_vehiculo_impl.dart';
import 'data/repositories/repositorio_inventario_impl.dart';
import 'data/repositories/repositorio_oferta_impl.dart';
import 'data/repositories/repositorio_factura_impl.dart';
import 'data/auth_repository_impl.dart';
import 'domain/repositories/cliente_repository.dart';
import 'domain/repositories/vehiculo_repository.dart';
import 'domain/repositories/inventario_repository.dart';
import 'domain/repositories/oferta_repository.dart';
import 'domain/repositories/factura_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/repositorio_proveedor_impl.dart';
import 'domain/repositories/proveedor_repository.dart';
import 'presentation/controllers/proveedor_controller.dart';
import 'presentation/controllers/reportes_controller.dart';
import 'presentation/controllers/facturacion_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/inventario_controller.dart';
import 'presentation/controllers/oferta_controller.dart';

final getIt = GetIt.instance;

void configurarDependencias() {
  getIt.registerLazySingleton<SupabaseDataSource>(
    () => SupabaseDataSource(useServiceRole: true),
  );

  getIt.registerLazySingleton<FirebaseDataSource>(
    () => FirebaseDataSource(),
  );

  getIt.registerLazySingleton<ClienteRepository>(
    () => ClienteRepositoryImpl(getIt<SupabaseDataSource>()),
  );

  getIt.registerLazySingleton<VehiculoRepository>(
    () => VehiculoRepositoryImpl(getIt<SupabaseDataSource>()),
  );

  getIt.registerLazySingleton<InventarioRepository>(
    () => InventarioRepositoryImpl(getIt<SupabaseDataSource>()),
  );

  getIt.registerLazySingleton<OfertaRepository>(
    () => OfertaRepositoryImpl(getIt<SupabaseDataSource>()),
  );

  getIt.registerLazySingleton<ProveedorRepository>(
    () => ProveedorRepositoryImpl(getIt<SupabaseDataSource>()),
  );

  getIt.registerLazySingleton<FacturaRepository>(
    () => FacturaRepositoryImpl(getIt<SupabaseDataSource>(), getIt<InventarioRepository>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<SupabaseDataSource>()),
  );

  getIt.registerFactory<FacturacionController>(
    () => FacturacionController(
      clienteRepository: getIt<ClienteRepository>(),
      vehiculoRepository: getIt<VehiculoRepository>(),
      inventarioRepository: getIt<InventarioRepository>(),
      ofertaRepository: getIt<OfertaRepository>(),
      facturaRepository: getIt<FacturaRepository>(),
    ),
  );

  getIt.registerFactory<AuthController>(
    () => AuthController(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerFactory<InventarioController>(
    () => InventarioController(
      repository: getIt<InventarioRepository>(),
    ),
  );

  getIt.registerFactory<ProveedorController>(
    () => ProveedorController(
      repository: getIt<ProveedorRepository>(),
    ),
  );

  getIt.registerFactory<ReportesController>(
    () => ReportesController(
      facturaRepository: getIt<FacturaRepository>(),
      inventarioRepository: getIt<InventarioRepository>(),
      vehiculoRepository: getIt<VehiculoRepository>(),
    ),
  );

  getIt.registerFactory<OfertaController>(
    () => OfertaController(
      repository: getIt<OfertaRepository>(),
    ),
  );
}
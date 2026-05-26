# DOCUMENTACIÓN DE CAMBIOS - MÓDULO FACTURACIÓN
## Control de Stock en Facturación

**Fecha:** 26 Mayo 2026
**Proyecto:** Taller Rodriguez
**Módulo:** Facturación / Inventario

---

## 1. RESUMEN DE LA MODIFICACIÓN

Se implementó el control de stock en el módulo de facturación para que:
- Al facturar un producto, el stock del inventario se reduzca automáticamente
- No se pueda facturar más producto del disponible
- El frontend muestre visualmente cuando un producto está bajo de stock o agotado
- Existe validación en 3 capas: Frontend, Backend y Base de Datos
- Se agregaron botones para aumentar y reducir cantidad de productos en la tabla de factura

---

## 2. ARCHIVOS MODIFICADOS

### 2.1 BACKEND

#### A) `backend/lib/domain/repositories/inventario_repository.dart`
**Cambios:**
- Agregado método `Future<bool> restarStock(String id, int cantidad)`
- Agregado método `Future<int> obtenerStockProducto(String id)`

```dart
// Líneas 25-27 (nuevas)
Future<bool> restarStock(String id, int cantidad);
Future<int> obtenerStockProducto(String id);
```

#### B) `backend/lib/data/repositories/repositorio_inventario_impl.dart`
**Cambios:**
- Implementados los métodos `restarStock()` y `obtenerStockProducto()`

```dart
// Líneas 162-200 (nuevos métodos)
@override
Future<bool> restarStock(String id, int cantidad) async { ... }

@override
Future<int> obtenerStockProducto(String id) async { ... }
```

#### C) `backend/lib/presentation/controllers/facturacion_controller.dart`
**Cambios:**
- Modificado método `crearFactura()` para validar stock antes de crear la factura
- Agregada lógica de validación que verifica stock disponible para cada producto tipo "Producto"
- Si el stock es insuficiente, retorna error con mensaje detallado
- Agregado campo `stock_minimo` a la respuesta de `obtenerInventario()`

```dart
// Validación agregada en crearFactura()
for (final item in itemsData) {
  final tipoProducto = item['tipo'] as String? ?? 'Producto';
  if (tipoProducto.toLowerCase() == 'producto') {
    final idProducto = item['id_producto'] as String? ?? '';
    final cantidadSolicitada = item['cantidad'] as int? ?? 1;
    final stockDisponible = await _inventarioRepository.obtenerStockProducto(idProducto);

    if (stockDisponible < cantidadSolicitada) {
      final nombreProducto = item['nombre'] as String? ?? 'Producto';
      return _respuestaError(
        'Stock insuficiente para $nombreProducto. Stock disponible: $stockDisponible, solicitado: $cantidadSolicitada'
      );
    }
  }
}
```

#### D) `backend/lib/data/repositories/repositorio_factura_impl.dart`
**Cambios:**
- Agregada dependencia de `InventarioRepository` al constructor
- Modificado método `crearFactura()` para restar stock después de crear la factura

```dart
// Nueva dependencia
final InventarioRepository _inventarioRepository;

// Constructor actualizado
FacturaRepositoryImpl(this._dataSource, this._inventarioRepository);

// Resta de stock al facturar
for (final detalle in factura.detalles) {
  final esProducto = detalle.tipo_producto.toLowerCase() == 'producto';
  if (esProducto) {
    await _inventarioRepository.restarStock(detalle.id_producto, detalle.cantidad);
  }
}
```

#### E) `backend/lib/injection.dart`
**Cambios:**
- Actualizado registro de `FacturaRepository` para incluir `InventarioRepository`

```dart
getIt.registerLazySingleton<FacturaRepository>(
  () => FacturaRepositoryImpl(getIt<SupabaseDataSource>(), getIt<InventarioRepository>()),
);
```

---

### 2.2 FRONTEND

#### A) `frontend/lib/pages/factura.dart`
**Cambios:**

1. Modificado método `_agregarItem()`:
   - Agregada validación de stock antes de agregar producto
   - Si es un producto (no servicio), verifica que haya stock disponible
   - Muestra mensaje de error si no hay stock

2. Modificado método `_buildItemFactura()`:
   - Agregados parámetros `stock`, `onIncrease`, `onDecrease`
   - Reemplazado texto de cantidad por botones `-` y `+`
   - Validación: botón `-` deshabilitado si cantidad = 1
   - Validación: botón `+` deshabilitado si stock = cantidad (para productos)
   - Servicios pueden aumentar sin límite de stock

3. Modificado header de tabla:
   - "CANT." cambiado a "CANTIDAD" para indicar controles

4. Nuevos métodos agregados:
   - `_aumentarCantidad(int index)`: Incrementa cantidad validando stock
   - `_reducirCantidad(int index)`: Decrementa cantidad (mínimo 1)

5. Modificado método `_buildProductRow()`:
   - Productos con stock = 0 se muestran con fondo rojo y botón deshabilitado
   - Productos con stock bajo (≤ stock_mínimo) se muestran con fondo naranja
   - Icono de warning para stock bajo
   - Icono de bloque para stock agotado

---

### 2.3 BASE DE DATOS

#### A) `database/validacion_stock_facturacion.sql` (NUEVO)
**Contenido:**
- Función `validar_stock_detalle_factura()`: Valida stock antes de insertar
- Trigger `trg_validar_stock_detalle_factura`: Ejecuta validación
- Función `restar_stock_detalle_factura()`: Resta stock después de insertar
- Trigger `trg_restar_stock_detalle_factura`: Ejecuta resta automática
- Función `restaurar_stock_detalle_factura()`: Restaura stock al eliminar
- Trigger `trg_restaurar_stock_detalle_factura`: Ejecuta restauración

---

## 3. FUNCIONALIDAD DE BOTONES (AUMENTAR/REDUCIR)

### Botón [+] Aumentar Cantidad
- **Estado habilitado**: Color verde, permite hacer clic
- **Estado deshabilitado**: Color gris claro, no permite hacer clic
- **Condiciones de habilitación**:
  - Para productos: solo si `cantidad < stock_disponible`
  - Para servicios: siempre habilitado (sin límite de stock)

### Botón [-] Reducir Cantidad
- **Estado habilitado**: Color rojo, permite hacer clic
- **Estado deshabilitado**: Color gris claro, no permite hacer clic
- **Condiciones de habilitación**:
  - Solo si `cantidad > 1` (no puede haber 0 items)

---

## 4. ARQUITECTURA DE VALIDACIÓN (3 CAPAS)

### 4.1 AL AGREGAR PRODUCTO (FRONTEND)
1. Usuario hace clic en producto
2. Sistema verifica si es un "Producto" o "Servicio"
3. Si es Producto, compara cantidad en factura vs stock disponible
4. Si cantidad_en_factura >= stock_disponible → Muestra error y no agrega
5. Si hay stock, incrementa cantidad o agrega nuevo item

### 4.2 AL AUMENTAR/REDUCIR CANTIDAD (FRONTEND)
1. Usuario presiona botón [+] o [-]
2. Si [-]: decrementa cantidad (mínimo 1)
3. Si [+] para producto: verifica stock disponible
4. Si [+] para servicio: incrementa sin límite
5. Recalcula totales automáticamente

### 4.3 AL PROCESAR FACTURA (BACKEND - CONTROLLER)
1. Recibe petición de crear factura
2. Itera sobre cada item y verifica stock en base de datos
3. Si algún producto no tiene stock suficiente → Retorna error
4. Si todo OK, procede a crear la factura

### 4.4 AL CREAR FACTURA (BACKEND - REPOSITORY)
1. Inserta registro en tabla `facturacion`
2. Inserta registros en tabla `detalles_factura`
3. Para cada detalle que sea "Producto", resta el stock
4. Retorna factura creada

### 4.5 AL INSERTAR EN `detalles_factura` (BASE DE DATOS)
1. Trigger `trg_validar_stock_detalle_factura` verifica stock
2. Si stock_insuficiente → Cancela operación con excepción
3. Si stock_ok → Permite inserción
4. Trigger `trg_restar_stock_detalle_factura` resta el stock

---

## 5. ESQUEMA DE DATOS AFECTADOS

### Tabla `inventario`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID | Identificador único |
| nombre | VARCHAR | Nombre del producto |
| tipo | VARCHAR | "Producto" o "Servicio" |
| stock | INTEGER | Cantidad disponible |
| stock_minimo | INTEGER | Nivel mínimo de stock |
| stock_maximo | INTEGER | Nivel máximo de stock |
| ultima_actualizacion | TIMESTAMP | Última modificación |

### Tabla `detalles_factura`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | SERIAL | Identificador único |
| id_factura | INTEGER | FK a facturacion |
| id_producto | VARCHAR | ID del producto/servicio |
| nombre_producto | VARCHAR | Nombre para referencia |
| tipo_producto | VARCHAR | "Producto" o "Servicio" |
| cantidad | INTEGER | Cantidad facturada |
| precio_unitario | DECIMAL | Precio por unidad |
| subtotal | DECIMAL | cantidad × precio_unitario |

---

## 6. MENSAJES DE ERROR

| Escenario | Mensaje |
|-----------|---------|
| Stock insuficiente (Frontend - agregar) | "No hay más stock disponible para [nombre]. Stock: [disponible]" |
| Stock insuficiente (Backend) | "Stock insuficiente para [nombre]. Stock disponible: [X], solicitado: [Y]" |
| Base de datos (Trigger) | "Stock insuficiente. Producto: [X], Stock disponible: [Y], Cantidad solicitada: [Z]" |

---

## 7. NOTAS DE IMPLEMENTACIÓN

- **Servicios**: Los servicios no tienen stock, por lo que no se valida su cantidad
- **Transaccionalidad**: El backend usa una única conexión a Supabase por request
- **Concurrencia**: El trigger de base de datos maneja Race Conditions
- **Actualización de UI**: El frontend recalcula totales al cambiar cantidad

---

## 8. TESTING RECOMENDADO

1. Facturar un producto con stock suficiente → Stock debe reducirse
2. Facturar un producto con stock exactamente igual a la cantidad → Debe funcionar
3. Facturar un producto con stock menor a la cantidad → Debe retornar error
4. Intentar agregar producto sin stock → Frontend debe mostrar error
5. Productos con stock bajo deben mostrarse en naranja
6. Productos sin stock deben mostrarse en rojo y deshabilitados
7. Botón [+] debe deshabilitarse cuando stock = cantidad en factura
8. Botón [-] debe deshabilitarse cuando cantidad = 1
9. Aumentar cantidad de un producto debe recalcular totales inmediatamente
10. Reducir cantidad debe mantener mínimo de 1

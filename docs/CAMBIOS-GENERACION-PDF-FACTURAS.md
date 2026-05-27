# Documentacion de Cambios: Generacion de PDF de Facturas en Backend

**Fecha:** 26 de Mayo de 2026
**Modulo:** Facturacion
**Funcionalidad:** Generacion de PDF de facturas en el backend (Dart)
**Autor:** Backend Team

---

## 1. Resumen del Cambio

Se implemento la funcionalidad para generar documentos PDF de facturas directamente desde el backend en Dart. Anteriormente, el frontend generaba los PDFs usando la libreria `pdf`. Ahora, el backend genera el PDF de forma privada y lo devuelve al cliente como descarga.

---

## 2. Archivos Creados

### 2.1 Domain Layer

#### `backend/lib/domain/entities/pdf_data.dart`
- **Descripcion:** Entidad que representa los datos necesarios para generar un PDF de factura
- **Clases:**
  - `PdfData`: Contiene todos los datos de la factura (cliente, vehiculo, items, totales)
  - `ItemPdfData`: Representa cada item/detalle de la factura
- **Paradigma:** Clean Architecture con Programacion Funcional Reactiva (streams)

#### `backend/lib/domain/repositories/pdf_repository.dart`
- **Descripcion:** Interface abstracta del repositorio de PDF
- **Metodo:** `Stream<Uint8List> generarFacturaPdf(PdfData pdfData)`
- **Paradigma:** Clean Architecture - Repository Pattern

#### `backend/lib/domain/usecases/generar_factura_pdf.dart`
- **Descripcion:** Caso de uso para generar PDF de factura
- **Implementacion:** Delega la generacion al repositorio
- **Paradigma:** Clean Architecture - Use Case Pattern + Programacion Funcional Reactiva

---

### 2.2 Data Layer

#### `backend/lib/data/datasources/pdf_datasource.dart`
- **Descripcion:** Datasource que genera el documento PDF usando la libreria `pdf`
- **Funcionalidades:**
  - Lee el logo del taller desde `frontend/assets/logo_taller.png`
  - Genera PDF con formato profesional
  - Incluye: header con logo y tipo de factura, informacion del cliente y vehiculo, tabla de items, totales
- **Libreria:** `package:pdf: ^3.11.0`

#### `backend/lib/data/repositories/pdf_repository_impl.dart`
- **Descripcion:** Implementacion del repositorio de PDF
- **Metodo:** Convierte el Future del datasource en Stream para cumplir con la interfaz reactiva

---

### 2.3 Presentation Layer

#### `backend/lib/presentation/controllers/pdf_controller.dart`
- **Descripcion:** Controlador que orquesta la generacion de PDF
- **Responsabilidades:**
  - Obtiene la factura y sus detalles desde Supabase
  - Mapea los datos al formato `PdfData`
  - Delega la generacion al use case
- **Paradigma:** Clean Architecture - Controller Pattern + Programacion Funcional Reactiva

---

## 3. Archivos Modificados

### 3.1 `backend/pubspec.yaml`
**Cambio:** Se agrego la dependencia `pdf: ^3.11.0`

```yaml
dependencies:
  pdf: ^3.11.0
```

**Razon:** Libreria para generacion de documentos PDF en Dart de forma privada (sin depender de servicios externos)

---

### 3.2 `backend/lib/injection.dart`
**Cambio:** Se registraron las dependencias para el modulo de PDF

**Imports agregados:**
```dart
import 'data/datasources/pdf_datasource.dart';
import 'data/repositories/pdf_repository_impl.dart';
import 'domain/repositories/pdf_repository.dart';
import 'domain/usecases/generar_factura_pdf.dart';
import 'presentation/controllers/pdf_controller.dart';
```

**Registros agregados:**
```dart
getIt.registerLazySingleton<PdfDatasource>(() => PdfDatasource());
getIt.registerLazySingleton<PdfRepository>(() => PdfRepositoryImpl(getIt<PdfDatasource>()));
getIt.registerFactory<GenerarFacturaPdf>(() => GenerarFacturaPdf(getIt<PdfRepository>()));
getIt.registerFactory<PdfController>(() => PdfController(
  generarFacturaPdf: getIt<GenerarFacturaPdf>(),
  supabaseDataSource: getIt<SupabaseDataSource>(),
));
```

**Razon:** Inyeccion de dependencias siguiendo el patron de Clean Architecture y usando `get_it`

---

### 3.3 `backend/lib/presentation/routes/app_routes.dart`
**Cambio:** Se agrega la ruta para descargar PDF de factura

**Imports agregados:**
```dart
import '../controllers/pdf_controller.dart';
```

**En el constructor AppRoutes():**
```dart
_pdfController = getIt<PdfController>(),
```

**Ruta agregada:**
```dart
router.get('/api/facturas/<id>/pdf', _generarPdfFactura);
```

**Handler agregado:**
```dart
Future<Response> _generarPdfFactura(Request request, String id) async {
  final idInt = int.tryParse(id);
  if (idInt == null) {
    return Response.badRequest(...);
  }
  try {
    final bytes = await _pdfController.generarPdfPorId(idInt).first;
    return Response.bytes(
      bytes,
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': 'attachment; filename="factura_$id.pdf"',
      },
    );
  } catch (e) {
    return Response.internalServerError(...);
  }
}
```

**Razon:** Exponer endpoint REST para que el frontend pueda descargar el PDF

---

## 4. Nueva Ruta de API

| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| GET | `/api/facturas/<id>/pdf` | Descarga el PDF de la factura con el ID especificado |

**Respuesta:**
- **Exito:** `200 OK` con `Content-Type: application/pdf`
- **Error:** `400 Bad Request` (ID invalido) o `500 Internal Server Error` (error al generar)

---

## 5. Estructura del PDF Generado

El documento PDF incluye:

1. **Header**
   - Logo del taller (imagen)
   - Nombre del taller "TALLER RODRIGUEZ"
   - Tipo de factura (Credito Fiscal / Consumidor Final)
   - Numero de factura (formato FAC-000001)
   - Fecha de emision

2. **Informacion del Cliente**
   - Nombre del cliente
   - RTN (si aplica)
   - Telefono
   - Email

3. **Informacion del Vehiculo** (si aplica)
   - Marca, modelo y anio
   - Placa

4. **Tabla de Items**
   - Cantidad
   - Descripcion (nombre del producto/servicio + tipo)
   - Precio unitario
   - Subtotal

5. **Totales**
   - Subtotal
   - Descuento (si aplica, con porcentaje)
   - IVA (13%)
   - **TOTAL** (destacado en rojo)

---

## 6. Arquitectura y Paradigmas

### 6.1 Clean Architecture
La implementacion sigue las capas de Clean Architecture:
- **Domain:** Entidades, Use Cases, Repository Interfaces
- **Data:** Datasources, Repository Implementations
- **Presentation:** Controllers, Routes

### 6.2 Dependency Injection
Se utiliza `get_it` para la inyeccion de dependencias, registrando:
- `PdfDatasource` como LazySingleton
- `PdfRepository` como LazySingleton
- `GenerarFacturaPdf` como Factory
- `PdfController` como Factory

### 6.3 Programacion Funcional Reactiva (Streams)
- El metodo `generarFacturaPdf` del repositorio retorna un `Stream<Uint8List>`
- El controlador usa async generators para obtener los bytes
- Permite procesamiento reactivo de datos

---

## 7. Uso desde Frontend

El frontend puede consumir el endpoint de la siguiente manera:

```dart
final response = await http.get(
  Uri.parse('${baseUrl}/api/facturas/$idFactura/pdf'),
);
if (response.statusCode == 200) {
  final bytes = response.bodyBytes;
  // Guardar o mostrar el PDF
}
```

---

## 8. Dependencias Externas

| Paquete | Version | Proposito |
|---------|---------|-----------|
| pdf | ^3.11.0 | Generacion de documentos PDF en Dart |

---

## 9. Archivos Involucrados Resumen

### Creados (4 archivos):
1. `backend/lib/domain/entities/pdf_data.dart`
2. `backend/lib/domain/repositories/pdf_repository.dart`
3. `backend/lib/domain/usecases/generar_factura_pdf.dart`
4. `backend/lib/data/datasources/pdf_datasource.dart`
5. `backend/lib/data/repositories/pdf_repository_impl.dart`
6. `backend/lib/presentation/controllers/pdf_controller.dart`

### Modificados (3 archivos):
1. `backend/pubspec.yaml`
2. `backend/lib/injection.dart`
3. `backend/lib/presentation/routes/app_routes.dart`

---

## 10. Notas de Implementacion

1. El logo se busca en la ruta relativa `frontend/assets/logo_taller.png` desde el directorio de ejecucion del servidor
2. Si el logo no existe, el PDF se genera sin logo (no falla)
3. El numero de factura se formatea como `FAC-XXXXXX` (6 digitos)
4. El PDF sigue el formato `PdfPageFormat.letter` (carta americana)
5. Todos los precios usan formato de 2 decimales (`toStringAsFixed(2)`)

---

## 11. Cambios en Frontend (Vista de Descarga de PDF)

### Archivos Modificados

#### `frontend/lib/services/facturacion_api.dart`
**Metodo agregado:**
```dart
Future<Uint8List?> descargarPdfFactura(int idFactura) async {
  try {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/facturas/$idFactura/pdf'),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  } catch (e) {
    return null;
  }
}
```

#### `frontend/lib/pages/factura.dart`
**Importaciones agregadas:**
```dart
import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
```

**Metodo `_mostrarDialogoPdf` agregado:**
```dart
Future<void> _mostrarDialogoPdf(int? idFactura) async {
  if (idFactura == null) return;

  final bytes = await _api.descargarPdfFactura(idFactura);

  if (!mounted) return;

  if (bytes != null) {
    showDialog(
      context: context,
      builder: (context) => _PdfDialogo(facturaBytes: bytes, idFactura: idFactura),
    );
  } else {
    _mostrarMensaje('Factura creada pero PDF no disponible', isError: true);
  }
}
```

**Llamada en `_procesarFactura`:**
```dart
if (resultado != null && resultado['success'] == true) {
  final idFactura = resultado['data']?['id'] as int?;
  await _mostrarDialogoPdf(idFactura);
  _mostrarMensaje('Factura creada exitosamente');
  // ... resto del codigo
}
```

**Widget `_PdfDialogo` agregado:**
- Dialogo con icono de exito
- Numero de factura
- Boton "Cerrar" para cerrar el dialogo
- Boton "Descargar PDF" que descarga el PDF de la factura

### Flujo de Usuario

1. Usuario procesa la factura
2. Se crea la factura en la base de datos (Supabase)
3. Se muestra automaticamente un dialogo con:
   - Icono de check verde
   - Mensaje "Factura creada exitosamente"
   - Numero de factura
   - Boton "Cerrar" para cerrar el dialogo
   - Boton "Descargar PDF" para descargar la factura en PDF

---

## 12. Compatibilidad

- El endpoint de descarga de PDF funciona para cualquier plataforma (web, mobile, desktop)
- La interfaz de descarga usa `dart:html` que es solo para web
- En futuras actualizaciones se puede implementar `open_filex` para plataformas nativas

---

## 13. Corrección de Bugs en Generación de PDF

**Fecha:** 26 de Mayo de 2026
**Problema:** La generación de PDF no funcionaba correctamente

### 13.1 Problemas Identificados

| # | Problema | Gravedad | Archivo Afectado |
|---|----------|----------|------------------|
| 1 | Los datos del cliente (nombre, teléfono, DUI, correo) nunca se almacenaban en la factura al crearla | CRÍTICO | `facturacion_controller.dart` |
| 2 | El campo RTN usaba incorrectamente `dui_cliente` en lugar del campo correcto | MEDIO | `pdf_controller.dart` |
| 3 | Campo NRC no existía en la entidad Factura para Crédito Fiscal | MEDIO | `factura.dart` |
| 4 | El código usaba `dart:html` que está deprecado y causa warnings | BAJO | `factura.dart` (frontend) |

### 13.2 Archivos Modificados

#### Backend

**`backend/lib/domain/entities/factura.dart`**
- Se agregaron campos `rtn_cliente` (String) y `nrc_cliente` (int)
- Se actualizaron: constructor, factory `crear`, `fromJson`, `toJson`, `props`

```dart
final String? rtn_cliente;
final int? nrc_cliente;
```

**`backend/lib/domain/entities/pdf_data.dart`**
- Se agregó campo `nrcCliente` (int?) a la clase `PdfData`
- Se actualizó la factory `fromFactura` y `props`

**`backend/lib/presentation/controllers/facturacion_controller.dart`**
- Al crear una factura, ahora consulta los datos completos del cliente desde `_clienteRepository`
- Los datos se guardan en la factura: `nombre_cliente`, `telefono_cliente`, `dui_cliente`, `correo_cliente`, `rtn_cliente`, `nrc_cliente`

```dart
if (body['id_cliente'] != null) {
  final cliente = await _clienteRepository.obtenerClientePorId(body['id_cliente'] as int);
  if (cliente != null) {
    nombreCliente = cliente.nombre;
    telefonoCliente = cliente.telefono;
    duiCliente = cliente.dui;
    correoCliente = cliente.correo;
    rtnCliente = cliente.rtn;
    nrcCliente = cliente.nrc;
  }
}
```

**`backend/lib/presentation/controllers/pdf_controller.dart`**
- Corregido el mapeo: ahora usa `factura.rtn_cliente` directamente en lugar de `factura.dui_cliente`
- Se agregó el campo `nrcCliente` en el mapeo a `PdfData`

**`backend/lib/data/repositories/repositorio_factura_impl.dart`**
- Se actualizaron todos los constructores de `Factura` para incluir `rtn_cliente` y `nrc_cliente`
- En `crearFactura()`, se guardan todos los campos del cliente en la base de datos

**`backend/lib/data/datasources/pdf_datasource.dart`**
- En el PDF ahora se muestra el NRC del cliente cuando está disponible
- Se muestra RTN y NRC en la sección de información del cliente

#### Frontend

**`frontend/pubspec.yaml`**
- Se agregó dependencia `web: ^1.1.0` para reemplazar `dart:html`

**`frontend/lib/pages/factura.dart`**
- Reemplazado `import 'dart:html' as html;` por `import 'package:web/web.dart' as web;`
- Actualizado método `_descargarPdf` para usar la nueva API del paquete `web`

```dart
void _descargarPdf(BuildContext context) async {
  try {
    final encoded = base64Encode(facturaBytes);
    final anchor = web.HTMLAnchorElement()
      ..href = 'data:application/pdf;base64,$encoded'
      ..download = 'factura_$idFactura.pdf'
      ..style.display = 'none';
    web.window.document.body!.appendChild(anchor);
    anchor.click();
    web.window.document.body!.removeChild(anchor);
    if (context.mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    // manejo de errores
  }
}
```

### 13.3 Resumen de Cambios

| Archivo | Cambio |
|---------|--------|
| `backend/lib/domain/entities/factura.dart` | +2 campos (rtn_cliente, nrc_cliente) |
| `backend/lib/domain/entities/pdf_data.dart` | +1 campo (nrcCliente) |
| `backend/lib/presentation/controllers/facturacion_controller.dart` | Consulta y guarda datos completos del cliente |
| `backend/lib/presentation/controllers/pdf_controller.dart` | Corrección mapeo RTN/NRC |
| `backend/lib/data/repositories/repositorio_factura_impl.dart` | Soporte para campos rtn_cliente, nrc_cliente |
| `backend/lib/data/datasources/pdf_datasource.dart` | Muestra NRC en el PDF |
| `frontend/pubspec.yaml` | +web: ^1.1.0 |
| `frontend/lib/pages/factura.dart` | Modernización API web |

### 13.4 Verificación

El backend compila sin errores:
```bash
cd backend && dart analyze lib/
```

El frontend compila sin errores:
```bash
cd frontend && flutter analyze lib/pages/factura.dart
```

### 13.5 Bug Adicional: Columna 'anio_vehiculo' no existe

**Fecha:** 26 de Mayo de 2026
**Error:** `Could not find the 'anio_vehiculo' column of 'facturacion' in the schema cache`

**Causa:** El código intentaba insertar `anio_vehiculo` y otros campos de vehículo como nulos en la tabla `facturacion`, pero la columna no existe en Supabase.

**Solución:** Modificar `crearFactura` en `repositorio_factura_impl.dart` para solo insertar campos de vehículo si no son nulos:

```dart
if (factura.modelo_vehiculo != null) {
  facturaData['modelo_vehiculo'] = factura.modelo_vehiculo;
}
if (factura.marca_vehiculo != null) {
  facturaData['marca_vehiculo'] = factura.marca_vehiculo;
}
if (factura.placa_vehiculo != null) {
  facturaData['placa_vehiculo'] = factura.placa_vehiculo;
}
if (factura.anio_vehiculo != null) {
  facturaData['anio_vehiculo'] = factura.anio_vehiculo;
}
```

**Archivo modificado:** `backend/lib/data/repositories/repositorio_factura_impl.dart`

### 13.6 Bug Adicional: Columnas de cliente no existen

**Fecha:** 26 de Mayo de 2026
**Error:** `Could not find the 'correo_cliente' column of 'facturacion' in the schema cache`

**Causa:** La tabla `facturacion` en Supabase no tiene las columnas `correo_cliente`, `rtn_cliente`, `nrc_cliente`. Solo tiene `id_cliente` como FK.

**Solución:** Modificar `crearFactura` para usar campos opcionales condicionalmente:

```dart
if (factura.nombre_cliente != null) {
  facturaData['nombre_cliente'] = factura.nombre_cliente;
}
if (factura.telefono_cliente != null) {
  facturaData['telefono_cliente'] = factura.telefono_cliente;
}
if (factura.dui_cliente != null) {
  facturaData['dui_cliente'] = factura.dui_cliente;
}
if (factura.rtn_cliente != null) {
  facturaData['rtn_cliente'] = factura.rtn_cliente;
}
if (factura.nrc_cliente != null) {
  facturaData['nrc_cliente'] = factura.nrc_cliente;
}
```

**Archivo modificado:** `backend/lib/data/repositories/repositorio_factura_impl.dart`

### 13.7 Nota Importante

La tabla `facturacion` en Supabase tiene un esquema limitado. Los campos que se insertan condicionalmente son:
- `nombre_cliente`, `telefono_cliente`, `dui_cliente`, `rtn_cliente`, `nrc_cliente` (solo si existen en la BD)
- `modelo_vehiculo`, `marca_vehiculo`, `placa_vehiculo`, `anio_vehiculo` (solo si existen en la BD)

Si alguna columna no existe en Supabase, el INSERT fallará. Para usar estos campos, primero debe agregar las columnas a la tabla `facturacion` en Supabase:
```sql
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS nombre_cliente TEXT;
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS telefono_cliente TEXT;
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS dui_cliente TEXT;
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS rtn_cliente TEXT;
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS nrc_cliente INTEGER;
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS modelo_vehiculo TEXT;
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS marca_vehiculo TEXT;
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS placa_vehiculo TEXT;
ALTER TABLE facturacion ADD COLUMN IF NOT EXISTS anio_vehiculo INTEGER;
```

### 13.8 Bug Adicional: PDF no disponible - Cliente no encontrado

**Fecha:** 26 de Mayo de 2026
**Error:** "Factura creada pero PDF no disponible"

**Causa:** El `PdfController` intentaba obtener datos del cliente desde la factura (campos `nombre_cliente`, `rtn_cliente`, etc.) pero estos campos no existen en la tabla `facturacion` de Supabase.

**Solución:** Modificar `PdfController` para consultar los datos del cliente directamente desde la tabla `clientes` usando `ClienteRepository`:

```dart
Future<PdfData> _mapearFacturaAPdfData(Map<String, dynamic> facturaMap) async {
  final factura = Factura.fromJson(facturaMap);
  // ... detalles ...

  String nombreCliente = 'Consumidor Final';
  String? rtnCliente;
  int? nrcCliente;
  String? telefonoCliente;
  String? emailCliente;

  if (factura.id_cliente != null) {
    final cliente = await clienteRepository.obtenerClientePorId(factura.id_cliente!);
    if (cliente != null) {
      nombreCliente = cliente.nombre;
      rtnCliente = cliente.rtn.isNotEmpty ? cliente.rtn : null;
      nrcCliente = cliente.nrc;
      telefonoCliente = cliente.telefono;
      emailCliente = cliente.correo;
    }
  }

  return PdfData.fromFactura(/* ... */);
}
```

**Archivos modificados:**
- `backend/lib/presentation/controllers/pdf_controller.dart` - Ahora consulta datos del cliente desde la tabla `clientes`
- `backend/lib/injection.dart` - Se agregó `clienteRepository` al constructor de `PdfController`
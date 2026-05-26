import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:frontend/services/facturacion_api.dart';

class FacturacionScreen extends StatefulWidget {
  const FacturacionScreen({super.key});

  @override
  State<FacturacionScreen> createState() => _FacturacionScreenState();
}

class _FacturacionScreenState extends State<FacturacionScreen> {
  // Instancia del servicio API
  final FacturacionApi _api = FacturacionApi();
  
  // Estado de carga
  bool _cargando = false;
  
  // Listas de datos del backend
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _vehiculos = [];
  List<Map<String, dynamic>> _ofertas = [];
  List<Map<String, dynamic>> _inventario = [];
  
  // Items de la factura actual
  List<Map<String, dynamic>> _itemsFactura = [];
  
  // Valores seleccionados
  int? _clienteSeleccionado;
  int? _vehiculoSeleccionado;
  String _tipoFactura = 'Credito Fiscal';
  int? _ofertaSeleccionada;
  double _descuentoPorcentaje = 0;
  
  // Text controllers
  final TextEditingController _busquedaController = TextEditingController();
  final TextEditingController _descuentoController = TextEditingController();
  
  // Totales
  double _subtotal = 0;
  double _iva = 0;
  double _descuento = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _descuentoController.dispose();
    super.dispose();
  }

  /// Carga todos los datos iniciales al abrir la pantalla
  Future<void> _cargarDatosIniciales() async {
    setState(() => _cargando = true);
    
    try {
      // Cargar clientes, ofertas e inventario en paralelo
      final resultados = await Future.wait([
        _api.obtenerClientes(),
        _api.obtenerOfertas(),
        _api.obtenerInventario(),
      ]);
      
      setState(() {
        _clientes = resultados[0];
        _ofertas = resultados[1];
        _inventario = resultados[2];
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  /// Carga los vehículos cuando se selecciona un cliente
  Future<void> _onClienteChanged(int? clienteId) async {
    setState(() {
      _clienteSeleccionado = clienteId;
      _vehiculos = [];
      _vehiculoSeleccionado = null;
    });
    
    if (clienteId != null) {
      final vehiculos = await _api.obtenerVehiculosPorCliente(clienteId);
      setState(() => _vehiculos = vehiculos);
    }
  }

  /// Busca productos en el inventario
  Future<void> _buscarInventario(String query) async {
    if (query.isEmpty) {
      final inventario = await _api.obtenerInventario();
      setState(() => _inventario = inventario);
    } else {
      final inventario = await _api.obtenerInventario(busqueda: query);
      setState(() => _inventario = inventario);
    }
  }

  /// Agrega un producto/servicio a la factura
  void _agregarItem(Map<String, dynamic> producto) {
    final tipoProducto = producto['tipo'] as String;
    final esProducto = tipoProducto.toLowerCase() != 'servicio';

    if (esProducto) {
      final stockDisponible = producto['stock'] as int? ?? 0;
      final stockMinimo = producto['stock_minimo'] as int? ?? 0;

      final indexExistente = _itemsFactura.indexWhere(
        (item) => item['id_producto'] == producto['id']
      );

      int cantidadEnFactura = 0;
      if (indexExistente >= 0) {
        cantidadEnFactura = _itemsFactura[indexExistente]['cantidad'] as int;
      }

      if (cantidadEnFactura >= stockDisponible) {
        _mostrarMensaje(
          'No hay más stock disponible para ${producto['nombre']}. Stock: $stockDisponible',
          isError: true,
        );
        return;
      }
    }

    final index = _itemsFactura.indexWhere(
      (item) => item['id_producto'] == producto['id']
    );

    setState(() {
      if (index >= 0) {
        _itemsFactura[index]['cantidad'] += 1;
      } else {
        _itemsFactura.add({
          'id_producto': producto['id'],
          'nombre': producto['nombre'],
          'tipo': producto['tipo'],
          'cantidad': 1,
          'precio_unitario': producto['precio_venta'],
          'stock': producto['stock'],
          'stock_minimo': producto['stock_minimo'],
        });
      }
      _calcularTotales();
    });
  }

  /// Calcula los subtotales, IVA y total
  void _calcularTotales() {
    // Calcular subtotal
    _subtotal = _itemsFactura.fold(0.0, (sum, item) {
      final cantidad = item['cantidad'] as int;
      final precio = (item['precio_unitario'] as num).toDouble();
      return sum + (cantidad * precio);
    });
    
    // Calcular descuento
    _descuento = _subtotal * (_descuentoPorcentaje / 100);
    
    // Calcular subtotal con descuento
    final subtotalConDescuento = _subtotal - _descuento;
    
    // Calcular IVA (13%)
    _iva = subtotalConDescuento * 0.13;
    
    // Calcular total
    _total = subtotalConDescuento + _iva;
  }

  /// Actualiza el descuento y recalcula totales
  void _actualizarDescuento(double porcentaje) {
    setState(() {
      _descuentoPorcentaje = porcentaje;
      _calcularTotales();
    });
  }

  /// Procesa y crea la factura en el backend
  Future<void> _procesarFactura() async {
    // Prevenir doble click
    if (_cargando) return;
    
    if (_clienteSeleccionado == null) {
      _mostrarMensaje('Debe seleccionar un cliente', isError: true);
      return;
    }
    
    if (_itemsFactura.isEmpty) {
      _mostrarMensaje('Debe agregar al menos un producto o servicio', isError: true);
      return;
    }
    
    setState(() => _cargando = true);
    
    // Intentar hasta 3 veces en caso de error de red
    Map<String, dynamic>? resultado;
    String? errorMsg;
    
    for (int intento = 1; intento <= 3; intento++) {
      try {
        resultado = await _api.crearFactura(
          idCliente: _clienteSeleccionado!,
          idVehiculo: _vehiculoSeleccionado,
          tipoFactura: _tipoFactura,
          items: _itemsFactura,
          descuentoPorcentaje: _descuentoPorcentaje,
          idOferta: _ofertaSeleccionada,
        );
        
        // Si成功了 (éxito), salir del loop
        if (resultado['success'] == true) {
          break;
        }
        
        // Si hubo error en el resultado, guardarlo
        errorMsg = resultado['message']?.toString() ?? 'Error desconocido';
        
      } catch (e) {
        errorMsg = 'Error de conexión: $e';
      }
      
      // Si no es el último intento, esperar antes de reintentar
      if (intento < 3) {
        await Future.delayed(Duration(milliseconds: 500 * intento));
      }
    }
    
    setState(() => _cargando = false);
    
if (resultado != null && resultado['success'] == true) {
      _mostrarMensaje('Factura creada exitosamente');
      await _limpiarFormulario();
      final warnings = resultado['warnings_stock'] as List?;
      if (warnings != null && warnings.isNotEmpty) {
        final mensajes = warnings.map<String>((w) {
          final nombre = (w as Map<String, dynamic>)['nombre'] ?? '';
          final stockActual = (w as Map<String, dynamic>)['stock_actual'] ?? 0;
          final stockMinimo = (w as Map<String, dynamic>)['stock_minimo'] ?? 0;
          return '$nombre: stock en $stockActual (minimo: $stockMinimo)';
        }).join('\n');
        _mostrarMensaje('Warning: algunos productos quedaron en stock minimo:\n$mensajes', isError: true);
      }
    } else {
      _mostrarMensaje(
        errorMsg ?? 'Error al crear factura',
        isError: true
      );
    }
  }

  /// Limpia el formulario después de crear una factura
  Future<void> _limpiarFormulario() async {
    setState(() {
      _itemsFactura = [];
      _clienteSeleccionado = null;
      _vehiculoSeleccionado = null;
      _ofertaSeleccionada = null;
      _descuentoPorcentaje = 0;
      _vehiculos = [];
      _calcularTotales();
    });

    final inventario = await _api.obtenerInventario();
    setState(() {
      _inventario = inventario;
    });
    // Limpiar campos de texto
    _descuentoController.clear();
    _busquedaController.clear();
  }

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;
    final bool isMedium = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      drawer: !isWide ? const SidebarDrawerContent() : null,
      appBar: !isWide ? AppBar(title: const Text('Facturación')) : null,
      backgroundColor: const Color(0xFFF8F9FA),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                const Sidebar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isWide)
                          const Text(
                            "Facturación",
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                          ),
                        const SizedBox(height: 20),
                        if (isMedium)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 370, child: _buildFormulario()),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: _buildTablaCentral()),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: _buildPanelProductos()),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildFormulario(),
                              const SizedBox(height: 16),
                              _buildTablaCentral(),
                              const SizedBox(height: 16),
                              _buildPanelProductos(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
// Dropdown Cliente
        _buildDropdown<int>(
          label: "Cliente",
          hint: "Seleccionar cliente",
          items: _clientes.map((c) => DropdownMenuItem<int>(
            value: c['id'] as int,
            child: Text(c['nombre']?.toString() ?? '', overflow: TextOverflow.ellipsis),
          )).toList(),
          value: _clienteSeleccionado,
          onChanged: (value) => _onClienteChanged(value),
        ),
        
        const SizedBox(height: 14),
        
        // Dropdown Vehículo
        _buildDropdown<int>(
          label: "Vehículo",
          hint: "Seleccionar vehículo",
          items: _vehiculos.map((v) => DropdownMenuItem<int>(
            value: v['id'] as int,
            child: Text('${v['marca']} ${v['modelo']} (${v['placa']})', overflow: TextOverflow.ellipsis),
          )).toList(),
          value: _vehiculoSeleccionado,
          onChanged: (value) {
            if (_vehiculos.isNotEmpty) {
              setState(() => _vehiculoSeleccionado = value);
            }
          },
        ),
        
        const SizedBox(height: 14),
        
        // Dropdown Tipo de factura
        _buildDropdown<String>(
          label: "Tipo de factura",
          hint: "Consumidor Final",
          items: const [
            DropdownMenuItem<String>(value: 'Consumidor Final', child: Text('Consumidor Final')),
            DropdownMenuItem<String>(value: 'Credito Fiscal', child: Text('Credito Fiscal')),
          ],
          value: _tipoFactura,
          onChanged: (value) => setState(() => _tipoFactura = value ?? 'Consumidor Final'),
        ),
        
        const SizedBox(height: 14),
        
        // Dropdown Ofertas
        _buildDropdown<int>(
          label: "Aplicar oferta",
          hint: "Ninguna",
          items: [
            const DropdownMenuItem<int>(value: null, child: Text('Ninguna')),
            ..._ofertas.map((o) => DropdownMenuItem<int>(
              value: o['id'] as int,
              child: Text('${o['nombre_oferta']} (${o['porcentaje_descuento']}% desc.)'),
            )),
          ],
          value: _ofertaSeleccionada,
          onChanged: (value) {
            setState(() => _ofertaSeleccionada = value);
            if (value != null && _ofertas.isNotEmpty) {
              final oferta = _ofertas.firstWhere((o) => o['id'] == value, orElse: () => {});
              if (oferta.isNotEmpty) {
                _actualizarDescuento((oferta['porcentaje_descuento'] as num).toDouble());
                _descuentoController.text = oferta['porcentaje_descuento'].toString();
              }
            }
          },
        ),
        
        const SizedBox(height: 14),
        
        // Campo de descuento
        const Text(
          "Porcentaje de descuento",
          style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Itim'),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _descuentoController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _MaxValueFormatter(100),
          ],
          decoration: InputDecoration(
            suffixText: "%",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          onChanged: (value) {
            final descuento = double.tryParse(value) ?? 0;
            _actualizarDescuento(descuento);
          },
        ),
      ],
    );
  }

  Widget _buildTablaCentral() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header rojo
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 1, child: Text("ID", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(flex: 3, child: Text("CANTIDAD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(flex: 4, child: Text("NOMBRE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(flex: 3, child: Text("TIPO", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(flex: 2, child: Text("PRECIO", textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    SizedBox(width: 32),
                  ],
                ),
              ),

              // Lista de items de la factura
              SizedBox(
                height: 260,
                child: _itemsFactura.isEmpty
                    ? const Center(
                        child: Text(
                          "Agregue productos desde el panel derecho",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _itemsFactura.length,
                        itemBuilder: (context, index) {
                          final item = _itemsFactura[index];
                          final cantidad = item['cantidad'] as int;
                          final precio = (item['precio_unitario'] as num).toDouble();
                          final stock = item['stock'] as int?;
                          return _buildItemFactura(
                            index + 1,
                            cantidad,
                            item['nombre'] as String,
                            item['tipo'] as String,
                            precio,
                            stock,
                            () => _eliminarItem(index),
                            () => _aumentarCantidad(index),
                            () => _reducirCantidad(index),
                          );
                        },
                      ),
              ),

              const Divider(height: 1),

              // Totales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    _buildTotalRow("Subtotal", "\$${_subtotal.toStringAsFixed(2)}"),
                    const SizedBox(height: 4),
                    if (_descuento > 0)
                      _buildTotalRow("Descuento (${_descuentoPorcentaje.toStringAsFixed(1)}%)", "-\$${_descuento.toStringAsFixed(2)}"),
                    _buildTotalRow("IVA (13%)", "\$${_iva.toStringAsFixed(2)}"),
                    const Divider(height: 16),
                    _buildTotalRow("Total", "\$${_total.toStringAsFixed(2)}", isTotal: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Botón procesar factura
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _cargando ? null : _procesarFactura,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _cargando ? "Procesando..." : "Procesar Factura",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Itim'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanelProductos() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Column(
        children: [
          // Buscador
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: "Buscar producto/servicio",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onSubmitted: _buscarInventario,
            ),
          ),
          const SizedBox(height: 12),

          // Tabla de productos
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 1, child: Text("ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 2, child: Text("PRECIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 3, child: Text("NOMBRE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 2, child: Text("TIPO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 1, child: Text("STOCK", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                ),

                // Lista de productos
                SizedBox(
                  height: 160,
                  child: _inventario.isEmpty
                      ? const Center(
                          child: Text(
                            "No hay productos disponibles",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _inventario.length,
                          itemBuilder: (context, index) {
                            final producto = _inventario[index];
                            return _buildProductRow(
                              index + 1,
                              producto['nombre'] as String,
                              (producto['precio_venta'] as num).toDouble(),
                              producto['tipo'] as String,
                              producto['stock'] as int?,
                              producto['stock_minimo'] as int?,
                              () => _agregarItem(producto),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required T? value,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Itim')),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(hint, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            items: items,
            onChanged: onChanged,
            borderRadius: BorderRadius.circular(8),
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 17 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: isTotal ? 20 : 14, fontWeight: FontWeight.bold, color: isTotal ? Colors.red : Colors.black)),
      ],
    );
  }

  Widget _buildItemFactura(int id, int cantidad, String nombre, String tipo, double precio, int? stock, VoidCallback onRemove, VoidCallback onIncrease, VoidCallback onDecrease) {
    final bool isServicio = tipo == "Servicio";
    final int stockDisponible = stock ?? 0;
    final bool puedeAumentar = !isServicio && cantidad < stockDisponible;
    final bool puedeReducir = cantidad > 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("#$id", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.remove, size: 16, color: puedeReducir ? Colors.grey.shade600 : Colors.grey.shade300),
                  onPressed: puedeReducir ? onDecrease : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "$cantidad",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.add, size: 16, color: puedeAumentar ? Colors.grey.shade600 : Colors.grey.shade300),
                  onPressed: puedeAumentar ? onIncrease : null,
                ),
              ),
            ],
          )),
          Expanded(flex: 4, child: Text(nombre, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(tipo, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isServicio ? Colors.orange.shade700 : Colors.blue.shade700))),
          Expanded(flex: 2, child: Text("\$${precio.toStringAsFixed(2)}", textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 32,
            child: IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(int id, String nombre, double precio, String tipo, int? stock, int? stockMinimo, VoidCallback onTap) {
    final bool isServicio = tipo == "Servicio";
    final int stockActual = stock ?? 0;
    final int stockMin = stockMinimo ?? 0;
    final bool sinStock = stockActual == 0;
    final bool stockBajo = !sinStock && stockActual <= stockMin;

    Color? rowColor;
    if (sinStock) {
      rowColor = Colors.red.shade50;
    } else if (stockBajo) {
      rowColor = Colors.orange.shade50;
    }

    return InkWell(
      onTap: sinStock ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: rowColor,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Expanded(flex: 1, child: Text("#$id", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text("\$${precio.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Expanded(flex: 3, child: Text(nombre, style: TextStyle(fontSize: 13, color: sinStock ? Colors.grey : Colors.black), overflow: TextOverflow.ellipsis, maxLines: 1)),
            Expanded(flex: 2, child: Text(tipo, style: TextStyle(fontSize: 13, color: isServicio ? Colors.orange.shade700 : Colors.blue.shade700, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            Expanded(flex: 1, child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (sinStock)
                  const Icon(Icons.block, size: 14, color: Colors.red)
                else if (stockBajo)
                  Icon(Icons.warning, size: 14, color: Colors.orange.shade700),
                const SizedBox(width: 4),
                Text(
                  stock != null ? "$stock" : "-",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: sinStock ? Colors.red : (stockBajo ? Colors.orange.shade700 : Colors.grey),
                    fontWeight: stockBajo ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  void _eliminarItem(int index) {
    setState(() {
      _itemsFactura.removeAt(index);
      _calcularTotales();
    });
  }

  void _aumentarCantidad(int index) {
    final item = _itemsFactura[index];
    final tipoProducto = item['tipo'] as String;
    final esProducto = tipoProducto.toLowerCase() != 'servicio';

    if (esProducto) {
      final stockDisponible = item['stock'] as int? ?? 0;
      final cantidadActual = item['cantidad'] as int;

      if (cantidadActual >= stockDisponible) {
        _mostrarMensaje(
          'No hay más stock disponible para ${item['nombre']}. Stock: $stockDisponible',
          isError: true,
        );
        return;
      }
    }

    setState(() {
      _itemsFactura[index]['cantidad'] += 1;
      _calcularTotales();
    });
  }

  void _reducirCantidad(int index) {
    final cantidadActual = _itemsFactura[index]['cantidad'] as int;
    if (cantidadActual > 1) {
      setState(() {
        _itemsFactura[index]['cantidad'] -= 1;
        _calcularTotales();
      });
    }
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  final int maxValue;

  _MaxValueFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final intValue = int.tryParse(newValue.text);
    if (intValue != null && intValue > maxValue) {
      return oldValue;
    }
    return newValue;
  }
}
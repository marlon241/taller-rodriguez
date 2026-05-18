import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import '../widgets/factura_item_row.dart';

class FacturacionScreen extends StatefulWidget {
  const FacturacionScreen({super.key});

  @override
  State<FacturacionScreen> createState() => _FacturacionScreenState();
}

class _FacturacionScreenState extends State<FacturacionScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;
    final bool isMedium = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      drawer: !isWide ? const SidebarDrawerContent() : null,
      appBar: !isWide ? AppBar(title: const Text('Facturación')) : null,
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
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
        _buildDropdown("Cliente", "Seleccionar cliente"),
        const SizedBox(height: 14),
        _buildDropdown("Vehículo", "Seleccionar vehículo"),
        const SizedBox(height: 14),
        _buildDropdown("Tipo de factura", "Factura"),
        const SizedBox(height: 14),
        _buildDropdown("Aplicar oferta", "Ninguna"),
        const SizedBox(height: 14),
        const Text(
          "Porcentaje de descuento",
          style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Itim'),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            suffixText: "%",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
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
              // Header rojo con ID agregado
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
                    Expanded(flex: 2, child: Text("CANT.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(flex: 4, child: Text("NOMBRE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(flex: 3, child: Text("TIPO", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(flex: 2, child: Text("PRECIO", textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                    SizedBox(width: 32),
                  ],
                ),
              ),

              // Lista con scroll
              SizedBox(
                height: 260,
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  children: const [
                    FacturaItemRow(id: 1, cantidad: 1, nombre: "Cambio de aceite", tipo: "Servicio", precio: 10.00),
                    FacturaItemRow(id: 2, cantidad: 2, nombre: "Aceite de caja", tipo: "Producto", precio: 15.43),
                    FacturaItemRow(id: 3, cantidad: 1, nombre: "Refrigerante", tipo: "Servicio", precio: 25.00),
                    FacturaItemRow(id: 4, cantidad: 4, nombre: "Cambio de neumáticos", tipo: "Producto", precio: 15.00),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Totales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    _buildTotalRow("Subtotal", "\$35.43"),
                    const SizedBox(height: 4),
                    _buildTotalRow("IVA (13%)", "\$4.61"),
                    const Divider(height: 16),
                    _buildTotalRow("Total", "\$40.04", isTotal: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Procesar Factura",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Itim'),
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
              decoration: InputDecoration(
                hintText: "Buscar producto/servicio",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tabla de productos con scroll
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
                // Header fijo con ID agregado
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

                // Filas con scroll
                SizedBox(
                  height: 160,
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _buildProductRow(1, "Cambio de aceite", 10.00, "Servicio", null),
                      _buildProductRow(2, "Aceite de caja", 15.43, "Producto", 16),
                      _buildProductRow(3, "Refrigerante", 25.00, "Servicio", 33),
                      _buildProductRow(4, "Cambio de neumáticos", 15.00, "Producto", null),
                      _buildProductRow(5, "Filtro de aire", 8.50, "Producto", 12),
                      _buildProductRow(6, "Pastillas de freno", 22.00, "Producto", 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Itim')),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          items: const [],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 17 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: isTotal ? 20 : 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductRow(int id, String nombre, double precio, String tipo, int? stock) {
    final bool isServicio = tipo == "Servicio";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("#$id", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text("\$${precio.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 3, child: Text(nombre, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 1)),
          Expanded(flex: 2, child: Text(tipo, style: TextStyle(fontSize: 13, color: isServicio ? Colors.orange.shade700 : Colors.blue.shade700, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 1, child: Text(stock != null ? "$stock" : "-", textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: Colors.grey))),
        ],
      ),
    );
  }
}
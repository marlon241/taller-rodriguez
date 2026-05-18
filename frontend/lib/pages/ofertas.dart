import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';

class OfertasScreen extends StatefulWidget {
  const OfertasScreen({super.key});

  @override
  State<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen> {
  bool _mostrarExpirados = false;

  
  final List<Map<String, dynamic>> _ofertas = [
    {
      'nombre': 'Canasta de Santa Fe',
      'estado': 'Activo',
      'fechaInicio': '06.12.2025',
      'fechaVencimiento': '15.12.2025',
      'activo': true,
    },
    {
      'nombre': 'Descuento Navidad',
      'estado': 'Expirado',
      'fechaInicio': '01.12.2025',
      'fechaVencimiento': '05.12.2025',
      'activo': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: isWide ? null : AppBar(title: const Text('Ofertas')),
      drawer: isWide ? null : const SidebarDrawerContent(),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'Ofertas',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Itim',
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  isWide ? _buildWideLayout() : _buildMobileLayout(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildFormPanel()),
          const SizedBox(width: 24),
          Expanded(flex: 3, child: _buildOffersTablePanel()),
        ],
      ),
    );
  }

  
  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildFormPanel(),
          const SizedBox(height: 20),
          _buildOffersTablePanel(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormPanel() {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Agregar nueva oferta",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Itim',
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("Nombre de la oferta"),
            const SizedBox(height: 14),
            _buildTextField("Descripción", maxLines: 4),
            const SizedBox(height: 14),

            // En móvil: campos apilados; en wide: fila
            isWide
                ? Row(
                    children: [
                      Expanded(
                          child: _buildTextField("% de descuento", suffix: "%")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Producto al que aplica")),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextField("Porcentaje de descuento", suffix: "%"),
                      const SizedBox(height: 14),
                      _buildTextField("Producto al que aplica"),
                    ],
                  ),

            const SizedBox(height: 14),

            // Fechas: en móvil apiladas, en wide en fila
            isWide
                ? Row(
                    children: [
                      Expanded(child: _buildTextField("Fecha de inicio")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Fecha de vencimiento")),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextField("Fecha de inicio"),
                      const SizedBox(height: 14),
                      _buildTextField("Fecha de vencimiento"),
                    ],
                  ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Agregar Oferta",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Itim',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1, String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontFamily: 'Itim')),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            suffixText: suffix,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersTablePanel() {
    final bool isWide = MediaQuery.of(context).size.width > 1000;
    final ofertasFiltradas = _mostrarExpirados
        ? _ofertas.where((o) => !o['activo']).toList()
        : _ofertas.where((o) => o['activo']).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: isWide
                ? const Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text("Oferta",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text("Estado",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text("Fecha inicio",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text("Fecha venc.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text("Acciones",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ],
                  )
                : const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ofertas",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Itim'),
                    ),
                  ),
          ),

          
          if (ofertasFiltradas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  _mostrarExpirados
                      ? 'No hay ofertas expiradas'
                      : 'No hay ofertas activas',
                  style: const TextStyle(color: Colors.black45),
                ),
              ),
            )
          else if (isWide)
            ...ofertasFiltradas
                .map((oferta) => _buildTableRow(oferta))
                .toList()
          else
            ...ofertasFiltradas
                .map((oferta) => _buildOfferCard(oferta))
                .toList(),

          const Divider(height: 1),

          
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Mostrar expirados",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Switch(
                  value: _mostrarExpirados,
                  onChanged: (val) {
                    setState(() {
                      _mostrarExpirados = val;
                    });
                  },
                  activeColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTableRow(Map<String, dynamic> oferta) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text(oferta['nombre'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: _buildEstadoBadge(oferta['activo']),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Text(oferta['fechaInicio'],
                      textAlign: TextAlign.center)),
              Expanded(
                  flex: 2,
                  child: Text(oferta['fechaVencimiento'],
                      textAlign: TextAlign.center)),
              Expanded(
                flex: 2,
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  
  Widget _buildOfferCard(Map<String, dynamic> oferta) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      oferta['nombre'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildEstadoBadge(oferta['activo']),
                ],
              ),
              const SizedBox(height: 10),

            
              Row(
                children: [
                  Expanded(
                    child: _buildDateInfo("Inicio", oferta['fechaInicio']),
                  ),
                  Expanded(
                    child:
                        _buildDateInfo("Vencimiento", oferta['fechaVencimiento']),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Editar",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF880E4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Eliminar",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildDateInfo(String label, String fecha) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black45)),
        Text(fecha,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEstadoBadge(bool activo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: activo ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        activo ? "Activo" : "Expirado",
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Editar",
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF880E4F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Eliminar",
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
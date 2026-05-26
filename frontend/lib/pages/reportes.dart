import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  String _filtroSeleccionado = 'Este mes';
  final List<String> _filtros = ['Este mes', 'Última semana', 'Este año'];

  static const Color purple = Color(0xFF7F77DD);
  static const Color teal   = Color(0xFF1D9E75);
  static const Color gray   = Color(0xFFB4B2A9);
  static const Color coral  = Color(0xFFD85A30);
  static const Color bgPage = Color(0xFFF4F3F7);
  static const Color bgCard = Colors.white;
  static const Color border = Color(0xFFE0DCED);

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: bgPage,
      // Drawer solo en móvil/tablet
      drawer: isWide ? null : const SidebarDrawerContent(),
      // AppBar solo en móvil/tablet
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: bgPage,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: const Text(
                'Reportes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _BadgeFecha(label: 'Octubre 2025'),
                ),
              ],
            ),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar solo en escritorio
            if (isWide) const Sidebar(),
            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header solo en escritorio (en móvil va en AppBar)
                    if (isWide) ...[
                      _buildHeader(),
                      const SizedBox(height: 20),
                    ],
                    // En móvil, mostrar dropdown de filtro bajo el appbar
                    if (!isWide) ...[
                      _buildMobileFiltro(),
                      const SizedBox(height: 16),
                    ],
                    _buildKpis(),
                    const SizedBox(height: 16),
                    _buildMainRow(),
                    const SizedBox(height: 16),
                    _buildBottomRow(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Reportes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        Row(
          children: [
            _BadgeFecha(label: 'Octubre 2025'),
            const SizedBox(width: 10),
            _FiltroDropdown(
              value: _filtroSeleccionado,
              items: _filtros,
              onChanged: (v) => setState(() => _filtroSeleccionado = v!),
            ),
          ],
        ),
      ],
    );
  }

  /// Filtro compacto para móvil
  Widget _buildMobileFiltro() {
    return Row(
      children: [
        _FiltroDropdown(
          value: _filtroSeleccionado,
          items: _filtros,
          onChanged: (v) => setState(() => _filtroSeleccionado = v!),
        ),
      ],
    );
  }

  // ── KPI cards ────────────────────────────────
  Widget _buildKpis() {
    return LayoutBuilder(builder: (context, c) {
      // En móvil: 2 columnas; en escritorio: 4 columnas
      final bool mobile = c.maxWidth < 600;
      final int crossCount = mobile ? 2 : 4;
      final double spacing = 12;
      final double itemW = (c.maxWidth - spacing * (crossCount - 1)) / crossCount;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          SizedBox(width: itemW, child: _KpiCard(icon: Icons.attach_money_rounded, iconBg: const Color(0xFFEEEDFE), iconColor: const Color(0xFF534AB7), label: 'Ventas del día', value: '\$2,150', sub: '+12% vs ayer', subColor: const Color(0xFF3B6D11), subIcon: Icons.trending_up)),
          SizedBox(width: itemW, child: _KpiCard(icon: Icons.storefront_outlined, iconBg: const Color(0xFFEAF3DE), iconColor: const Color(0xFF3B6D11), label: 'Inventario', value: '245 prod.', sub: '3 en stock bajo', subColor: const Color(0xFF854F0B), subIcon: Icons.warning_amber_rounded)),
          SizedBox(width: itemW, child: _KpiCard(icon: Icons.account_balance_wallet_outlined, iconBg: const Color(0xFFE1F5EE), iconColor: const Color(0xFF0F6E56), label: 'Saldo en caja', value: '\$2,030', sub: 'Base \$500 · Egr. \$620', subColor: Colors.grey)),
          SizedBox(width: itemW, child: _KpiCard(icon: Icons.directions_car_outlined, iconBg: const Color(0xFFFAECE7), iconColor: const Color(0xFF993C1D), label: 'Vehículos taller', value: '10 activos', sub: '2 listos p/entrega', subColor: Colors.grey)),
        ],
      );
    });
  }

  // ── Fila principal (gráfica + caja) ──────────
  Widget _buildMainRow() {
    return LayoutBuilder(builder: (context, c) {
      final bool wide = c.maxWidth > 600;
      if (wide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildVentasMesCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildCajaCard()),
          ],
        );
      }
      return Column(children: [
        _buildVentasMesCard(),
        const SizedBox(height: 16),
        _buildCajaCard(),
      ]);
    });
  }

  Widget _buildVentasMesCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Ventas del mes'),
          _LegendRow(items: const [
            _LegendItem(color: purple, label: 'Productos'),
            _LegendItem(color: teal,   label: 'Servicios'),
            _LegendItem(color: gray,   label: 'Otros'),
          ]),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: _VentasBarChart()),
        ],
      ),
    );
  }

  Widget _buildCajaCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Estado de caja'),
          _StatusRow(label: 'Estado', trailing: _Pill(label: 'Abierta', bg: const Color(0xFFEAF3DE), fg: const Color(0xFF27500A))),
          _StatusRow(label: 'Base inicial',  value: '\$500.00'),
          _StatusRow(label: 'Ingresos',      value: '\$2,150.00', valueColor: const Color(0xFF3B6D11)),
          _StatusRow(label: 'Egresos',       value: '\$620.00',   valueColor: const Color(0xFFA32D2D)),
          const Divider(color: border, height: 20),
          _StatusRow(label: 'Saldo actual', value: '\$2,030.00', bold: true),
          const SizedBox(height: 12),
          const Text('Desglose ingresos', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          _MiniBar(label: 'Productos', fraction: 0.58, color: purple, amount: '\$1,250'),
          _MiniBar(label: 'Servicios', fraction: 0.37, color: teal,   amount: '\$800'),
          _MiniBar(label: 'Otros',     fraction: 0.05, color: gray,   amount: '\$100'),
        ],
      ),
    );
  }

  // ── Fila inferior (vehículos + inventario + donut) ──
  Widget _buildBottomRow() {
    return LayoutBuilder(builder: (context, c) {
      final bool wide = c.maxWidth > 600;
      if (wide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildVehiculosCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildInventarioCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildDonutCard()),
          ],
        );
      }
      return Column(children: [
        _buildVehiculosCard(),
        const SizedBox(height: 16),
        _buildInventarioCard(),
        const SizedBox(height: 16),
        _buildDonutCard(),
      ]);
    });
  }

  Widget _buildVehiculosCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Vehículos en taller'),
          _MiniBar(label: 'En diagnóstico', fraction: 0.30, color: purple, amount: '3'),
          _MiniBar(label: 'En reparación',  fraction: 0.50, color: coral,  amount: '5'),
          _MiniBar(label: 'Listos entrega', fraction: 0.20, color: teal,   amount: '2'),
          const SizedBox(height: 8),
          _StatusRow(
            label: 'Tiempo promedio',
            value: '2.5 días',
            icon: Icons.access_time_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInventarioCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Inventario'),
          _StatusRow(label: 'Total productos', value: '245'),
          _StatusRow(label: 'Valor total',     value: '\$28,750'),
          _StatusRow(label: 'Nuevos este mes', value: '15'),
          const SizedBox(height: 10),
          Row(children: const [
            Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFF854F0B)),
            SizedBox(width: 4),
            Text('Stock bajo', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          const SizedBox(height: 6),
          _AlertItem(label: 'Pastillas de freno',  cantidad: '3 uds.'),
          _AlertItem(label: 'Aceite transmisión',  cantidad: '2 uds.'),
          _AlertItem(label: 'Filtro de aire',       cantidad: '4 uds.'),
        ],
      ),
    );
  }

  Widget _buildDonutCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Ventas por categoría'),
          SizedBox(height: 160, child: _DonutChart()),
          const SizedBox(height: 8),
          _LegendRow(items: const [
            _LegendItem(color: purple, label: 'Prod. 58%'),
            _LegendItem(color: teal,   label: 'Serv. 37%'),
            _LegendItem(color: gray,   label: 'Otros 5%'),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GRÁFICA DE BARRAS — fl_chart
// ─────────────────────────────────────────────
class _VentasBarChart extends StatelessWidget {
  static const purple = Color(0xFF7F77DD);
  static const teal   = Color(0xFF1D9E75);
  static const gray   = Color(0xFFB4B2A9);

  final List<String> semanas = const ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];

  final List<List<double>> data = const [
    [980,  1250, 1100, 1400],
    [600,  800,  750,  900 ],
    [80,   100,  90,   120 ],
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 2600,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (v, _) => Text(
                '\$${v.toInt()}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              interval: 500,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= semanas.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(semanas[i],
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                );
              },
            ),
          ),
          rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(semanas.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(toY: data[0][i], color: purple, width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
              BarChartRodData(toY: data[1][i], color: teal,   width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
              BarChartRodData(toY: data[2][i], color: gray,   width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DONUT — fl_chart
// ─────────────────────────────────────────────
class _DonutChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 45,
        sections: [
          PieChartSectionData(value: 58, color: const Color(0xFF7F77DD), radius: 40, showTitle: false),
          PieChartSectionData(value: 37, color: const Color(0xFF1D9E75), radius: 40, showTitle: false),
          PieChartSectionData(value: 5,  color: const Color(0xFFB4B2A9), radius: 40, showTitle: false),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGETS DE APOYO
// ─────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0DCED), width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label, value, sub;
  final Color subColor;
  final IconData? subIcon;

  const _KpiCard({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.label, required this.value, required this.sub,
    required this.subColor, this.subIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0DCED), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(children: [
            if (subIcon != null) ...[
              Icon(subIcon, size: 12, color: subColor),
              const SizedBox(width: 2),
            ],
            Flexible(child: Text(sub, style: TextStyle(fontSize: 11, color: subColor))),
          ]),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;
  final Color valueColor;
  final bool bold;
  final IconData? icon;

  const _StatusRow({
    required this.label,
    this.value,
    this.trailing,
    this.valueColor = Colors.black87,
    this.bold = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: Colors.grey),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: bold ? Colors.black87 : Colors.grey,
                    fontWeight: bold ? FontWeight.w500 : FontWeight.normal)),
          ]),
          if (trailing != null) trailing!,
          if (value != null)
            Text(value!,
                style: TextStyle(
                    fontSize: bold ? 15 : 13,
                    fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
                    color: valueColor)),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double fraction;
  final Color color;
  final String amount;

  const _MiniBar({required this.label, required this.fraction, required this.color, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: const Color(0xFFF0EEF8),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String label, cantidad;
  const _AlertItem({required this.label, required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF633806))),
          _Pill(label: cantidad, bg: const Color(0xFFFAEEDA), fg: const Color(0xFF633806)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Pill({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: fg.withOpacity(0.3), width: 0.5)),
      child: Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
    );
  }
}

class _BadgeFecha extends StatelessWidget {
  final String label;
  const _BadgeFecha({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF3C3489)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF3C3489))),
      ]),
    );
  }
}

class _FiltroDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _FiltroDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC9C2E8), width: 0.5),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: false,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final List<_LegendItem> items;
  const _LegendRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: items,
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }
}
import 'package:flutter/material.dart';

class VisualizarVehiculoModal extends StatelessWidget {
  final Map<String, dynamic> vehiculo;

  const VisualizarVehiculoModal({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    final urlImagenVehiculo = vehiculo['url_imagen_vehiculo'] as String?;
    final urlTarjeta = vehiculo['url_tarjeta_circulacion'] as String?;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Detalles del Vehículo",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Info principal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del vehículo
                  Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: urlImagenVehiculo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              urlImagenVehiculo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.directions_car,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : const Icon(Icons.directions_car, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(width: 20),

                  // Datos básicos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehiculo['marca']} ${vehiculo['modelo']}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _infoRow(Icons.confirmation_number, 'Placa', vehiculo['placa'] ?? '-'),
                        _infoRow(Icons.calendar_today, 'Año', '${vehiculo['anio'] ?? '-'}'),
                        _infoRow(Icons.info_outline, 'Estado', vehiculo['estado'] ?? '-'),
                        _infoRow(Icons.login, 'Ingreso', _formatFecha(vehiculo['fecha_ingreso'])),
                        _infoRow(Icons.logout, 'Salida', _formatFecha(vehiculo['fecha_salida'])),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Diagnóstico
              if (vehiculo['diagnostico'] != null && vehiculo['diagnostico'].toString().isNotEmpty) ...[
                const Text('Diagnóstico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Text(
                    vehiculo['diagnostico'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Tarjeta de circulación
              if (urlTarjeta != null) ...[
                const Text('Tarjeta de Circulación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    urlTarjeta,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Botón cerrar
              Center(
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cerrar', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Itim')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFC0392B)),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return '-';
    final dt = DateTime.tryParse(fecha.toString());
    if (dt == null) return '-';
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${dt.day.toString().padLeft(2, '0')} ${meses[dt.month - 1]} ${dt.year}';
  }
}
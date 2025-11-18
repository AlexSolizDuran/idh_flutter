import 'package:flutter/material.dart';
import 'package:restauran/models/pedido.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;

  const PedidoCard({super.key, required this.pedido});

  // Helper para obtener el color del estado
  Color _getStatusColor() {
    // Usamos los estados de tu 'flujo_delivery.md'
    switch (pedido.estadoPedido.toUpperCase()) {
      case 'ENTREGADO':
        return Colors.green[700]!;
      case 'EN_CAMINO_AL_CLIENTE':
      case 'EN_CAMINO_AL_RESTAURANTE':
      case 'BUSCANDO_REPARTIDOR':
        return Colors.blue[700]!;
      case 'LISTO_PARA_RECOGER':
        return Colors.orange[700]!;
      case 'CANCELADO':
        return Colors.red[700]!;
      default: // PENDIENTE_CONFIRMACION, EN_PREPARACION, etc.
        return Colors.grey[700]!;
    }
  }

  // Helper para el color del borde
  Color _getBorderColor() {
    switch (pedido.estadoPedido.toUpperCase()) {
      case 'ENTREGADO':
        return Colors.green;
      case 'EN_CAMINO_AL_CLIENTE':
      case 'EN_CAMINO_AL_RESTAURANTE':
      case 'BUSCANDO_REPARTIDOR':
        return Colors.blue;
      case 'LISTO_PARA_RECOGER':
        return Colors.orange;
      case 'CANCELADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: _getBorderColor(), width: 6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${pedido.pedidoId}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${pedido.montoTotal.toStringAsFixed(2)} BOB',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Color del monto
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // --- ESTA ES LA LÍNEA ACTUALIZADA ---
              Text(
                'Cliente: ${pedido.cliente.nombreTelegram ?? "ID: ${pedido.cliente.telegramUserId}"}',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              // --- FIN DE LA ACTUALIZACIÓN ---
              const SizedBox(height: 4),
              Text(
                'Direccion: ${pedido.direccionEntrega}',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Estado: ',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    pedido.estadoPedido, // Usamos el estado real
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

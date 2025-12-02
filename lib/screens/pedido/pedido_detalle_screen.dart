import 'package:flutter/material.dart';
import 'package:restauran/models/pedido.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PedidoDetalleScreen extends StatelessWidget {
  final Pedido pedido;

  const PedidoDetalleScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    // Simulamos los datos que faltan en el modelo, como en la captura
    final String puntos = (pedido.estadoPedido == 'ENTREGADO') ? '10' : '0';
    final String tiempo = (pedido.estadoPedido == 'ENTREGADO')
        ? '25 Minutos'
        : 'N/A';

    // Intentamos parsear la descripción del pedido
    final List<String> productos = pedido.descripcionPedido
        .split(',')
        .map((e) => e.trim())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resumen Pedido',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'PEDIDO # ${pedido.pedidoId}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Nombre',
                  pedido.cliente.nombreTelegram ?? 'N/A',
                ),
                _buildInfoCard('Direccion', pedido.direccionEntrega),

                if (pedido.latitudCliente != null &&
                    pedido.longitudCliente != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("Ver Ubicación Cliente en Mapa"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Color azul mapa
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final lat = pedido.latitudCliente;
                        final lon = pedido.longitudCliente;
                        // URL universal para abrir Google Maps / Waze / Maps en iOS
                        final url = Uri.parse(
                          "https://www.google.com/maps/search/?api=1&query=$lat,$lon",
                        );

                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No se pudo abrir el mapa"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                _buildInfoCard(
                  'Fecha',
                  DateFormat('dd / MM / yyyy').format(pedido.fechaCreacion),
                ),
                _buildInfoCard('Puntos', puntos), // Dato simulado
                _buildInfoCard('Tiempo', tiempo), // Dato simulado
                const SizedBox(height: 24),
                Text(
                  'PRODUCTOS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildProductosCard(context, productos, pedido.montoTotal),
              ],
            ),
          ),
          _buildReportButton(context),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  // Widget para las tarjetas de información (Nombre, Dirección, etc.)
  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la tarjeta roja de "Productos"
  Widget _buildProductosCard(
    BuildContext context,
    List<String> productos,
    double total,
  ) {
    return Card(
      elevation: 2,
      color: Colors.redAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Lista de productos (parseados del string)
            ...productos
                .map(
                  (producto) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // No podemos saber el precio individual, solo el texto
                        Text(
                          producto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            const Divider(color: Colors.white54, height: 24),
            // Fila del Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} Bs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para el botón "Reportar Problema"
  Widget _buildReportButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Lógica para reportar un problema
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Función "Reportar Problema" no implementada.'),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[400], // Color de la captura
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'REPORTAR PROBLEMA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

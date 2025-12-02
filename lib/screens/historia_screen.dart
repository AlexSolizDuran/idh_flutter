import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran/models/pedido.dart';
import 'package:restauran/providers/auth_provider.dart';
import 'package:restauran/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:restauran/screens/pedido/pedido_detalle_screen.dart';
import 'package:restauran/services/unauthorized_exception.dart';

class HistoriaScreen extends StatefulWidget {
  const HistoriaScreen({super.key});

  @override
  State<HistoriaScreen> createState() => _HistoriaScreenState();
}

class _HistoriaScreenState extends State<HistoriaScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Pedido>>? _historialFuture;

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  void _handleUnauthorized() {
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  void _loadHistorial() {
    setState(() {
      // Usamos el endpoint correcto que devuelve TODOS los pedidos
      _historialFuture = _fetchHistorial('/repartidor/me/pedidos');
    });
  }

  Future<List<Pedido>> _fetchHistorial(String endpoint) async {
    try {
      final data = await _apiService.get(endpoint);
      final pedidos =
          (data as List).map((item) => Pedido.fromJson(item)).toList();

      // Ordenar por fecha de creación descendente
      pedidos.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      return pedidos;
    } on UnauthorizedException {
      _handleUnauthorized();
      return [];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el historial: $e')),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Carreras'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue[600]),
            onPressed: _loadHistorial,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadHistorial(),
        child: FutureBuilder<List<Pedido>>(
          future: _historialFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Error al cargar el historial.'),
                    ElevatedButton(
                      onPressed: _loadHistorial,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final historial = snapshot.data!;
              return _buildHistorialList(historial);
            } else {
              return const Center(
                child: Text(
                  'No tienes pedidos en tu historial.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
          },
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildHistorialList(List<Pedido> historial) {
    return ListView(
      children: [
        _buildStatsGrid(),
        _buildTableHeader(),
        // 2. Pasamos el 'context' para poder navegar
        ...historial.map((pedido) => _buildTableRow(context, pedido)).toList(),
      ],
    );
  }

  // --- Widgets de la UI ---

  Widget _buildStatsGrid() {
    // Datos de placeholder (simulados)
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.0,
      padding: const EdgeInsets.all(12.0),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildStatsCard('Puntos', '70/100', Colors.green),
        _buildStatsCard('Total Puntos', '9.584', Colors.blue),
        _buildStatsCard('Viajes Mes', '77', Colors.blue),
        _buildStatsCard('Total Viajes', '779', Colors.blue),
        _buildStatsCard('Venta Diaria', '789 Bs', Colors.orange),
        _buildStatsCard('Total Venta', '42.123 Bs', Colors.orange),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.teal[400],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Fecha',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Num',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Pts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Monto',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Tiempo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Recibimos el context aquí
  Widget _buildTableRow(BuildContext context, Pedido pedido) {
    // Datos simulados para Pts y Tiempo (ya que el backend no los tiene aún)
    final String puntos = (pedido.estadoPedido == 'ENTREGADO') ? '5' : '0';
    final String tiempo =
        (pedido.estadoPedido == 'ENTREGADO') ? '00:15:20' : '00:00:00';
    final bool isEvenRow = (pedido.pedidoId % 2 == 0);

    // 4. Envolvemos en InkWell para detectar el toque
    return InkWell(
      onTap: () {
        // 5. Navegamos a la pantalla de detalle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PedidoDetalleScreen(pedido: pedido),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isEvenRow ? Colors.white : Colors.grey[50],
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ), // Línea separadora sutil
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                DateFormat('dd/MM/yyyy').format(pedido.fechaCreacion),
              ),
            ),
            Expanded(flex: 2, child: Text(pedido.pedidoId.toString())),
            Expanded(flex: 1, child: Text(puntos)),
            Expanded(
              flex: 3,
              child: Text(pedido.montoTotal.toStringAsFixed(2)),
            ),
            Expanded(flex: 3, child: Text(tiempo)),
          ],
        ),
      ),
    );
  }
}

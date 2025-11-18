import 'package:flutter/material.dart';
import 'package:restauran/models/pedido.dart';
import 'package:restauran/models/repartidor.dart';
import 'package:restauran/services/api_service.dart';

// Modelo combinado para los datos de la pantalla
class PrincipalData {
  final Repartidor repartidor;
  final Pedido? pedidoActivo;

  PrincipalData({required this.repartidor, this.pedidoActivo});
}

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final ApiService _apiService = ApiService();
  Future<PrincipalData>? _dataFuture;
  bool _isLoadingToggle = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<PrincipalData> _fetchData() async {
    try {
      // 1. Obtener los datos del repartidor (siempre debe funcionar)
      final repartidorData = await _apiService.get('/repartidor/me');
      final repartidor = Repartidor.fromJson(repartidorData);

      // 2. Intentar obtener el pedido activo
      Pedido? pedidoActivo;
      try {
        final pedidoData = await _apiService.get('/repartidor/pedidos/activo');
        pedidoActivo = Pedido.fromJson(pedidoData);
      } catch (e) {
        // Si el error es 404, significa que no hay pedido activo.
        // Lo ignoramos y dejamos pedidoActivo = null
        if (!e.toString().contains('404')) {
          rethrow; // Lanzar otros errores (ej. 500)
        }
      }

      return PrincipalData(repartidor: repartidor, pedidoActivo: pedidoActivo);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      rethrow;
    }
  }

  Future<void> _updateStatus(bool isDisponible) async {
    setState(() {
      _isLoadingToggle = true;
    });
    try {
      final nuevoEstado = isDisponible ? 'disponible' : 'no_disponible';
      await _apiService.put('/repartidor/status', {
        'estado_disponibilidad': nuevoEstado,
      });
      _loadData(); // Recargar todos los datos
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar estado: $e')));
    } finally {
      setState(() {
        _isLoadingToggle = false;
      });
    }
  }

  Future<void> _handleAction(String action, int pedidoId) async {
    try {
      await _apiService.post('/pedidos/$action/$pedidoId');
      _loadData(); // Recargar el estado del pedido
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al realizar la acción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PrincipalData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error al cargar los datos.'),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final repartidor = data.repartidor;
            final pedidoActivo = data.pedidoActivo;
            final isDisponible =
                repartidor.estadoDisponibilidad == 'disponible';

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView(
                children: [
                  _buildHeader(repartidor.nombreCompleto, isDisponible),
                  _buildStatsCards(),
                  if (pedidoActivo != null)
                    _buildActiveOrder(pedidoActivo)
                  else
                    _buildNoOrderFound(repartidor.estadoDisponibilidad),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No se encontraron datos.'));
          }
        },
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildHeader(String nombre, bool isDisponible) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hola, ${nombre.split(' ').first}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Puntos', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                      '70/100',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    LinearProgressIndicator(value: 0.7, color: Colors.green),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viajes Mes',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '77',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Para alinear con el progress bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrder(Pedido pedido) {
    // Lógica simple de temporizador (esto debería ser más robusto en producción)
    final tiempoTranscurrido = DateTime.now().difference(pedido.fechaCreacion);
    final minutos = tiempoTranscurrido.inMinutes;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pedido #${pedido.pedidoId}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.redAccent, size: 20),
                          SizedBox(width: 4),
                          Text(
                            '$minutos min',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    'Cliente: ${pedido.cliente.nombreTelegram ?? "N/A"}',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dirección: ${pedido.direccionEntrega}',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(pedido),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Marcador de posición del Mapa
          Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 250,
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 50, color: Colors.grey[600]),
                    Text(
                      'Marcador de posición del Mapa',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOrderFound(String estadoRepartidor) {
    bool isDisponible = estadoRepartidor == 'disponible';
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              isDisponible ? Icons.search : Icons.pause_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isDisponible ? 'Buscando pedidos...' : 'Estás desconectado',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isDisponible
                  ? 'Se te notificará cuando haya un nuevo pedido disponible.'
                  : 'Activa el interruptor "En Línea" para empezar a recibir pedidos.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Pedido pedido) {
    // Estos son los mismos botones de tu código original, ahora en la pantalla principal
    switch (pedido.estadoPedido) {
      case 'BUSCANDO_REPARTIDOR': // Asignado, esperando aceptación
        return Column(
          children: [
            ElevatedButton(
              onPressed: () => _handleAction('aceptar', pedido.pedidoId),
              child: const Text('Aceptar Pedido'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _handleAction('rechazar', pedido.pedidoId),
              child: const Text('Rechazar Pedido'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        );
      case 'EN_CAMINO_AL_RESTAURANTE':
        return ElevatedButton(
          onPressed: () => _handleAction('recoger', pedido.pedidoId),
          child: const Text('He recogido el Pedido'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
        );
      case 'EN_CAMINO_AL_CLIENTE':
        return ElevatedButton(
          onPressed: () => _handleAction('completar', pedido.pedidoId),
          child: const Text('He entregado el Pedido'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
        );
      default:
        return Text(
          'Estado: ${pedido.estadoPedido}',
          textAlign: TextAlign.center,
        );
    }
  }
}

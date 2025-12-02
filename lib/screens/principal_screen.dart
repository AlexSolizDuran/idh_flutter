import 'package:flutter/material.dart';
import 'package:restauran/models/pedido.dart';
import 'package:restauran/models/repartidor.dart';
import 'package:restauran/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart'; // <--- Agregar
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:restauran/screens/pedido/pedido_detalle_screen.dart'; // <--- AGREGAR

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
  Timer? _timer; // <--- Variable para el timer

  Pedido? _pedidoActual;
  @override
  void initState() {
    super.initState();
    _loadData();
    // Iniciar el polling cada 2 segundos
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // CONDICIÓN: Si ya tengo un pedido y NO estoy solo "buscando" (o sea, ya lo acepté),
      // entonces NO recargo automáticamente.
      if (_pedidoActual != null &&
          _pedidoActual!.estadoPedido != 'BUSCANDO_REPARTIDOR') {
        return;
      }

      _loadDataSilencioso();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // <--- IMPORTANTE: Cancelar al salir
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<void> _loadDataSilencioso() async {
    try {
      final repartidorData = await _apiService.get('/repartidor/me');
      final repartidor = Repartidor.fromJson(repartidorData);

      Pedido? pedidoActivo;
      try {
        final pedidoData = await _apiService.get('/repartidor/pedidos/activo');
        pedidoActivo = Pedido.fromJson(pedidoData);
      } catch (e) {
        /* 404 ignorado */
      }

      // --- ACTUALIZAR VARIABLE DE CONTROL ---
      _pedidoActual = pedidoActivo;
      // -------------------------------------

      if (mounted) {
        setState(() {
          _dataFuture = Future.value(
            PrincipalData(repartidor: repartidor, pedidoActivo: pedidoActivo),
          );
        });
      }
    } catch (e) {
      print("Error polling: $e");
    }
  }

  Future<PrincipalData> _fetchData() async {
    try {
      final repartidorData = await _apiService.get('/repartidor/me');
      final repartidor = Repartidor.fromJson(repartidorData);

      Pedido? pedidoActivo;
      try {
        final pedidoData = await _apiService.get('/repartidor/pedidos/activo');
        pedidoActivo = Pedido.fromJson(pedidoData);
      } catch (e) {
        if (!e.toString().contains('404')) {
          rethrow;
        }
      }

      // --- ACTUALIZAR VARIABLE DE CONTROL ---
      _pedidoActual = pedidoActivo;
      // -------------------------------------

      return PrincipalData(repartidor: repartidor, pedidoActivo: pedidoActivo);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }

  Future<void> _updateStatus(bool isDisponible) async {
    setState(() {
      _isLoadingToggle = true;
    });

    try {
      // A. OBTENER POSICIÓN ACTUAL (Real o Fake GPS)
      // Esto pedirá permisos si no los tiene
      Position position = await _determinePosition();
      print(
        "📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}",
      );

      final nuevoEstado = isDisponible ? 'disponible' : 'no_disponible';

      // B. ENVIAR AL BACKEND CON COORDENADAS
      await _apiService.put('/repartidor/status', {
        'estado_disponibilidad': nuevoEstado,
        'latitud': position.latitude, // <--- CAMPO CLAVE
        'longitud': position.longitude, // <--- CAMPO CLAVE
      });

      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error GPS/API: $e')));
      // Opcional: Si falla, podrías revertir el switch visualmente aquí
    } finally {
      setState(() {
        _isLoadingToggle = false;
      });
    }
  }

  // --- FUNCIÓN AUXILIAR REQUERIDA POR GEOLOCATOR ---
  // Copia y pega esto también dentro de tu clase _PrincipalScreenState
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si el GPS está encendido
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('El GPS está desactivado. Actívalo para continuar.');
    }

    // 2. Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Permisos denegados permanentemente. Habilítalos en Ajustes.',
      );
    }

    // 3. Obtener ubicación (Alta precisión para que el Fake GPS funcione bien)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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
            // Usamos Clip.antiAlias para que el efecto de tinta respete los bordes redondeados
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              // --- AQUÍ ESTÁ LA MAGIA: NAVEGACIÓN AL DETALLE ---
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PedidoDetalleScreen(pedido: pedido),
                  ),
                );
              },
              // ------------------------------------------------
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
                            const Icon(
                              Icons.timer,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$minutos min',
                              style: const TextStyle(
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
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dirección: ${pedido.direccionEntrega}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    // Nota visual para indicar que es clickeable
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Ver detalles >",
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildActionButtons(pedido),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // === REEMPLAZAR DESDE AQUÍ ===
          if (pedido.latitudCliente != null && pedido.longitudCliente != null)
            Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 250, // Altura del mapa
                child: FlutterMap(
                  options: MapOptions(
                    // Centramos el mapa en la ubicación del CLIENTE
                    initialCenter: LatLng(
                      pedido.latitudCliente!,
                      pedido.longitudCliente!,
                    ),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.restauran',
                    ),
                    MarkerLayer(
                      markers: [
                        // Marcador del CLIENTE (Destino)
                        Marker(
                          point: LatLng(
                            pedido.latitudCliente!,
                            pedido.longitudCliente!,
                          ),
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        // Opcional: Podrías agregar otro marcador para el REPARTIDOR (tu ubicación actual)
                        // si tienes acceso a la variable 'position' aquí.
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            // Mensaje si el pedido no tiene ubicación (por ejemplo, pedidos viejos)
            Card(
              elevation: 2,
              color: Colors.grey[200],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text("Este pedido no tiene ubicación de mapa."),
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

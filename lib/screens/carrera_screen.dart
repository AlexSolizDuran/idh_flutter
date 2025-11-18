import 'package:flutter/material.dart';
import 'package:restauran/models/pedido.dart';
import 'package:restauran/services/api_service.dart';
import 'package:restauran/widgets/pedido_card.dart'; // Importar el nuevo widget

class CarreraScreen extends StatefulWidget {
  const CarreraScreen({super.key});

  @override
  State<CarreraScreen> createState() => _CarreraScreenState();
}

class _CarreraScreenState extends State<CarreraScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Pedido>>? _pedidosFuture;
  bool _isEnLinea = false; // Estado para el toggle
  bool _isLoadingToggle = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Carga tanto el estado del repartidor como la lista de pedidos
  void _loadAllData() {
    _loadRepartidorStatus();
    _loadPedidos();
  }

  // Carga la lista de pedidos
  void _loadPedidos() {
    setState(() {
      _pedidosFuture = _fetchPedidos();
    });
  }

  // Carga el estado "En Linea"
  Future<void> _loadRepartidorStatus() async {
    try {
      final data = await _apiService.get('/repartidor/me');
      setState(() {
        _isEnLinea = data['estado_disponibilidad'] == 'disponible';
      });
    } catch (e) {
      // Manejo de error silencioso para el estado
      print('Error al cargar estado: $e');
    }
  }

  // Llama al nuevo endpoint que devuelve una LISTA
  Future<List<Pedido>> _fetchPedidos() async {
    try {
      final data = await _apiService.get('/repartidor/me/pedidos');
      // 'data' es ahora una List<dynamic>
      List<Pedido> pedidos = (data as List)
          .map((pedidoJson) => Pedido.fromJson(pedidoJson))
          .toList();
      return pedidos;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar historial: $e')));
      return []; // Retorna lista vacía en caso de error
    }
  }

  // Cambia el estado "En Linea"
  Future<void> _toggleEnLinea(bool value) async {
    setState(() {
      _isLoadingToggle = true;
    });
    try {
      final nuevoEstado = value ? 'disponible' : 'no_disponible';
      await _apiService.put('/repartidor/status', {
        'estado_disponibilidad': nuevoEstado,
      });
      setState(() {
        _isEnLinea = value;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cambiar estado: $e')));
    } finally {
      setState(() {
        _isLoadingToggle = false;
      });
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
          Row(
            children: [
              const Text('En Linea'),
              Switch(
                value: _isEnLinea,
                onChanged: _isLoadingToggle ? null : _toggleEnLinea,
                activeColor: Colors.green,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAllData,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Pedidos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pedido>>(
              future: _pedidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: _loadPedidos,
                      child: const Text('Reintentar'),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final pedidos = snapshot.data!;
                  return ListView.builder(
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      return PedidoCard(pedido: pedidos[index]);
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      'No se encontraron pedidos.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

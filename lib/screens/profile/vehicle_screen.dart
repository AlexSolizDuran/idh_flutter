import 'package:flutter/material.dart';
import 'package:restauran/models/vehiculo.dart'; // ¡Necesitarás crear este modelo!
import 'package:restauran/services/api_service.dart';
import 'package:restauran/utils/app_theme_color.dart';

class VehicleScreen extends StatefulWidget {
  VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  Future<Vehiculo>? _vehicleFuture;
  bool _isSaving = false;

  // Controladores
  late TextEditingController _placaController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _colorController;
  late TextEditingController _tipoController;

  @override
  void initState() {
    super.initState();
    _placaController = TextEditingController();
    _marcaController = TextEditingController();
    _modeloController = TextEditingController();
    _colorController = TextEditingController();
    _tipoController = TextEditingController();

    // Carga los datos iniciales
    _vehicleFuture = _fetchVehicle();
  }

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  Future<Vehiculo> _fetchVehicle() async {
    try {
      final data = await _apiService.get('/repartidor/vehiculo');
      final vehiculo = Vehiculo.fromJson(data);

      // Inicializa los controladores con los datos cargados
      _placaController.text = vehiculo.placa;
      _marcaController.text = vehiculo.marca ?? '';
      _modeloController.text = vehiculo.modelo ?? '';
      _colorController.text = vehiculo.color ?? '';
      _tipoController.text = vehiculo.tipo;

      return vehiculo;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar vehículo: $e')));
      }
      rethrow;
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // El body debe coincidir con tu schema 'VehiculoUpdate'
      final Map<String, dynamic> data = {
        'placa': _placaController.text,
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'color': _colorController.text,
        'tipo': _tipoController.text,
      };

      await _apiService.put('/repartidor/vehiculo', data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehículo actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final misColores = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Vehículo'),
        backgroundColor: misColores.primario,
      ),
      body: FutureBuilder<Vehiculo>(
        future: _vehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _vehicleFuture = _fetchVehicle();
                  });
                },
                child: const Text('Reintentar'),
              ),
            );
          } else if (snapshot.hasData) {
            // Si los datos cargaron, muestra el formulario
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _placaController,
                    decoration: const InputDecoration(
                      labelText: 'Placa (Matrícula)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pin),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo requerido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.factory),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.color_lens),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tipoController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo (ej. motocicleta)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.motorcycle),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _saveVehicle,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: misColores.acento,
                          ),
                          child: Text(
                            'Actualizar Informacion',
                            style: TextStyle(
                              color: Colors
                                  .white, // <--- CAMBIA 'blue' POR EL COLOR QUE QUIERAS
                              fontSize:
                                  20, // Opcional: Para cambiar el tamaño de la fuente
                              fontWeight: FontWeight
                                  .bold, // Opcional: Para ponerlo en negrita
                            ),
                          ),
                        ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No se encontró vehículo.'));
          }
        },
      ),
    );
  }
}

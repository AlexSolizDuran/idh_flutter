import 'package:flutter/material.dart';
import 'package:restauran/models/repartidor.dart';
import 'package:restauran/services/api_service.dart';
import 'package:restauran/utils/app_theme_color.dart';

class EditProfileScreen extends StatefulWidget {
  final Repartidor repartidor; // Recibe el repartidor de la pantalla anterior

  const EditProfileScreen({super.key, required this.repartidor});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los datos actuales
    _nombreController = TextEditingController(
      text: widget.repartidor.nombreCompleto,
    );
    _telefonoController = TextEditingController(
      text: widget.repartidor.telefono,
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // No hacer nada si el formulario no es válido
    }

    setState(() => _isLoading = true);

    try {
      // El body debe coincidir con tu schema 'RepartidorUpdate' en la API
      final Map<String, dynamic> data = {
        'nombre_completo': _nombreController.text,
        'telefono': _telefonoController.text,
      };

      await _apiService.put('/repartidor/me', data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        // Regresa a la pantalla anterior
        Navigator.pop(
          context,
          true,
        ); // Devuelve 'true' para indicar que se actualizó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final misColores = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Mi Perfil'),
        backgroundColor: misColores.primario,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre no puede estar vacío';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // El email no se edita, se muestra como solo lectura
            TextFormField(
              initialValue: widget.repartidor.email,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveProfile,
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
      ),
    );
  }
}

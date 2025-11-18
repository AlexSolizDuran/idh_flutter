import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran/providers/auth_provider.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  // Variables de estado para los interruptores
  bool _alertaNuevosPedidos = true;
  bool _sonidoAlerta = true;
  bool _modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Sección de Notificación ---
          _buildSectionHeader('Notificacion'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias, // Para que los ListTiles se recorten
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                  title: Text('Alerta de Nuevos Pedidos'),
                  value: _alertaNuevosPedidos,
                  onChanged: (bool value) {
                    setState(() {
                      _alertaNuevosPedidos = value;
                      // Aquí guardarías la preferencia (ej. SharedPreferences)
                    });
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: Icon(
                    Icons.volume_up_outlined,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                  title: const Text('Sonido de Alerta'),
                  value: _sonidoAlerta,
                  onChanged: (bool value) {
                    setState(() {
                      _sonidoAlerta = value;
                      // Aquí guardarías la preferencia
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Sección de Aplicación ---
          _buildSectionHeader('Aplicacion'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.brightness_6_outlined,
                    color: Colors.grey[700],
                  ),
                  title: const Text('Modo Oscuro'),
                  value: _modoOscuro,
                  onChanged: (bool value) {
                    setState(() {
                      _modoOscuro = value;
                      // Aquí cambiarías el tema de la app
                    });
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey[700]),
                  title: const Text('Version de la App'),
                  trailing: const Text(
                    '1.2.3', // Como en la captura
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  // Helper para los títulos de sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Diálogo de confirmación para cerrar sesión
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                // Llama al provider para hacer logout
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
                // El AuthProvider se encargará de navegar a la pantalla de Login
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran/models/repartidor.dart';
import 'package:restauran/providers/auth_provider.dart'; // Importa tu AuthProvider
import 'package:restauran/services/api_service.dart';
import 'package:restauran/screens/profile/edit_profile_screen.dart';
import 'package:restauran/screens/profile/vehicle_screen.dart';
import 'package:restauran/services/unauthorized_exception.dart';
import 'package:restauran/utils/app_theme_color.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ApiService _apiService = ApiService();
  Future<Repartidor>? _repartidorFuture;

  @override
  void initState() {
    super.initState();
    _loadRepartidorData();
  }

  void _handleUnauthorized() {
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  void _loadRepartidorData() {
    setState(() {
      _repartidorFuture = _fetchRepartidor();
    });
  }

  Future<Repartidor> _fetchRepartidor() async {
    try {
      final data = await _apiService.get('/repartidor/me');
      return Repartidor.fromJson(data);
    } on UnauthorizedException {
      _handleUnauthorized();
      rethrow;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el perfil: $e')),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos los colores aquí para un acceso fácil
    final misColores = Theme.of(context).extension<AppThemeColors>()!;
    const double fontSize = 25;
    const Color colorFondo = Color(0xFFF2F2F2); // Un gris claro para el fondo
    // Amarillo de los botones
    const Color colorBotonRojo = Color(0xFFF44336); // Rojo para cerrar sesión
    const Color colorTextoGris = Color(0xFF4A4A4A);

    return Scaffold(
      // 1. Sin AppBar y con color de fondo
      backgroundColor: colorFondo,
      body: FutureBuilder<Repartidor>(
        future: _repartidorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error al cargar el perfil.'),
                  ElevatedButton(
                    onPressed: _loadRepartidorData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final repartidor = snapshot.data!;
            // 2. Usamos SingleChildScrollView para evitar desbordes
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60), // Espacio para la barra de estado
                  // 3. Cabecera del Perfil
                  _buildProfileHeaderCard(repartidor),
                  const SizedBox(height: 30),

                  // 4. Sección "Cuenta"
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 10),
                    child: Text(
                      'Cuenta',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: colorTextoGris,
                      ),
                    ),
                  ),
                  _buildOptionButton(
                    icon: Icons.person_outline,
                    text: 'Mi Perfil',
                    color: misColores.secundario,
                    onPressed: () {
                      // --- ESTA ES LA NAVEGACIÓN ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Pasa el objeto 'repartidor' que ya tienes
                          builder: (context) =>
                              EditProfileScreen(repartidor: repartidor),
                        ),
                      ).then((seActualizo) {
                        // Opcional: Si el perfil se guardó, refresca los datos
                        if (seActualizo == true) {
                          _loadRepartidorData();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOptionButton(
                    icon: Icons.motorcycle_outlined,
                    text: 'Mi Vehiculo',
                    color: misColores.secundario,
                    onPressed: () {
                      // --- ESTA ES LA NAVEGACIÓN ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Esta pantalla carga sus propios datos
                          builder: (context) => VehicleScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // 5. Sección "Soporte"
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 10),
                    child: Text(
                      'Soporte',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorTextoGris,
                      ),
                    ),
                  ),
                  _buildOptionButton(
                    icon: Icons.help_outline,
                    text: 'Ayuda',
                    color: misColores.secundario,
                    onPressed: () {
                      // TODO: Navegar a la pantalla de ayuda
                    },
                  ),
                  const SizedBox(height: 40),

                  // 6. Botón de Cerrar Sesión
                  _buildLogoutButton(context, color: colorBotonRojo),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No se encontraron datos.'));
          }
        },
      ),
    );
  }

  // Widget para la cabecera (Avatar, Nombre, ID)
  Widget _buildProfileHeaderCard(Repartidor repartidor) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              // URL del avatar de la imagen de ejemplo
              backgroundImage: NetworkImage(
                'https://i.postimg.cc/Qt8B1f1y/avatar-placeholder.png',
              ),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repartidor.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Nota: La imagen muestra un ID de texto, pero tu modelo tiene un ID numérico.
                // Lo formateamos para que se parezca.
                Text(
                  'ID: #${repartidor.repartidorId}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                // Nota: Tu modelo 'Repartidor' no tiene 'rating' ni 'viajes'.
                // Si los añades en el futuro, irían aquí.
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los botones de opción (amarillos)
  Widget _buildOptionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: const Color(0xFFFFFFFF), // Color del texto e icono
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Color(0xFFFFFFFF)),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  // Widget para el botón de cerrar sesión
  Widget _buildLogoutButton(BuildContext context, {required Color color}) {
    // Obtenemos el AuthProvider para poder llamar a logout()
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ElevatedButton(
      onPressed: () {
        // Llama al método logout de tu provider
        authProvider.logout();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white, // Color del texto
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Center(
        child: Text(
          'Cerrar Sesión',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

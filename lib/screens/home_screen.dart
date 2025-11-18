import 'package:flutter/material.dart';
import 'package:restauran/screens/principal_screen.dart';
import 'package:restauran/screens/carrera_screen.dart';
import 'package:restauran/screens/historia_screen.dart';
import 'package:restauran/screens/perfil_screen.dart';
import 'package:restauran/screens/ajustes_screen.dart';
import 'package:restauran/utils/app_theme_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  static const List<Widget> _widgetOptions = <Widget>[
    PerfilScreen(),
    CarreraScreen(),
    PrincipalScreen(),
    HistoriaScreen(),
    AjustesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final misColores = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      appBar: AppBar(
        // 3. Este es el título que se verá siempre
        title: const Text('Título de la App'),

        // 4. Usa tu color personalizado como fondo
        // (Asegúrate de que 'miColorMarca' sea el nombre correcto de tu variable)
        backgroundColor: misColores.primario,

        // 5. (Opcional) Asegura que el texto del título sea legible
        foregroundColor: Colors.white,

        // 6. (Opcional) Quita la sombra si prefieres un look plano
        elevation: 4.0,
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 40),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 40),
            label: 'Carrera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 40),
            label: 'Principal',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 40),
            label: 'Historia',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 40),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

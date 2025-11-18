import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran/providers/auth_provider.dart';
import 'package:restauran/screens/home_screen.dart';
import 'package:restauran/screens/login_screen.dart';
import 'package:restauran/utils/app_theme_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Restauran App',

        // --- TEMA CLARO (LIGHT) ---
        theme: ThemeData(
          brightness: Brightness.light, // Define que este es el tema claro
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true, // Recomendado para estilos modernos
          // Aquí añades tus colores personalizados para el modo claro
          extensions: <ThemeExtension<dynamic>>[
            const AppThemeColors(
              primario: Color(0xFFFF4B3E),
              secundario: Color(0xFFFFC43D),
              acento: Color(0xFF2EC4B6), // Tu verde principal
            ),
          ],
        ),

        // --- TEMA OSCURO (DARK) ---
        darkTheme: ThemeData(
          brightness: Brightness.dark, // Define que este es el tema oscuro
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true, // Recomendado
          // Aquí defines TUS MISMAS variables, pero con valores para modo oscuro
          extensions: <ThemeExtension<dynamic>>[
            const AppThemeColors(
              primario: Color(0xFFFF4B3E),
              secundario: Color(0xFFFFC43D),
              acento: Color(0xFF2EC4B6), // Un verde más claro
            ),
          ],
        ),

        // --- MODO DE TEMA ---
        // 'system' hace que la app cambie automáticamente
        // entre 'theme' y 'darkTheme' según la configuración del teléfono.
        themeMode: ThemeMode.system,

        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

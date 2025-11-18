// lib/utils/app_theme_colors.dart
import 'package:flutter/material.dart';

// 1. Define tu clase de extensión de tema
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color primario;
  final Color secundario;
  final Color acento;

  const AppThemeColors({
    required this.primario,
    required this.secundario,
    required this.acento,
  });

  // --- Esto es "boilerplate" (código repetitivo) necesario ---
  // Flutter lo usa para animar entre temas
  @override
  AppThemeColors copyWith({Color? primario, Color? secundario, Color? acento}) {
    return AppThemeColors(
      primario: primario ?? this.primario,
      secundario: secundario ?? this.secundario,
      acento: acento ?? this.acento,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      primario: primario,
      secundario: secundario,
      acento: acento,
    );
  }

  // --- Fin del boilerplate ---
}

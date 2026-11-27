import 'package:flutter/material.dart';

/// Paleta de colores para el modo oscuro de Ica Tours
/// Mantiene Verde Oasis y Arena Dorada como acentos
class AppDarkColors {
  AppDarkColors._();

  /// Verde Oasis - Se mantiene como color primario
  static const Color primary = Color(0xFF176B63);

  /// Arena Dorada - Elementos secundarios
  static const Color secondary = Color(0xFFE8B86D);

  /// Fondo oscuro principal
  static const Color background = Color(0xFF1A1A2E);

  /// Fondo secundario (tarjetas, superficies)
  static const Color surface = Color(0xFF16213E);

  /// Fondo terciario (campos de texto, elementos elevados)
  static const Color surfaceVariant = Color(0xFF0F3460);

  /// Texto principal en modo oscuro
  static const Color textPrimary = Color(0xFFE8E8E8);

  /// Texto secundario en modo oscuro
  static const Color textSecondary = Color(0xFFA0A0A0);

  /// Borde sutil para campos y contenedores
  static const Color border = Color(0xFF2A2A4A);

  /// Sombra en modo oscuro
  static const Color shadow = Color(0xFF0D0D1A);
}

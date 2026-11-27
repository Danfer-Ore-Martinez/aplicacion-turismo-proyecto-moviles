import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto centralizados para la aplicación Ica Tours
/// Tipografía: Roboto (fuente por defecto de Material Design)
class AppTextStyles {
  AppTextStyles._(); // Constructor privado

  /// Título principal - 24 sp, negrita
  static const TextStyle titleMain = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Título de sección - 20 sp, seminegrita
  static const TextStyle titleSection = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Título de tarjeta - 16 sp, seminegrita
  static const TextStyle titleCard = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Texto general - 14 a 16 sp, regular
  static const TextStyle bodyText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Texto secundario - 12 a 14 sp, regular
  static const TextStyle secondaryText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Texto sobre imágenes (blanco) - para overlay en tarjetas
  static const TextStyle overlayTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );

  /// Texto sobre imágenes secundario (blanco)
  static const TextStyle overlaySubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.surface,
  );

  /// Texto blanco para AppBar
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );

  /// Estilo para mensaje de "no resultados"
  static const TextStyle noResults = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
}

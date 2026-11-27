import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'app_dark_colors.dart';

/// Key para guardar la preferencia de tema en SharedPreferences
const String _themePrefKey = 'is_dark_mode';

/// Provider que gestiona el estado del tema (claro/oscuro)
/// y persiste la preferencia del usuario con SharedPreferences
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoaded => _isLoaded;

  /// Carga la preferencia de tema guardada al iniciar la app
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themePrefKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _isLoaded = true;
    notifyListeners();
  }

  /// Alterna entre modo claro y oscuro, y guarda la preferencia
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  /// Tema claro de la aplicación
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: AppColors.surface,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Tema oscuro de la aplicación
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppDarkColors.primary,
      scaffoldBackgroundColor: AppDarkColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppDarkColors.primary,
        secondary: AppDarkColors.secondary,
        surface: AppDarkColors.surface,
        onPrimary: AppDarkColors.textPrimary,
        onSecondary: AppDarkColors.textPrimary,
        onSurface: AppDarkColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppDarkColors.surface,
        foregroundColor: AppDarkColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppDarkColors.surface,
        selectedItemColor: AppDarkColors.secondary,
        unselectedItemColor: AppDarkColors.textSecondary,
      ),
      cardTheme: CardThemeData(
        color: AppDarkColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppDarkColors.border),
        ),
        filled: true,
        fillColor: AppDarkColors.surfaceVariant,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDarkColors.primary,
          foregroundColor: AppDarkColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppDarkColors.textPrimary),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppDarkColors.textPrimary),
        bodySmall: TextStyle(color: AppDarkColors.textSecondary),
        titleLarge: TextStyle(color: AppDarkColors.textPrimary),
        titleMedium: TextStyle(color: AppDarkColors.textPrimary),
      ),
    );
  }
}

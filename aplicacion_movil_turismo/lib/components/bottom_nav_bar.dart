import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_dark_colors.dart';
import '../core/text_styles.dart';

/// Barra de navegación inferior con 5 secciones
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: isDark ? AppDarkColors.surface : AppColors.surface,
      selectedItemColor: isDark ? AppDarkColors.secondary : AppColors.primary,
      unselectedItemColor: isDark
          ? AppDarkColors.textSecondary.withValues(alpha: 0.5)
          : AppColors.textPrimary.withValues(alpha: 0.5),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTextStyles.secondaryText.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        color: isDark ? AppDarkColors.secondary : AppColors.primary,
      ),
      unselectedLabelStyle: AppTextStyles.secondaryText.copyWith(
        fontSize: 11,
        color: isDark
            ? AppDarkColors.textSecondary.withValues(alpha: 0.5)
            : AppColors.textPrimary.withValues(alpha: 0.5),
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Destinos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Mi viaje',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.luggage_outlined),
          activeIcon: Icon(Icons.luggage),
          label: 'Viajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}

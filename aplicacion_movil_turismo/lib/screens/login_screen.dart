import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_dark_colors.dart';
import '../core/text_styles.dart';
import '../core/theme_provider.dart';
import 'home_screen.dart';

/// Pantalla de login básico (sin autenticación real)
/// Sirve como punto de entrada antes de mostrar la pantalla principal
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          userName: _nameController.text.trim().isEmpty
              ? 'Viajero'
              : _nameController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Ícono principal
              const SizedBox(height: 40),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.landscape,
                  color: AppColors.surface,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              // Título de la app
              Text(
                'Ica Tours',
                style: (isDark
                        ? AppTextStyles.titleMain.copyWith(
                            fontSize: 32,
                            color: AppDarkColors.textPrimary,
                          )
                        : AppTextStyles.titleMain)
                    .copyWith(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre los atractivos turísticos de Ica',
                style: AppTextStyles.secondaryText.copyWith(
                  color: isDark
                      ? AppDarkColors.textSecondary
                      : AppColors.textPrimary.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Campo de nombre
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppDarkColors.surfaceVariant
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppDarkColors.shadow : Colors.black)
                          .withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? AppDarkColors.border
                        : AppColors.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: isDark
                          ? AppDarkColors.secondary
                          : AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: AppTextStyles.bodyText.copyWith(
                          color: isDark
                              ? AppDarkColors.textPrimary
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu nombre',
                          hintStyle: AppTextStyles.secondaryText.copyWith(
                            color: isDark
                                ? AppDarkColors.textSecondary
                                : AppColors.textPrimary
                                    .withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _onLogin(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Botón de ingreso
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ingresar',
                    style: AppTextStyles.titleCard.copyWith(
                      color: AppColors.surface,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Texto inferior
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Explora Ica con nosotros 🌵',
                  style: AppTextStyles.secondaryText.copyWith(
                    color: isDark
                        ? AppDarkColors.textSecondary
                        : AppColors.textPrimary.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

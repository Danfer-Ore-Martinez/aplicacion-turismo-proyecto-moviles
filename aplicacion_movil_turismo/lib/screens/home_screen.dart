import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_dark_colors.dart';
import '../core/text_styles.dart';
import '../core/theme_provider.dart';
import '../models/destination_model.dart';
import '../services/api_service.dart';
import '../components/destination_card.dart';
import '../components/custom_search_bar.dart';
import '../components/bottom_nav_bar.dart';

/// Pantalla principal de la aplicación
/// Muestra la lista de destinos turísticos de Ica con búsqueda
class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Destination> _destinos = [];
  List<Destination> _filteredDestinos = [];
  bool _isLoading = true;       // Solo para la carga inicial
  bool _isSearching = false;    // Para búsquedas (no oculta el buscador)
  Timer? _debounce;             // Evita llamadas excesivas a la API

  @override
  void initState() {
    super.initState();
    _cargarDestinos();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Carga los destinos desde la API (o datos de respaldo si falla)
  Future<void> _cargarDestinos() async {
    setState(() {
      _isLoading = true;
    });

    final destinos = await ApiService.getDestinos();
    if (!mounted) return;
    setState(() {
      _destinos = destinos;
      _filteredDestinos = destinos;
      _isLoading = false;
    });
  }

  /// Filtra los destinos con debounce para no saturar la API
  void _buscarDestinos(String query) {
    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _filteredDestinos = _destinos;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Espera 400ms después de la última tecla antes de buscar
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final resultados = await ApiService.getDestinos(buscar: query);
      if (!mounted) return;
      setState(() {
        _filteredDestinos = resultados;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppDarkColors.background : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppDarkColors.surface : AppColors.primary,
        foregroundColor:
            isDark ? AppDarkColors.textPrimary : AppColors.surface,
        elevation: 0,
        title: Text(
          'Ica Tours',
          style: isDark
              ? AppTextStyles.appBarTitle.copyWith(
                  color: AppDarkColors.textPrimary,
                )
              : AppTextStyles.appBarTitle,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              size: 24,
            ),
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildPlaceholder('Destinos', Icons.explore),
          _buildPlaceholder('Mi viaje', Icons.map),
          _buildPlaceholder('Viajes', Icons.luggage),
          _buildPlaceholder('Perfil', Icons.person),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  /// Contenido de la pestaña Inicio
  Widget _buildHomeTab() {
    // Carga inicial: mostrar loading en toda la pantalla
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    // Una vez cargado, el buscador y encabezado SIEMPRE están visibles
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de sección
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'Tours',
            style: AppTextStyles.titleSection,
          ),
        ),
        // Barra de búsqueda (siempre visible)
        CustomSearchBar(
          hintText: 'Buscar destino...',
          onChanged: _buscarDestinos,
        ),
        // Área de resultados
        Expanded(
          child: _isSearching
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : _filteredDestinos.isEmpty
                  ? _buildNoResultsWidget()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemCount: _filteredDestinos.length,
                      itemBuilder: (context, index) {
                        final destino = _filteredDestinos[index];
                        return DestinationCard(destination: destino);
                      },
                    ),
        ),
      ],
    );
  }

  /// Widget que se muestra cuando no hay resultados de búsqueda
  Widget _buildNoResultsWidget() {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDark ? AppDarkColors.secondary : AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay destinos disponibles',
              style: AppTextStyles.titleCard.copyWith(
                color: isDark
                    ? AppDarkColors.textPrimary.withValues(alpha: 0.7)
                    : AppColors.textPrimary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro término de búsqueda',
              style: AppTextStyles.secondaryText.copyWith(
                color: isDark
                    ? AppDarkColors.textSecondary
                    : AppColors.textPrimary.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder para las secciones que desarrollarán los compañeros
  Widget _buildPlaceholder(String title, IconData icon) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark
                ? AppDarkColors.secondary.withValues(alpha: 0.4)
                : AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.titleSection.copyWith(
              color: isDark
                  ? AppDarkColors.textPrimary.withValues(alpha: 0.5)
                  : AppColors.textPrimary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sección en desarrollo',
            style: AppTextStyles.secondaryText.copyWith(
              color: isDark
                  ? AppDarkColors.textSecondary.withValues(alpha: 0.4)
                  : AppColors.textPrimary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

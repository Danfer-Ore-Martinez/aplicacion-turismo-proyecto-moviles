import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_dark_colors.dart';
import '../core/text_styles.dart';
import '../models/destination_model.dart';

/// Tarjeta de destino turístico
/// Muestra una imagen de fondo con el nombre y actividad principal superpuestos
class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback? onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppDarkColors.shadow : Colors.black)
                  .withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo local (nombrada según el destino)
              Image.asset(
                _getImagePath(destination.nombre),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: (isDark
                            ? AppDarkColors.primary
                            : AppColors.primary)
                        .withValues(alpha: 0.1),
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: isDark
                          ? AppDarkColors.secondary
                          : AppColors.secondary,
                    ),
                  );
                },
              ),
              // Degradado oscuro en la parte inferior para legibilidad del texto
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SizedBox(height: 100),
                ),
              ),
              // Texto sobre la imagen
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination.nombre,
                      style: AppTextStyles.overlayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.actividad ?? '',
                      style: AppTextStyles.overlaySubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retorna la ruta de la imagen local según el nombre del destino
  String _getImagePath(String nombre) {
    final map = {
      'Laguna de Huacachina': 'assets/images/huacachina.jpg',
      'Parque Temático de Cachiche': 'assets/images/parque_cachiche.jpg',
      'Hacienda Tacama': 'assets/images/tacama.jpg',
      'Cañón de los Perdidos': 'assets/images/canion_perdidos.jpg',
      'Santuario del Señor de Luren': 'assets/images/luren.jpg',
      'Bosque de Piedras': 'assets/images/bosque_frailes.jpg',
      'Palmera de las 7 Cabezas': 'assets/images/palmeras.png',
      'Fiesta de la Vendimia': 'assets/images/vendimia.jpg',
      'Procesión del Señor de Luren': 'assets/images/procesion_luren.jpg',
      'Museo Adolfo Bermúdez Jenkins': 'assets/images/museo_adolfo.jpg',
      'Parque de la Palma': 'assets/images/palma.png',
    };
    return map[nombre] ?? 'assets/images/placeholder.jpg';
  }
}

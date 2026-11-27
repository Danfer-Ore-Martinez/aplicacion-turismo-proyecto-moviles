import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_dark_colors.dart';
import '../core/text_styles.dart';

/// Campo de búsqueda personalizado con estilos de la aplicación
class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Buscar destino...',
    required this.onChanged,
    this.onClear,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppDarkColors.shadow : Colors.black)
                .withValues(alpha: 0.08),
            blurRadius: 6,
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
            Icons.search,
            color: isDark ? AppDarkColors.secondary : AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: AppTextStyles.bodyText.copyWith(
                color: isDark
                    ? AppDarkColors.textPrimary
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.secondaryText.copyWith(
                  color: isDark
                      ? AppDarkColors.textSecondary
                      : AppColors.textPrimary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged('');
                widget.onClear?.call();
              },
              child: Icon(
                Icons.close,
                color: isDark
                    ? AppDarkColors.textSecondary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Caja informativa con icono, titulo y mensaje para notas contextuales del wizard.
class EstablishmentInfoCallout extends StatelessWidget {
  /// Crea una caja informativa reutilizable.
  const EstablishmentInfoCallout({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  /// Icono mostrado a la izquierda del texto.
  final IconData icon;

  /// Titulo destacado de la nota.
  final String title;

  /// Mensaje descriptivo de la nota.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.smallEmphasis.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(message, style: AppTypography.formFieldHelper),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

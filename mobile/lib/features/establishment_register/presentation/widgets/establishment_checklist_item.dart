import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Item numerado del checklist mostrado en el estado vacío de establecimiento.
class EstablishmentChecklistItem extends StatelessWidget {
  /// Crea un item de checklist con orden, titulo y subtitulo.
  const EstablishmentChecklistItem({
    required this.order,
    required this.label,
    required this.subtitle,
    super.key,
  });

  /// Numero de orden del item.
  final int order;

  /// Titulo visible del item.
  final String label;

  /// Descripcion corta del item.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$order',
              style: AppTypography.smallEmphasis.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.mediumEmphasis.copyWith(color: AppColors.textPrimary),
                ),
                Text(subtitle, style: AppTypography.formFieldHelper),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

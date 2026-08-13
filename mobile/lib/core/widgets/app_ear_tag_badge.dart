import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Chip que reproduce visualmente una caravana física: color de plástico +
/// número visual en dos líneas.
///
/// Reutiliza el patrón que ya existía duplicado en
/// `animal_identification_summary.dart` y `registered_animal_summary_card.dart`.
class AppEarTagBadge extends StatelessWidget {
  /// Crea la caravana con el [visualTag] y el color de plástico indicados.
  const AppEarTagBadge({
    required this.visualTag,
    super.key,
    this.color = AppColors.earTagYellow,
    this.width,
  });

  /// Número visual impreso en la caravana (ej. `'003 1284'`).
  final String visualTag;

  /// Color de plástico de la caravana.
  final Color color;

  /// Ancho fijo opcional del chip.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        visualTag.replaceFirst(' ', '\n'),
        style: AppTypography.smallEmphasis.copyWith(color: AppColors.textPrimary, height: 1),
        textAlign: TextAlign.center,
      ),
    );
  }
}

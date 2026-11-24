import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_ear_tag_badge.dart';

/// Resumen de la identificación capturada en el paso anterior.
class AnimalIdentificationSummary extends StatelessWidget {
  /// Crea un resumen visual de la caravana identificada.
  const AnimalIdentificationSummary({
    required this.rfid,
    required this.visualTag,
    required this.readingDescription,
    super.key,
  });

  /// Codigo RFID completo de la caravana.
  final String rfid;

  /// Numero visual impreso en la caravana.
  final String visualTag;

  /// Descripcion de la lectura realizada.
  final String readingDescription;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, 0),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Color.alphaBlend(AppColors.earTagBlue.withValues(alpha: 0.18), AppColors.surface),
        border: Border.all(color: AppColors.earTagBlue.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          AppEarTagBadge(visualTag: visualTag, color: AppColors.earTagBlue),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rfid, style: AppTypography.monoValueEmphasis),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.xxs),
                    Flexible(child: Text(readingDescription, style: AppTypography.formFieldHelper)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

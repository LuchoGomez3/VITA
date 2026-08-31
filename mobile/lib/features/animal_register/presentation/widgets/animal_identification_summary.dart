import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

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
    return ColoredBox(
      color: AppColors.backgroundSecondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.earTagYellow,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                visualTag.replaceFirst(' ', '\n'),
                style: AppTypography.smallEmphasis.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rfid,
                    style: AppTypography.smallEmphasis.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    readingDescription,
                    style: AppTypography.smallEmphasis.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

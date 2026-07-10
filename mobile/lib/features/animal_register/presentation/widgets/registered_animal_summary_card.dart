import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Resumen del animal registrado que se muestra en la pantalla de exito.
class RegisteredAnimalSummaryCard extends StatelessWidget {
  /// Crea una tarjeta con los datos principales del animal dado de alta.
  const RegisteredAnimalSummaryCard({
    required this.visualTag,
    required this.title,
    required this.rfid,
    required this.destination,
    super.key,
  });

  /// Numero visual de la caravana.
  final String visualTag;

  /// Titulo descriptivo del animal.
  final String title;

  /// RFID asociado al animal.
  final String rfid;

  /// Destino o potrero asignado.
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.earTagYellow,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              visualTag.replaceFirst(' ', '\n'),
              style: AppTypography.smallEmphasis.copyWith(
                color: AppColors.textPrimary,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.secondaryEmphasis.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  rfid,
                  style: AppTypography.smallEmphasis.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textSecondary,
                      size: 15,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        destination,
                        style: AppTypography.smallEmphasis.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
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

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

/// Agrupa los controles humanos que validan la fotografía antes de continuar.
class ManualCaptureReviewCard extends StatelessWidget {
  /// Crea la tarjeta con el estado actual de cada comprobación.
  const ManualCaptureReviewCard({
    required this.sharpnessConfirmed,
    required this.completeAnimalConfirmed,
    required this.lateralConfirmed,
    required this.errorText,
    required this.onSharpnessChanged,
    required this.onCompleteAnimalChanged,
    required this.onLateralChanged,
    super.key,
  });

  /// Indica que el operario observó una fotografía nítida.
  final bool sharpnessConfirmed;

  /// Indica que el animal aparece completo dentro del encuadre.
  final bool completeAnimalConfirmed;

  /// Indica que la captura muestra el perfil lateral del bovino.
  final bool lateralConfirmed;

  /// Mensaje mostrado cuando falta completar alguna comprobación.
  final String? errorText;

  /// Actualiza la confirmación de nitidez.
  final ValueChanged<bool?> onSharpnessChanged;

  /// Actualiza la confirmación del encuadre completo.
  final ValueChanged<bool?> onCompleteAnimalChanged;

  /// Actualiza la confirmación del perfil lateral.
  final ValueChanged<bool?> onLateralChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      color: AppColors.surface,
      elevation: AppElevation.card,
      shadowColor: AppColors.textPrimary,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            VisionWeighingStrings.manualReviewTitle,
            style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(VisionWeighingStrings.sharpnessConfirmation, style: AppTypography.formFieldValue),
            value: sharpnessConfirmed,
            onChanged: onSharpnessChanged,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              VisionWeighingStrings.completeAnimalConfirmation,
              style: AppTypography.formFieldValue,
            ),
            value: completeAnimalConfirmed,
            onChanged: onCompleteAnimalChanged,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(VisionWeighingStrings.lateralConfirmation, style: AppTypography.formFieldValue),
            value: lateralConfirmed,
            onChanged: onLateralChanged,
          ),
          if (errorText case final String error)
            Text(
              error,
              style: AppTypography.formFieldError,
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';

/// Recordatorio alineado con el borde inferior físico del teléfono horizontal.
class LandscapeFramingReminder extends StatelessWidget {
  /// Orienta y ubica el texto según el sentido en que se giró el dispositivo.
  const LandscapeFramingReminder({required this.orientation, super.key});

  /// Orientación física usada para escoger el borde inferior.
  final DeviceOrientation orientation;

  @override
  Widget build(BuildContext context) {
    final rightSide = orientation == DeviceOrientation.landscapeRight;
    return Positioned(
      top: 0,
      bottom: 0,
      left: rightSide ? null : AppSpacing.xs,
      right: rightSide ? AppSpacing.xs : null,
      child: Center(
        child: RotatedBox(
          quarterTurns: rightSide ? 1 : 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
              child: Text(
                VisionWeighingStrings.framingReminder,
                textAlign: TextAlign.center,
                style: AppTypography.formFieldHelper.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

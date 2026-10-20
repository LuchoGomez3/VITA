import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/weighing/presentation/strings/weighing_strings.dart';

/// Pill de estado de conexión de la balanza Bluetooth.
///
/// El estado "conectada/estable" es mock fijo — ver "Explícitamente fuera de
/// alcance" en `.claude/specs/pesaje-en-manga.md`.
class WeighingConnectionPill extends StatelessWidget {
  /// Crea la pill con el nombre de la balanza mock.
  const WeighingConnectionPill({required this.scaleName, super.key});

  /// Nombre de la balanza Bluetooth mock.
  final String scaleName;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth_connected, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '$scaleName · ${WeighingStrings.scaleStableSuffix}',
              style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

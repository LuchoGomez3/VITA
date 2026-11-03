import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/weighing/presentation/mock/weighing_mock.dart';
import 'package:frontend_mayoral/features/weighing/presentation/strings/weighing_strings.dart';

/// Header común a ambas tabs de captura: cierre del flujo, caravana, RFID,
/// raza/categoría y progreso dentro del lote.
class WeighingAnimalHeader extends StatelessWidget {
  /// Crea el header con el [animal] actual y el progreso del lote.
  const WeighingAnimalHeader({
    required this.animal,
    required this.batchPosition,
    required this.onClose,
    super.key,
  });

  /// Animal mock que se está pesando.
  final WeighingAnimalMock animal;

  /// Posición actual dentro del lote mock (ver `weighingBatchTotal`).
  final int batchPosition;

  /// Callback al presionar el botón de cierre.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: WeighingStrings.closeTooltip,
              onPressed: onClose,
            ),
            const Spacer(),
            _BatchProgressChip(
              label: WeighingStrings.batchProgress(batchPosition, weighingBatchTotal),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              AppEarTagBadge(visualTag: animal.visualTag),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(animal.rfid, style: AppTypography.monoValue),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(animal.breedAndCategory, style: AppTypography.formFieldHelper),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BatchProgressChip extends StatelessWidget {
  const _BatchProgressChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        child: Text(label, style: AppTypography.smallEmphasis),
      ),
    );
  }
}

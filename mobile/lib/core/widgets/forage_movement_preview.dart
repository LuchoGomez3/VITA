import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/catalogs/forage_resource_catalog.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Resume el recurso actual y el disponible en el lote de destino.
class ForageMovementPreview extends StatelessWidget {
  /// Admite varios recursos de origen cuando se mueve un grupo.
  const ForageMovementPreview({
    required this.currentResourceCodes,
    required this.destinationResourceCode,
    super.key,
  });

  /// Códigos de los lotes de origen de los animales que se van a mover.
  final Iterable<String?> currentResourceCodes;

  /// Código vigente en el lote elegido como destino.
  final String? destinationResourceCode;

  @override
  Widget build(BuildContext context) {
    final current = currentResourceCodes.map(ForageResourceCatalog.displayNameFor).toSet().join(', ');
    final destination = ForageResourceCatalog.displayNameFor(destinationResourceCode);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundPositiveContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Forraje del lote', style: AppTypography.smallEmphasis),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _Resource(label: 'Actual', name: current),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.primary),
                ),
                Expanded(
                  child: _Resource(label: 'Destino', name: destination),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Resource extends StatelessWidget {
  const _Resource({required this.label, required this.name});

  final String label;
  final String name;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.formFieldHelper),
      Text(name, style: AppTypography.mediumEmphasis.copyWith(color: AppColors.positiveText)),
    ],
  );
}

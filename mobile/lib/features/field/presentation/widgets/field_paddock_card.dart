import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/presentation/mock/paddock_mock.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Card de un potrero en la lista, con barra de color por densidad.
class FieldPaddockCard extends StatelessWidget {
  /// Crea la card de un potrero.
  const FieldPaddockCard({required this.paddock, required this.onTap, super.key});

  /// Potrero representado.
  final Paddock paddock;

  /// Acción disparada al tocar la card.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: paddock.density.color),
                child: const SizedBox(width: 6, height: 72),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(paddock.name, style: AppTypography.secondaryEmphasis),
                          ),
                          if (!paddock.isEmpty)
                            Text(
                              '${paddock.headCount} ${FieldStrings.headCountSuffix}',
                              style: AppTypography.formFieldValueEmphasis.copyWith(color: AppColors.primary),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        paddock.forage == null
                            ? '${paddock.hectares.toStringAsFixed(0)} ${FieldStrings.hectaresSuffix}'
                            : '${paddock.hectares.toStringAsFixed(0)} ${FieldStrings.hectaresSuffix} · ${paddock.forage}',
                        style: AppTypography.formFieldHelper,
                      ),
                      Text(paddock.lastMovement, style: AppTypography.formFieldHelper),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textHint),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}

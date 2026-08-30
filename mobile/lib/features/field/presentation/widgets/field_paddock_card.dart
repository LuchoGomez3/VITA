import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/field/domain/entities/forage_resource.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';

/// Tarjeta de un lote persistido localmente.
class FieldPaddockCard extends StatelessWidget {
  /// Crea la tarjeta con información productiva derivada de SQLite.
  const FieldPaddockCard({
    required this.lot,
    required this.animalCount,
    required this.onTap,
    super.key,
  });

  /// Lote representado.
  final Lot lot;

  /// Cantidad actual de animales asignados.
  final int animalCount;

  /// Abre el detalle del lote.
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
                decoration: BoxDecoration(color: _statusColor(lot.status)),
                child: const SizedBox(width: 6, height: 82),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lot.name,
                              style: AppTypography.secondaryEmphasis,
                            ),
                          ),
                          Text(
                            '$animalCount ${FieldStrings.headCountSuffix}',
                            style: AppTypography.formFieldValueEmphasis.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${lot.surfaceHectares.toStringAsFixed(1)} '
                        '${FieldStrings.hectaresSuffix} · '
                        '${InitialForageResources.displayNameFor(lot.forageResourceCode)}',
                        style: AppTypography.formFieldHelper,
                      ),
                      Text(
                        '${FieldStrings.statusName(lot.status)} · '
                        '${lot.hasWater ? FieldStrings.waterAvailable : FieldStrings.waterUnavailable}',
                        style: AppTypography.formFieldHelper,
                      ),
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

  Color _statusColor(LotStatus status) => switch (status) {
    LotStatus.active => AppColors.primary,
    LotStatus.resting => AppColors.earTagBlue,
    LotStatus.maintenance => Colors.orange,
    LotStatus.inactive || LotStatus.unknown => AppColors.textHint,
  };
}

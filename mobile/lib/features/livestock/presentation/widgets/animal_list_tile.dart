import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';

/// Fila de la lista de animales (diseño "Lista de animales").
///
/// Caravana a la izquierda; a la derecha raza · categoría, el RFID y una línea
/// con el último peso, su fecha y el potrero.
class AnimalListTile extends StatelessWidget {
  /// Crea la fila de [animal]; [onTap] abre su ficha.
  const AnimalListTile({
    required this.animal,
    required this.onTap,
    super.key,
  });

  /// Animal a mostrar.
  final AnimalListEntry animal;

  /// Acción al tocar la fila.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = [animal.breed, animal.categoryName].where((part) => part.isNotEmpty).join(' · ');
    final weight = animal.lastWeightKg;
    final weighingDate = animal.lastWeighingDate;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppEarTagBadge(visualTag: animal.visualTag),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.mediumEmphasis.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      _groupRfid(animal.rfidTagNumber),
                      style: AppTypography.monoValue.copyWith(fontSize: 11, color: AppColors.textHint),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DefaultTextStyle(
                      style: AppTypography.formFieldHelper.copyWith(color: AppColors.textSecondary),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xxxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: weight == null ? LivestockStrings.noWeight : '${_weight(weight)} kg',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                                if (weighingDate != null)
                                  TextSpan(text: ' · ${DateDisplayFormatter.shortDate(weighingDate)}'),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.place_outlined, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.xxxs),
                              Text(animal.lotName.isEmpty ? LivestockStrings.noLot : animal.lotName),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// `982000412884712` → `982 000412 884 712`, como en la caravana impresa.
  static String _groupRfid(String rfid) {
    if (rfid.length != 15) {
      return rfid;
    }
    return '${rfid.substring(0, 3)} ${rfid.substring(3, 9)} ${rfid.substring(9, 12)} ${rfid.substring(12)}';
  }

  static String _weight(double kg) => kg.toStringAsFixed(kg.truncateToDouble() == kg ? 0 : 1);
}

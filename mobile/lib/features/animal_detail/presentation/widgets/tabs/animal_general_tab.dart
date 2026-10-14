import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_formatters.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_sync_footer.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_ficha_section.dart';

/// Pestaña General (diseño "Ficha · General"): foto, identificación y
/// observaciones, más el estado de sincronización del animal.
class AnimalGeneralTab extends StatelessWidget {
  /// Crea la pestaña para [animal].
  const AnimalGeneralTab({required this.animal, required this.onRetrySync, super.key});

  /// Animal de la ficha.
  final AnimalDetail animal;

  /// Reintenta sincronizar un alta rechazada.
  final VoidCallback onRetrySync;

  @override
  Widget build(BuildContext context) {
    final observations = animal.observations;
    final coat = animal.coat;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const _PhotoPlaceholder(),
        const SizedBox(height: AppSpacing.lg),
        const AnimalFichaSectionTitle(AnimalDetailStrings.identificationSection),
        const SizedBox(height: AppSpacing.xs),
        AnimalFichaDataGroup(
          rows: [
            AnimalFichaDataRow(
              label: AnimalDetailStrings.rfidLabel,
              value: groupRfid(animal.rfidTagNumber),
              isMono: true,
            ),
            AnimalFichaDataRow(label: AnimalDetailStrings.visualTagLabel, value: animal.visualTag),
            AnimalFichaDataRow(label: AnimalDetailStrings.breedLabel, value: animal.breed),
            AnimalFichaDataRow(label: AnimalDetailStrings.sexLabel, value: animal.sex.label),
            AnimalFichaDataRow(
              label: AnimalDetailStrings.coatLabel,
              value: (coat == null || coat.isEmpty) ? AnimalDetailStrings.noDataValue : coat,
            ),
            AnimalFichaDataRow(
              label: AnimalDetailStrings.birthDateRowLabel,
              value: DateDisplayFormatter.shortDate(animal.birthDate),
            ),
            AnimalFichaDataRow(
              label: AnimalDetailStrings.calculatedAgeLabel,
              value: animal.birthDate.ageLabel(),
            ),
            AnimalFichaDataRow(
              label: AnimalDetailStrings.categoryLabel,
              value: animal.categoryName.isEmpty ? AnimalDetailStrings.noDataValue : animal.categoryName,
            ),
            AnimalFichaDataRow(
              label: AnimalDetailStrings.currentLotLabel,
              value: animal.lotName.isEmpty ? AnimalDetailStrings.noLot : animal.lotName,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const AnimalFichaSectionTitle(AnimalDetailStrings.observationsLabel),
        const SizedBox(height: AppSpacing.xs),
        AppSurfaceCard(
          child: Text(
            (observations == null || observations.isEmpty) ? AnimalDetailStrings.noDataValue : observations,
            style: AppTypography.mediumEmphasis,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimalDetailSyncFooter(animalDetail: animal, onRetry: onRetrySync),
      ],
    );
  }
}

/// Lugar de la foto del animal (diseño: "[ foto del animal ]").
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_outlined, color: AppColors.textHint),
          SizedBox(height: AppSpacing.xxs),
          Text(AnimalDetailStrings.photoPlaceholder, style: AppTypography.formFieldHelper),
        ],
      ),
    );
  }
}

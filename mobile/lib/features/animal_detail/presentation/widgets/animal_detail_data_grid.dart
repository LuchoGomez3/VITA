import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Grilla de solo lectura con los principales atributos del animal.
class AnimalDetailDataGrid extends StatelessWidget {
  /// Crea la grilla de datos del detalle de animal.
  const AnimalDetailDataGrid({
    required this.animalDetail,
    super.key,
  });

  /// Datos del animal a mostrar.
  final AnimalDetail animalDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.sexLabel,
                value: animalDetail.sex.label,
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.breedLabel,
                value: animalDetail.breed,
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.categoryLabel,
                value: animalDetail.categoryName.isEmpty ? AnimalDetailStrings.noDataValue : animalDetail.categoryName,
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.coatLabel,
                value: (animalDetail.coat?.isEmpty ?? true) ? AnimalDetailStrings.noDataValue : animalDetail.coat!,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.birthDateLabel,
                value: DateDisplayFormatter.shortDate(animalDetail.birthDate),
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.ageLabel,
                value: animalDetail.birthDate.ageLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.lastWeightLabel,
                value: animalDetail.currentWeight.displayWeight,
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.lastWeightSourceLabel,
                value: animalDetail.weighingMethod.label,
                isHighlighted: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension on AnimalSex {
  String get label => switch (this) {
    AnimalSex.male => AnimalDetailStrings.sexMale,
    AnimalSex.female => AnimalDetailStrings.sexFemale,
  };
}

extension on AnimalWeighingMethod {
  String get label => switch (this) {
    AnimalWeighingMethod.manual => AnimalDetailStrings.manualWeighingMethod,
    AnimalWeighingMethod.bluetoothScale => AnimalDetailStrings.bluetoothWeighingMethod,
    AnimalWeighingMethod.artificialIntelligence => AnimalDetailStrings.aiWeighingMethod,
  };
}

extension on DateTime {
  String get ageLabel {
    final now = DateTime.now();
    var months = (now.year - year) * 12 + now.month - month;
    if (now.day < day) {
      months -= 1;
    }
    if (months < 0) {
      return AnimalDetailStrings.noDataValue;
    }
    if (months < 12) {
      return '$months ${AnimalDetailStrings.monthsSuffix}';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) {
      return '$years ${AnimalDetailStrings.yearsSuffix}';
    }

    return '$years ${AnimalDetailStrings.yearsSuffix} $remainingMonths ${AnimalDetailStrings.monthsSuffix}';
  }
}

extension on double {
  String get displayWeight {
    if (this <= 0) {
      return AnimalDetailStrings.noDataValue;
    }

    return '${toStringAsFixed(truncateToDouble() == this ? 0 : 1)} kg';
  }
}

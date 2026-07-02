import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

/// Read-only grid with the main animal attributes.
class AnimalDetailDataGrid extends StatelessWidget {
  /// Creates the animal detail data grid.
  const AnimalDetailDataGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.breedLabel,
                value: AnimalDetailStrings.breedValue,
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.sexLabel,
                value: AnimalDetailStrings.sexValue,
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.categoryLabel,
                value: AnimalDetailStrings.categoryValue,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.birthDateLabel,
                value: AnimalDetailStrings.birthDateValue,
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.ageLabel,
                value: AnimalDetailStrings.ageValue,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.lastWeightLabel,
                value: AnimalDetailStrings.lastWeightValue,
              ),
            ),
            Expanded(
              child: AppInfoCell(
                label: AnimalDetailStrings.lastWeightSourceLabel,
                value: AnimalDetailStrings.lastWeightSourceValue,
                isHighlighted: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

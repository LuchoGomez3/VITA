import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/presentation/mock/paddock_mock.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/field_paddock_mosaic.dart';

/// Ficha de un potrero: KPIs, forraje y servicios, composición del rodeo e
/// historial de ocupación.
class FieldDetailPage extends StatelessWidget {
  /// Crea la ficha de detalle a partir del id de potrero recibido por ruta.
  const FieldDetailPage({required this.potreroId, super.key});

  /// Id del potrero mostrado (ver `paddocksMock`).
  final String potreroId;

  @override
  Widget build(BuildContext context) {
    final paddock = paddocksMock.firstWhere(
      (p) => p.id == potreroId,
      orElse: () => paddocksMock.first,
    );
    final density = paddock.isEmpty ? 0.0 : paddock.headCount / paddock.hectares;
    final hasFullDetail = paddock.id == 'la-loma';

    return Scaffold(
      appBar: AppBar(title: Text(paddock.name)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  SizedBox(
                    height: 140,
                    child: FieldPaddockMosaic(paddocks: [paddock]),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppInfoCell(
                          label: FieldStrings.headCountDetailLabel,
                          value: '${paddock.headCount}',
                        ),
                      ),
                      Expanded(
                        child: AppInfoCell(
                          label: FieldStrings.surfaceDetailLabel,
                          value: '${paddock.hectares.toStringAsFixed(0)} ${FieldStrings.hectaresSuffix}',
                        ),
                      ),
                      Expanded(
                        child: AppInfoCell(
                          label: FieldStrings.densityDetailLabel,
                          value:
                              '${density.toStringAsFixed(1).replaceAll('.', ',')} ${FieldStrings.densityUnit}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppSectionHeader(
                    title: FieldStrings.forageSectionTitle,
                    subtitle: paddock.forage ?? FieldStrings.densityNone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInfoCell(
                    label: FieldStrings.forageResourceLabel,
                    value: paddock.forage ?? '—',
                  ),
                  if (hasFullDetail) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const AppInfoCell(
                      label: FieldStrings.waterSourceLabel,
                      value: FieldStrings.waterSourceValue,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const AppInfoCell(
                      label: FieldStrings.lastRotationLabel,
                      value: FieldStrings.lastRotationValue,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            FieldStrings.animalsSectionTitle(paddock.headCount),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        const Text(
                          FieldStrings.viewAnimalsLink,
                          style: AppTypography.inlinePrimaryLink,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final (label, count) in laLomaComposition)
                          AppStatusChip(label: '$label · $count'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      FieldStrings.occupationHistoryTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final (range, value) in laLomaOccupationHistory)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(range, style: AppTypography.formFieldHelper),
                            Text(value, style: AppTypography.mediumEmphasis),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppFilledButton(
                label: FieldStrings.moveAnimalsCta,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fuera de alcance de esta iniciativa')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

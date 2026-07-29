import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_asset_icon.dart';

/// Muestra los cuatro valores principales del inventario en una grilla compacta.
class HomeKpiSummaryGrid extends StatelessWidget {
  /// Crea la grilla con el resumen actual del tablero.
  const HomeKpiSummaryGrid({required this.dashboard, super.key});

  /// Fuente de valores productivos para las tarjetas.
  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: [
        _KpiCard(
          label: HomeStrings.activeStock,
          value: '${dashboard.activeAnimals}',
          helper: HomeStrings.animalsUnit,
          assetPath: 'assets/icons/cow.svg',
        ),
        _KpiCard(
          label: HomeStrings.knownLiveWeight,
          value: '${dashboard.knownLiveWeightKg.toStringAsFixed(0)} kg',
          helper: '${dashboard.animalsWithCurrentWeight} ${HomeStrings.withWeight}',
          assetPath: 'assets/icons/scale.svg',
        ),
        _KpiCard(
          label: HomeStrings.monthlyAdditions,
          value: '${dashboard.monthlyAdditions}',
          helper: HomeStrings.currentMonth,
          assetPath: 'assets/icons/add.svg',
        ),
        _KpiCard(
          label: HomeStrings.monthlyRemovals,
          value: '${dashboard.monthlyRemovals}',
          helper: HomeStrings.currentMonth,
          assetPath: 'assets/icons/close.svg',
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.assetPath,
  });

  final String label;
  final String value;
  final String helper;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeAssetIcon(assetPath: assetPath),
          const Spacer(),
          Text(value, style: AppTypography.bigTitle),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.mediumEmphasis,
          ),
          Text(
            helper,
            style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

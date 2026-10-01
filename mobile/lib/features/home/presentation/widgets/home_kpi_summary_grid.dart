import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_asset_icon.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_daily_gain_card.dart';

/// Muestra stock activo y ganancia diaria en dos columnas de igual ancho.
class HomeKpiSummaryGrid extends StatelessWidget {
  /// Crea la grilla con el resumen actual del tablero.
  const HomeKpiSummaryGrid({required this.dashboard, super.key});

  /// Fuente de valores productivos para las tarjetas.
  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final stockCard = _KpiCard(
      label: HomeStrings.activeStock,
      value: '${dashboard.activeAnimals}',
      helper: HomeStrings.animalsUnit,
      assetPath: 'assets/icons/cow.svg',
    );
    final gainCard = HomeDailyGainCard(dashboard: dashboard);

    // Iguala el alto según el contenido, manteniendo ambos KPI lado a lado.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: stockCard),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: gainCard),
        ],
      ),
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
      // Mantiene la misma profundidad visual que las tarjetas de gastos.
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeAssetIcon(assetPath: assetPath),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.bigTitle),
          Text(
            label,
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

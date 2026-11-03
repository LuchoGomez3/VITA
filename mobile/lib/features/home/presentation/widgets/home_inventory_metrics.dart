import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';

/// Agrupa altas y bajas para comparar los movimientos del mismo período.
class HomeMonthlyMovementsCard extends StatelessWidget {
  /// Crea el resumen mensual del inventario.
  const HomeMonthlyMovementsCard({required this.dashboard, super.key});

  /// Fuente de las cantidades de altas y bajas.
  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomeStrings.monthlyMovements,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MovementMetric(
                  label: HomeStrings.monthlyAdditions,
                  value: dashboard.monthlyAdditions,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MovementMetric(
                  label: HomeStrings.monthlyRemovals,
                  value: dashboard.monthlyRemovals,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Presenta una cantidad con su etiqueta sin depender del color para distinguirla.
class _MovementMetric extends StatelessWidget {
  const _MovementMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: AppTypography.bigTitle),
        Text(label, style: AppTypography.mediumEmphasis),
      ],
    );
  }
}

/// Acompaña el peso acumulado con su cobertura para no sugerir un total completo.
class HomeLiveWeightCard extends StatelessWidget {
  /// Crea el indicador de peso disponible del rodeo.
  const HomeLiveWeightCard({required this.dashboard, super.key});

  /// Fuente del peso registrado y del total de animales activos.
  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomeStrings.knownLiveWeight,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            dashboard.animalsWithCurrentWeight == 0
                ? HomeStrings.noData
                : '${dashboard.knownLiveWeightKg.toStringAsFixed(0)} kg',
            style: AppTypography.bigTitle,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            HomeStrings.weightCoverage(dashboard.animalsWithCurrentWeight, dashboard.activeAnimals),
            style: AppTypography.smallEmphasis.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

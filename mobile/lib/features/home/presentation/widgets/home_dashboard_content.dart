import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_category_metrics_card.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_daily_gain_card.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_kpi_summary_grid.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_lot_metrics_card.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_operating_balance_card.dart';

/// Organiza las secciones visibles cuando los KPIs terminaron de calcularse.
class HomeDashboardContent extends StatelessWidget {
  /// Crea el contenido desplazable del tablero.
  const HomeDashboardContent({required this.dashboard, super.key});

  /// Indicadores listos para representar en pantalla.
  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<HomeDashboardCubit>().load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.xl,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const HomeOperatingBalanceCard(),
          const SizedBox(height: AppSpacing.lg),
          Text(HomeStrings.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(HomeStrings.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          HomeKpiSummaryGrid(dashboard: dashboard),
          const SizedBox(height: AppSpacing.md),
          HomeDailyGainCard(dashboard: dashboard),
          const SizedBox(height: AppSpacing.md),
          HomeLotMetricsCard(lots: dashboard.lots),
          const SizedBox(height: AppSpacing.md),
          HomeCategoryMetricsCard(categories: dashboard.categories),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_category_metrics_card.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_inventory_metrics.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_kpi_summary_grid.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_lot_metrics_card.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_operating_balance_card.dart';
import 'package:go_router/go_router.dart';

/// Organiza las secciones visibles cuando los KPIs terminaron de calcularse.
class HomeDashboardContent extends StatelessWidget {
  /// Crea el contenido desplazable del tablero.
  const HomeDashboardContent({
    required this.dashboard,
    required this.onEstablishmentSelectionRequested,
    required this.canViewFinancialInformation,
    super.key,
  });

  /// Indicadores listos para representar en pantalla.
  final HomeDashboard dashboard;

  /// Abre el selector superior cuando una accion requiere establecimiento.
  final VoidCallback onEstablishmentSelectionRequested;

  /// Oculta toda la informacion financiera para roles no autorizados.
  final bool canViewFinancialInformation;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<HomeDashboardCubit>().load,
      child: ListView(
        // El espacio seguro viaja con la lista: permite ver contenido detrás
        // de la barra y deja la última tarjeta accesible al terminar el scroll.
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (canViewFinancialInformation) ...[
            HomeOperatingBalanceCard(
              dashboard: dashboard,
              onRegisterExpense: () => _openExpenses(context, AppRoutes.expenseRegister),
              onRegisterIncome: () => context.push(AppRoutes.incomeRegister),
              onViewMovements: () => _openExpenses(context, AppRoutes.expenseRecords),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(HomeStrings.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          HomeKpiSummaryGrid(dashboard: dashboard),
          const SizedBox(height: AppSpacing.sm),
          HomeMonthlyMovementsCard(dashboard: dashboard),
          const SizedBox(height: AppSpacing.sm),
          HomeLiveWeightCard(dashboard: dashboard),
          const SizedBox(height: AppSpacing.sm),
          HomeLotMetricsCard(lots: dashboard.lots),
          const SizedBox(height: AppSpacing.sm),
          HomeCategoryMetricsCard(categories: dashboard.categories),
        ],
      ),
    );
  }

  void _openExpenses(BuildContext context, String path) {
    final state = context.read<HomeDashboardCubit>().state;
    final id = state.selectedEstablishmentId;
    if (id == null) {
      onEstablishmentSelectionRequested();
      return;
    }
    context.push(
      AppRoutes.expensesForEstablishment(
        path: path,
        establishmentId: id,
        establishmentName: state.establishments[id]?.name ?? id,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_asset_icon.dart';
import 'package:go_router/go_router.dart';

/// Resume el balance operativo y ofrece accesos a sus movimientos.
///
/// Los importes son temporales hasta que stock, ingresos y egresos cuenten con
/// sus fuentes de datos definitivas.
class HomeOperatingBalanceCard extends StatelessWidget {
  /// Crea el bloque superior del balance operativo.
  const HomeOperatingBalanceCard({
    required this.onEstablishmentSelectionRequested,
    super.key,
  });

  /// Solicita desplegar el selector de establecimientos del encabezado.
  final VoidCallback onEstablishmentSelectionRequested;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevation: 6,
      shadowColor: const Color(0x33000000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            HomeStrings.operatingBalance,
            style: AppTypography.pageTitle,
          ),
          Text(
            _formatBalance(context),
            style: AppTypography.balanceValue,
          ),
          const SizedBox(height: AppSpacing.md),
          const _BalanceRow(
            label: HomeStrings.estimatedStock,
            value: HomeStrings.mockStockValue,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BalanceRow(
            label: HomeStrings.operatingExpenses,
            value: _formatExpenses(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          _OperatingActions(
            onEstablishmentSelectionRequested: onEstablishmentSelectionRequested,
          ),
        ],
      ),
    );
  }

  String _formatExpenses(BuildContext context) {
    final dashboard = context.watch<HomeDashboardCubit>().state.dashboardState;
    final cents = dashboard is Data<HomeDashboard> ? dashboard.data.operatingExpensesCents : 0;
    return '- ${_currency(cents)}';
  }

  String _formatBalance(BuildContext context) => _formatExpenses(context);

  String _currency(int cents) {
    final whole = cents ~/ 100;
    final grouped = whole.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return '\$ $grouped,${(cents % 100).toString().padLeft(2, '0')}';
  }
}

/// Distribuye los accesos compactos de ingreso, egreso y movimientos.
class _OperatingActions extends StatelessWidget {
  const _OperatingActions({
    required this.onEstablishmentSelectionRequested,
  });

  final VoidCallback onEstablishmentSelectionRequested;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableButtonSize = (constraints.maxWidth - AppSpacing.sm * 2) / 3;
        final buttonSize = availableButtonSize > 83 ? 83.0 : availableButtonSize;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _OperatingActionButton(
              size: buttonSize,
              label: HomeStrings.registerExpense,
              assetPath: 'assets/icons/money_send.svg',
              onPressed: () => _openExpenses(context, AppRoutes.expenseRegister),
            ),
            const SizedBox(width: AppSpacing.md),
            _OperatingActionButton(
              size: buttonSize,
              label: HomeStrings.registerIncome,
              assetPath: 'assets/icons/money_receive.svg',
              onPressed: () => context.push(AppRoutes.incomeRegister),
            ),
            const SizedBox(width: AppSpacing.md),
            _OperatingActionButton(
              size: buttonSize,
              label: HomeStrings.movements,
              assetPath: 'assets/icons/money.svg',
              onPressed: () => context.push(AppRoutes.expenseRecords),
            ),
          ],
        );
      },
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
        establishmentName: state.establishments[id] ?? id,
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.mediumEmphasis)),
        Text(
          value,
          style: AppTypography.mediumEmphasis.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _OperatingActionButton extends StatelessWidget {
  const _OperatingActionButton({
    required this.size,
    required this.label,
    required this.assetPath,
    required this.onPressed,
  });

  final double size;
  final String label;
  final String assetPath;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Material(
        color: AppColors.backgroundSecondaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HomeAssetIcon(assetPath: assetPath, size: 22),
                const SizedBox(height: AppSpacing.xs),
                Flexible(
                  child: Center(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.smallEmphasis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

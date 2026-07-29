import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_asset_icon.dart';
import 'package:go_router/go_router.dart';

/// Resume el balance operativo y ofrece accesos a sus movimientos.
///
/// Los importes son temporales hasta que stock, ingresos y egresos cuenten con
/// sus fuentes de datos definitivas.
class HomeOperatingBalanceCard extends StatelessWidget {
  /// Crea el bloque superior del balance operativo.
  const HomeOperatingBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.md),
      elevation: 6,
      shadowColor: Color(0x33000000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomeStrings.operatingBalance,
            style: AppTypography.pageTitle,
          ),
          Text(
            HomeStrings.mockBalanceValue,
            style: AppTypography.balanceValue,
          ),
          SizedBox(height: AppSpacing.md),
          _BalanceRow(
            label: HomeStrings.estimatedStock,
            value: HomeStrings.mockStockValue,
          ),
          SizedBox(height: AppSpacing.sm),
          _BalanceRow(
            label: HomeStrings.operatingExpenses,
            value: HomeStrings.mockExpensesValue,
          ),
          SizedBox(height: AppSpacing.lg),
          _OperatingActions(),
        ],
      ),
    );
  }
}

/// Distribuye los accesos compactos de ingreso, egreso y movimientos.
class _OperatingActions extends StatelessWidget {
  const _OperatingActions();

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
              onPressed: () => context.push(AppRoutes.expenseRegister),
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

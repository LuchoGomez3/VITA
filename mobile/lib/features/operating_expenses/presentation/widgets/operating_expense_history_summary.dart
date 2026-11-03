import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_surface_card.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_history_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

/// Resumen consolidado del historial para el establecimiento activo.
class OperatingExpenseHistorySummary extends StatelessWidget {
  /// Crea el resumen a partir del estado actual del historial.
  const OperatingExpenseHistorySummary({
    required this.establishmentName,
    required this.state,
    super.key,
  });

  /// Nombre visible del establecimiento activo.
  final String establishmentName;

  /// Estado desde el cual se obtienen totales y datos de sincronización.
  final OperatingExpenseHistoryState state;

  @override
  Widget build(BuildContext context) {
    final history = switch (state.history) {
      Data<OperatingExpenseHistory>(:final data) => data,
      _ => null,
    };
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSurfaceCard(
            elevation: 2,
            shadowColor: AppColors.cardShadow,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              height: 176,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(establishmentName, style: AppTypography.pageTitle),
                  const SizedBox(height: AppSpacing.sm),
                  _ExpenseTotal(history: history),
                  const Spacer(),
                  _RecordCount(history: history),
                ],
              ),
            ),
          ),
          if (history?.totalIncludesPending ?? false) ...[
            const SizedBox(height: AppSpacing.xs),
            _PendingSummary(pendingCount: history?.pendingCount ?? 0),
          ],
          if ((history?.cachedWithoutConnection ?? false) && !state.refreshing) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              OperatingExpenseStrings.cachedWithoutConnection,
              style: AppTypography.formFieldHelper,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseTotal extends StatelessWidget {
  const _ExpenseTotal({required this.history});

  final OperatingExpenseHistory? history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          OperatingExpenseStrings.totalExpenses,
          style: AppTypography.secondaryEmphasis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          ArgentineCurrencyInputFormatter.formatCents(history?.totalCents ?? 0),
          style: AppTypography.successTitle,
        ),
      ],
    );
  }
}

class _RecordCount extends StatelessWidget {
  const _RecordCount({required this.history});

  final OperatingExpenseHistory? history;

  @override
  Widget build(BuildContext context) {
    final count = history?.expenses.length ?? 0;
    return Text(
      '$count ${count == 1 ? OperatingExpenseStrings.oneRecord : OperatingExpenseStrings.records}',
    );
  }
}

class _PendingSummary extends StatelessWidget {
  const _PendingSummary({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${OperatingExpenseStrings.pendingSummary}: $pendingCount. '
      '${OperatingExpenseStrings.totalIncludesPending}',
      style: AppTypography.formFieldHelper,
    );
  }
}

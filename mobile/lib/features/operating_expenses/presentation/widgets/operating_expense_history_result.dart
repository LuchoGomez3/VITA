import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_history_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_history_card.dart';

/// Sliver que presenta la carga, el error, el vacío o la lista del historial.
class OperatingExpenseHistoryResult extends StatelessWidget {
  /// Crea el resultado correspondiente al estado actual.
  const OperatingExpenseHistoryResult({required this.state, super.key});

  /// Estado del historial que determina el contenido visible.
  final OperatingExpenseHistoryState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.history) {
      Data<OperatingExpenseHistory>(:final data) when data.expenses.isEmpty => _EmptyHistory(
        filtered: state.filters.period != OperatingExpensePeriod.currentMonth || state.filters.hasClassificationFilter,
      ),
      Data<OperatingExpenseHistory>(:final data) => _ExpenseList(history: data),
      ResultError<OperatingExpenseHistory>(:final error) => SliverFillRemaining(
        hasScrollBody: false,
        child: _HistoryError(
          message: OperatingExpenseStrings.failureMessage(error),
        ),
      ),
      _ => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({required this.history});

  final OperatingExpenseHistory history;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      sliver: SliverList.separated(
        itemCount: history.expenses.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, index) => OperatingExpenseHistoryCard(
          key: ValueKey(history.expenses[index].id),
          expense: history.expenses[index],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            filtered ? OperatingExpenseStrings.emptyFilters : OperatingExpenseStrings.emptyHistory,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: context.read<OperatingExpenseHistoryCubit>().refresh,
              icon: const Icon(Icons.refresh),
              label: const Text(OperatingExpenseStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_header.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_history_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_export_button.dart';

/// Encabezado del historial que presenta un resumen compacto al desplazarse.
class OperatingExpenseHistoryHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Crea el encabezado animado del historial.
  const OperatingExpenseHistoryHeader({
    required this.compact,
    required this.establishmentName,
    required this.state,
    required this.onExport,
    super.key,
  });

  /// Indica si debe mostrarse el resumen integrado en la barra.
  final bool compact;

  /// Nombre del establecimiento incluido en el resumen compacto.
  final String establishmentName;

  /// Estado con el total y la cantidad de movimientos visibles.
  final OperatingExpenseHistoryState state;

  /// Inicia la exportación CSV.
  final VoidCallback onExport;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final history = switch (state.history) {
      Data<OperatingExpenseHistory>(:final data) => data,
      _ => null,
    };
    return AppHeader(
      title: OperatingExpenseStrings.historyTitle,
      titleWidget: _AnimatedHistoryTitle(
        compact: compact,
        establishmentName: establishmentName,
        history: history,
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: compact
              ? const _CompactExpenseType(
                  key: ValueKey('compact-expense-type'),
                )
              : const SizedBox.shrink(
                  key: ValueKey('hidden-expense-type'),
                ),
        ),
        OperatingExpenseExportButton(
          loading: state.export is Loading<OperatingExpenseExport>,
          onPressed: onExport,
        ),
      ],
    );
  }
}

class _AnimatedHistoryTitle extends StatelessWidget {
  const _AnimatedHistoryTitle({
    required this.compact,
    required this.establishmentName,
    required this.history,
  });

  final bool compact;
  final String establishmentName;
  final OperatingExpenseHistory? history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          OperatingExpenseStrings.historyTitle,
          style: AppTypography.appBarTitle,
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: compact ? 1 : 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: _CompactHistorySummary(
              establishmentName: establishmentName,
              history: history,
            ),
          ),
          builder: (context, progress, child) => ClipRect(
            child: Align(
              alignment: Alignment.topLeft,
              heightFactor: progress,
              child: Opacity(opacity: progress, child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactHistorySummary extends StatelessWidget {
  const _CompactHistorySummary({
    required this.establishmentName,
    required this.history,
  });

  final String establishmentName;
  final OperatingExpenseHistory? history;

  @override
  Widget build(BuildContext context) {
    final count = history?.expenses.length ?? 0;
    final amount = ArgentineCurrencyInputFormatter.formatCents(
      history?.totalCents ?? 0,
    );
    return Container(
      key: const ValueKey('compact-history-summary'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: const ShapeDecoration(
        color: AppColors.surface,
        shape: StadiumBorder(),
      ),
      child: Text(
        '$establishmentName · $amount · $count '
        '${count == 1 ? OperatingExpenseStrings.oneRecord : OperatingExpenseStrings.records}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.smallEmphasis,
      ),
    );
  }
}

class _CompactExpenseType extends StatelessWidget {
  const _CompactExpenseType({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xxs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: const ShapeDecoration(
          color: AppColors.primary,
          shape: StadiumBorder(),
        ),
        child: const Text(
          OperatingExpenseStrings.expensesTab,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

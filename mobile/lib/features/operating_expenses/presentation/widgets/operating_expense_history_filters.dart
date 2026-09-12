import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/cubit/operating_expense_history_cubit.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

/// Controles combinables del historial financiero.
class OperatingExpenseHistoryFilters extends StatelessWidget {
  /// Crea los filtros a partir del estado del cubit.
  const OperatingExpenseHistoryFilters({required this.state, super.key});

  /// Estado con filtros y catalogo reconciliado.
  final OperatingExpenseHistoryState state;

  @override
  Widget build(BuildContext context) {
    final type = state.filters.type;
    final categories = state.categories.where((item) => type == null || item.type == type).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: AppSurfaceCard(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          title: const Text(
            OperatingExpenseStrings.filters,
            style: AppTypography.pageTitle,
          ),
          children: [
            _DateFilters(
              filters: state.filters,
              onPeriodSelected: context.read<OperatingExpenseHistoryCubit>().selectPeriod,
              onCustomRangeSelected: context.read<OperatingExpenseHistoryCubit>().selectCustomRange,
            ),
            const SizedBox(height: AppSpacing.md),
            _ExpenseTypeSelector(
              selectedType: type,
              onSelected: context.read<OperatingExpenseHistoryCubit>().selectType,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String?>(
              key: ValueKey('expense-category-filter-${type?.value}'),
              initialValue: state.filters.category,
              decoration: const InputDecoration(
                labelText: OperatingExpenseStrings.category,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  child: Text(OperatingExpenseStrings.allCategories),
                ),
                ...categories.map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.value,
                    child: Text(item.label),
                  ),
                ),
              ],
              onChanged: context.read<OperatingExpenseHistoryCubit>().selectCategory,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: context.read<OperatingExpenseHistoryCubit>().clearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text(OperatingExpenseStrings.clearFilters),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilters extends StatelessWidget {
  const _DateFilters({
    required this.filters,
    required this.onPeriodSelected,
    required this.onCustomRangeSelected,
  });

  final OperatingExpenseFilters filters;
  final ValueChanged<OperatingExpensePeriod> onPeriodSelected;
  final void Function(DateTime from, DateTime to) onCustomRangeSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(OperatingExpenseStrings.dateRange, style: AppTypography.secondaryEmphasis),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _DateShortcutChip(
                label: OperatingExpenseStrings.currentMonth,
                onTap: () => onPeriodSelected(OperatingExpensePeriod.currentMonth),
              ),
              const SizedBox(width: AppSpacing.xs),
              _DateShortcutChip(
                label: OperatingExpenseStrings.lastQuarter,
                onTap: () => onPeriodSelected(OperatingExpensePeriod.lastQuarter),
              ),
              const SizedBox(width: AppSpacing.xs),
              _DateShortcutChip(
                label: OperatingExpenseStrings.allHistory,
                onTap: () => onPeriodSelected(OperatingExpensePeriod.allHistory),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppDateFormField(
                title: OperatingExpenseStrings.dateFrom,
                hintText: OperatingExpenseStrings.dateHint,
                value: filters.from,
                lastDate: today,
                onChanged: (from) {
                  final currentTo = filters.to ?? today;
                  final to = from.isAfter(currentTo) ? from : currentTo;
                  onCustomRangeSelected(from, to);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppDateFormField(
                title: OperatingExpenseStrings.dateTo,
                hintText: OperatingExpenseStrings.dateHint,
                value: filters.to,
                lastDate: today,
                onChanged: (to) {
                  final currentFrom = filters.from ?? to;
                  final from = to.isBefore(currentFrom) ? to : currentFrom;
                  onCustomRangeSelected(from, to);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateShortcutChip extends StatelessWidget {
  const _DateShortcutChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(label, style: AppTypography.datePickerChip),
      ),
    );
  }
}

class _ExpenseTypeSelector extends StatelessWidget {
  const _ExpenseTypeSelector({
    required this.selectedType,
    required this.onSelected,
  });

  final OperatingExpenseType? selectedType;
  final ValueChanged<OperatingExpenseType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppChoiceSelector<OperatingExpenseType>(
        title: OperatingExpenseStrings.type,
        value: selectedType,
        options: const [
          AppChoiceOption(
            value: OperatingExpenseType.administrativeExpense,
            label: OperatingExpenseStrings.administrativeType,
          ),
          AppChoiceOption(
            value: OperatingExpenseType.productionCost,
            label: OperatingExpenseStrings.productiveType,
          ),
        ],
        onChanged: (type) => onSelected(type == selectedType ? null : type),
      ),
    );
  }
}

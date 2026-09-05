import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

/// Selector visual entre egresos e ingresos del historial financiero.
class OperatingExpenseMovementSelector extends StatelessWidget {
  /// Crea el selector con egresos como opción activa.
  const OperatingExpenseMovementSelector({
    required this.onIncomeSelected,
    super.key,
  });

  /// Se ejecuta al seleccionar la opción de ingresos aún no disponible.
  final VoidCallback onIncomeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: SegmentedButton<String>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: AppColors.onPrimary,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
        ),
        segments: const [
          ButtonSegment(
            value: 'expenses',
            label: Text(OperatingExpenseStrings.expensesTab),
          ),
          ButtonSegment(
            value: 'income',
            label: Text(OperatingExpenseStrings.incomeTab),
          ),
        ],
        selected: const {'expenses'},
        onSelectionChanged: (selection) {
          if (selection.contains('income')) onIncomeSelected();
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/constants/financial_movement_strings.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Selector visual entre egresos y ventas del historial financiero.
class FinancialMovementSelector extends StatelessWidget {
  /// Crea el selector indicando cuál sección está activa.
  const FinancialMovementSelector({
    required this.onSelectionChanged,
    required this.salesSelected,
    super.key,
  });

  /// Determina si la sección activa es ventas o egresos.
  final bool salesSelected;

  /// Solicita el cambio de sección; la aplicación resuelve su navegación.
  final ValueChanged<bool> onSelectionChanged;

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
            label: Text(FinancialMovementStrings.expenses),
          ),
          ButtonSegment(
            value: 'sales',
            label: Text(FinancialMovementStrings.sales),
          ),
        ],
        selected: {if (salesSelected) 'sales' else 'expenses'},
        onSelectionChanged: (selection) {
          onSelectionChanged(selection.contains('sales'));
        },
      ),
    );
  }
}

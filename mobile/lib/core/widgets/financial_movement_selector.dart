import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/constants/financial_movement_strings.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Selector compartido entre egresos y ventas del historial financiero.
class FinancialMovementSelector extends StatelessWidget {
  /// Crea el selector e indica si la seccion activa es ventas.
  const FinancialMovementSelector({
    required this.salesSelected,
    required this.onSelectionChanged,
    super.key,
  });

  /// Indica si ventas es la seccion seleccionada.
  final bool salesSelected;

  /// Notifica `true` al seleccionar ventas y `false` al seleccionar egresos.
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
        selected: {
          if (salesSelected) 'sales' else 'expenses',
        },
        onSelectionChanged: (selection) {
          onSelectionChanged(selection.contains('sales'));
        },
      ),
    );
  }
}

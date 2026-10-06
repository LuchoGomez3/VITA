import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/widgets/financial_movement_selector.dart';

/// Selector financiero con la sección de egresos activa.
class OperatingExpenseMovementSelector extends StatelessWidget {
  /// Recibe la acción de navegación a ventas compuesta por la aplicación.
  const OperatingExpenseMovementSelector({required this.onSalesSelected, super.key});

  /// Abre el historial de ventas del mismo establecimiento.
  final VoidCallback onSalesSelected;

  @override
  Widget build(BuildContext context) => FinancialMovementSelector(
    salesSelected: false,
    onSelectionChanged: (salesSelected) {
      if (salesSelected) onSalesSelected();
    },
  );
}

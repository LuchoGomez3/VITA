import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/constants/financial_movement_strings.dart';

/// Acción del encabezado que refleja el progreso de la exportación CSV.
class FinancialCsvExportButton extends StatelessWidget {
  /// Crea el botón de exportación.
  const FinancialCsvExportButton({
    required this.loading,
    required this.onPressed,
    super.key,
  });

  /// Indica si la exportación está en curso.
  final bool loading;

  /// Inicia la exportación cuando el botón está disponible.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: FinancialMovementStrings.exportCsv,
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.file_download_outlined),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_surface_card.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';

/// Resumen de ventas con la misma jerarquía visual del historial de egresos.
class LivestockSaleHistorySummary extends StatelessWidget {
  /// Recibe los importes y la cantidad visibles en el listado actual.
  const LivestockSaleHistorySummary({
    required this.establishmentName,
    required this.totalCents,
    required this.recordCount,
    super.key,
  });

  /// Nombre del establecimiento cuyo historial se consulta.
  final String establishmentName;

  /// Suma de los precios pactados, expresada en centavos enteros.
  final int totalCents;

  /// Cantidad de ventas incluidas en el resumen.
  final int recordCount;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: AppSurfaceCard(
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
            const Text(LivestockSaleHistoryStrings.total, style: AppTypography.secondaryEmphasis),
            const SizedBox(height: AppSpacing.xxs),
            Text(ArgentineCurrencyInputFormatter.formatCents(totalCents), style: AppTypography.successTitle),
            const Spacer(),
            Text(LivestockSaleHistoryStrings.recordCount(recordCount)),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';

/// Resume las ventas disponibles para el establecimiento seleccionado.
class LivestockSaleHistorySummary extends StatelessWidget {
  /// Crea el resumen comercial local.
  const LivestockSaleHistorySummary({
    required this.establishmentName,
    required this.totalCents,
    required this.recordCount,
    super.key,
  });

  /// Nombre visible del establecimiento.
  final String establishmentName;

  /// Suma de los montos pactados en centavos.
  final int totalCents;

  /// Cantidad de ventas incluidas.
  final int recordCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: AppSurfaceCard(
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(establishmentName, style: AppTypography.pageTitle),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              LivestockSaleHistoryStrings.total,
              style: AppTypography.secondaryEmphasis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              ArgentineCurrencyInputFormatter.formatCents(totalCents),
              style: AppTypography.successTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(LivestockSaleHistoryStrings.recordCount(recordCount)),
            const SizedBox(height: AppSpacing.xxs),
            const Text(
              LivestockSaleHistoryStrings.localOnlyNotice,
              style: AppTypography.formFieldHelper,
            ),
            const SizedBox(height: AppSpacing.xxs),
            const Text(
              LivestockSaleHistoryStrings.informationalAmountsNotice,
              style: AppTypography.formFieldHelper,
            ),
          ],
        ),
      ),
    );
  }
}

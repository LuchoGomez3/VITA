import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';

/// Tarjeta de solo lectura que resume una venta del historial.
class LivestockSaleHistoryCard extends StatelessWidget {
  /// Crea la tarjeta a partir de una venta local.
  const LivestockSaleHistoryCard({
    required this.sale,
    required this.onTap,
    super.key,
  });

  /// Operacion comercial que se presenta.
  final LivestockSale sale;

  /// Abre el detalle de la operacion sin habilitar su modificacion.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final collectedCents = sale.collectedAmountCents ?? sale.initialPayment?.amountCents ?? 0;
    final pendingCents = sale.pendingAmountCents ?? sale.totalAmountCents - collectedCents;
    final buyerName = '${sale.buyerName} ${sale.buyerLastName ?? ''}'.trim();

    return Semantics(
      button: true,
      label: LivestockSaleHistoryStrings.openDetail,
      child: AppSurfaceCard(
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        LivestockSaleHistoryStrings.buyer,
                        style: AppTypography.formFieldHelper,
                      ),
                      Text(
                        buyerName,
                        style: AppTypography.formFieldValueEmphasis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  ArgentineCurrencyInputFormatter.formatCents(
                    sale.totalAmountCents,
                  ),
                  style: AppTypography.secondaryEmphasis.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${DateDisplayFormatter.shortDate(sale.operationDate)} · '
              '${LivestockSaleHistoryStrings.animalCount(sale.animalIds.length)} · '
              '${_saleTypeLabel(sale.saleType)}',
              style: AppTypography.formFieldHelper,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${LivestockSaleHistoryStrings.dte}: ${sale.dteNumber}',
              style: AppTypography.mediumEmphasis,
            ),
            const SizedBox(height: AppSpacing.sm),
            _AmountRow(
              label: LivestockSaleHistoryStrings.collectedAmount,
              cents: collectedCents,
            ),
            const SizedBox(height: AppSpacing.xxs),
            _AmountRow(
              label: LivestockSaleHistoryStrings.pendingBalance,
              cents: pendingCents,
            ),
            if (sale.observations case final observations? when observations.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text(
                LivestockSaleHistoryStrings.observations,
                style: AppTypography.formFieldHelper,
              ),
              Text(observations, style: AppTypography.formFieldValue),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _PaymentStatusChip(condition: sale.paymentCondition),
                _SyncStatusChip(status: sale.syncStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _saleTypeLabel(LivestockSaleType type) {
    return switch (type) {
      LivestockSaleType.bulk => LivestockSaleHistoryStrings.bulkSale,
      LivestockSaleType.perKilogram => LivestockSaleHistoryStrings.perKilogramSale,
    };
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.cents});

  final String label;
  final int cents;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          ArgentineCurrencyInputFormatter.formatCents(cents),
          style: AppTypography.mediumEmphasis,
        ),
      ],
    );
  }
}

class _PaymentStatusChip extends StatelessWidget {
  const _PaymentStatusChip({required this.condition});

  final LivestockSalePaymentCondition condition;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (condition) {
      LivestockSalePaymentCondition.total => (
        LivestockSaleHistoryStrings.paymentTotal,
        AppStatusChipTone.success,
      ),
      LivestockSalePaymentCondition.partial => (
        LivestockSaleHistoryStrings.paymentPartial,
        AppStatusChipTone.warning,
      ),
      LivestockSalePaymentCondition.pending => (
        LivestockSaleHistoryStrings.paymentPending,
        AppStatusChipTone.warning,
      ),
    };
    return AppStatusChip(label: label, tone: tone, showDot: true);
  }
}

class _SyncStatusChip extends StatelessWidget {
  const _SyncStatusChip({required this.status});

  final LivestockSaleSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (status) {
      LivestockSaleSyncStatus.synchronized => (
        LivestockSaleHistoryStrings.synchronized,
        AppStatusChipTone.success,
      ),
      LivestockSaleSyncStatus.pending => (
        LivestockSaleHistoryStrings.syncPending,
        AppStatusChipTone.warning,
      ),
      LivestockSaleSyncStatus.rejected => (
        LivestockSaleHistoryStrings.syncRejected,
        AppStatusChipTone.error,
      ),
    };
    return AppStatusChip(label: label, tone: tone, showDot: true);
  }
}

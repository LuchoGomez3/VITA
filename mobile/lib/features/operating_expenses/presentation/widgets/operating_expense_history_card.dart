import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_surface_card.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

/// Tarjeta de auditoria de un egreso sin exponer identificadores tecnicos.
class OperatingExpenseHistoryCard extends StatelessWidget {
  /// Crea la tarjeta para un movimiento visible.
  const OperatingExpenseHistoryCard({required this.expense, super.key});

  /// Egreso ya filtrado y etiquetado por el repositorio.
  final OperatingExpense expense;

  @override
  Widget build(BuildContext context) {
    final pending = expense.syncStatus != OperatingExpenseSyncStatus.synchronized;
    return Semantics(
      label: pending ? OperatingExpenseStrings.pendingSync : null,
      container: true,
      child: AppSurfaceCard(
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        padding: const EdgeInsets.all(AppSpacing.md),
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
                      const Text(OperatingExpenseStrings.conceptLabel, style: AppTypography.formFieldHelper),
                      Text(expense.supply, style: AppTypography.formFieldValueEmphasis),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  ArgentineCurrencyInputFormatter.formatCents(expense.amountCents),
                  style: AppTypography.secondaryEmphasis.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${DateDisplayFormatter.shortDate(expense.date)} · ${expense.type.label} · '
              '${expense.categoryLabel ?? expense.category}',
              style: AppTypography.formFieldHelper,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${OperatingExpenseStrings.registeredBy}: '
              '${expense.loadedByName ?? OperatingExpenseStrings.unknownRegistrant}',
              style: AppTypography.mediumEmphasis,
            ),
            if (expense.receiptNumber case final receipt?) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text('${OperatingExpenseStrings.receiptLabel}: $receipt'),
            ],
            if (expense.description case final description?) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text('${OperatingExpenseStrings.descriptionLabel}: $description'),
            ],
            if (pending) ...[
              const SizedBox(height: AppSpacing.sm),
              const _PendingBadge(),
            ],
          ],
        ),
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.syncPendingContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_problem, size: 16, color: AppColors.syncPending),
          SizedBox(width: AppSpacing.xxs),
          Text(
            OperatingExpenseStrings.pendingSync,
            style: TextStyle(color: AppColors.syncPending, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:go_router/go_router.dart';

/// Anima la transicion entre la espera del backend y el resumen confirmado.
class OperatingExpenseSubmissionView extends StatelessWidget {
  /// Crea la vista continua de carga y resultado.
  const OperatingExpenseSubmissionView({
    required this.expense,
    required this.establishmentName,
    required this.onAddAnotherExpense,
    super.key,
  });

  /// Egreso confirmado, o `null` mientras se espera la respuesta.
  final OperatingExpense? expense;

  /// Nombre visible del establecimiento asociado.
  final String establishmentName;

  /// Reinicia el flujo para cargar un nuevo gasto.
  final VoidCallback onAddAnotherExpense;

  @override
  Widget build(BuildContext context) {
    final savedExpense = expense;
    final isLoading = savedExpense == null;
    return SafeArea(
      child: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isLoading ? 1 : 0,
            child: const _SavingContent(),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 550),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: savedExpense == null
                ? const SizedBox.shrink(key: ValueKey('saving'))
                : _SuccessContent(
                    key: const ValueKey('success'),
                    expense: savedExpense,
                    establishmentName: establishmentName,
                    onAddAnotherExpense: onAddAnotherExpense,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeInOutCubic,
              alignment: isLoading ? Alignment.center : Alignment.topCenter,
              child: AppStatusIndicator(
                icon: isLoading ? Icons.cloud_upload_outlined : Icons.check,
                color: AppColors.primary,
                isLoading: isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingContent extends StatelessWidget {
  const _SavingContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(dimension: 86),
            SizedBox(height: AppSpacing.xxl),
            Text(
              OperatingExpenseStrings.savingTitle,
              style: AppTypography.successTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              OperatingExpenseStrings.savingMessage,
              style: AppTypography.successSubtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.expense,
    required this.establishmentName,
    required this.onAddAnotherExpense,
    super.key,
  });

  final OperatingExpense expense;
  final String establishmentName;
  final VoidCallback onAddAnotherExpense;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 126, AppSpacing.lg, AppSpacing.lg),
      children: [
        const Text(
          OperatingExpenseStrings.successTitle,
          style: AppTypography.successTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(_successMessage, style: AppTypography.successSubtitle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        _ExpenseSummaryCard(
          expense: expense,
          establishmentName: establishmentName,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppFilledButton(
          label: OperatingExpenseStrings.addAnotherExpense,
          icon: const Icon(Icons.add),
          onPressed: onAddAnotherExpense,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppOutlinedButton(
          label: OperatingExpenseStrings.backHome,
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }

  String get _successMessage => switch (expense.syncStatus) {
    OperatingExpenseSyncStatus.synchronized => OperatingExpenseStrings.cloudSuccessMessage,
    OperatingExpenseSyncStatus.pending => OperatingExpenseStrings.localSuccessMessage,
    OperatingExpenseSyncStatus.rejected => OperatingExpenseStrings.rejectedMessage,
  };
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({
    required this.expense,
    required this.establishmentName,
  });

  final OperatingExpense expense;
  final String establishmentName;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(OperatingExpenseStrings.summary, style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(label: OperatingExpenseStrings.establishment, value: establishmentName),
          _SummaryRow(
            label: OperatingExpenseStrings.amount,
            value: ArgentineCurrencyInputFormatter.formatCents(expense.amountCents),
          ),
          _SummaryRow(label: OperatingExpenseStrings.type, value: expense.type.label),
          _SummaryRow(label: OperatingExpenseStrings.category, value: expense.category),
          _SummaryRow(label: OperatingExpenseStrings.supply, value: expense.supply),
          _SummaryRow(
            label: OperatingExpenseStrings.date,
            value: DateDisplayFormatter.shortDate(expense.date),
            showDivider: expense.description != null || expense.receiptNumber != null,
          ),
          if (expense.description case final description?)
            _SummaryRow(
              label: OperatingExpenseStrings.concept,
              value: description,
              showDivider: expense.receiptNumber != null,
            ),
          if (expense.receiptNumber case final receiptNumber?)
            _SummaryRow(
              label: OperatingExpenseStrings.receiptSummary,
              value: receiptNumber,
              showDivider: false,
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.showDivider = true});

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label, style: AppTypography.formFieldHelper)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.formFieldValueEmphasis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

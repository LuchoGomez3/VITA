import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/formatters/argentine_currency_input_formatter.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/app_surface_card.dart';
import 'package:frontend_mayoral/core/widgets/financial_movement_selector.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_history_cubit.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/history/livestock_sale_history_header.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/history/livestock_sale_history_summary.dart';
import 'package:go_router/go_router.dart';

/// Historial local de ventas dentro de los movimientos financieros.
class LivestockSaleHistoryPage extends StatelessWidget {
  /// Recibe la composición del Cubit y la navegación a egresos desde la app.
  const LivestockSaleHistoryPage({
    required this.establishmentName,
    required this.createCubit,
    required this.onExpensesSelected,
    super.key,
  });

  /// Nombre del establecimiento autorizado cuyo historial se muestra.
  final String establishmentName;

  /// Factory que entrega casos de uso sin exponer repositorios a presentación.
  final LivestockSaleHistoryCubit Function() createCubit;

  /// Cambia de sección mediante una ruta definida por la aplicación.
  final VoidCallback onExpensesSelected;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createCubit()..load(),
    child: _HistoryView(establishmentName: establishmentName, onExpensesSelected: onExpensesSelected),
  );
}

// Se mantienen los mismos umbrales y animaciones que en egresos para que el
// cambio de sección conserve la forma de desplazarse por los movimientos.
const _selectorOverlayExtent = 60.0;
const _compactHeaderScrollThreshold = 96.0;

class _HistoryView extends StatefulWidget {
  const _HistoryView({required this.establishmentName, required this.onExpensesSelected});

  final String establishmentName;
  final VoidCallback onExpensesSelected;

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  final _scrollController = ScrollController();
  bool _compactHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateHeaderMode);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateHeaderMode)
      ..dispose();
    super.dispose();
  }

  void _updateHeaderMode() {
    final compact = _scrollController.offset >= _compactHeaderScrollThreshold;
    if (compact != _compactHeader) setState(() => _compactHeader = compact);
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<LivestockSaleHistoryCubit, LivestockSaleHistoryState>(
    listenWhen: (previous, current) => previous.payment != current.payment,
    listener: (context, state) {
      final message = switch (state.payment) {
        Data<LivestockSale>() => LivestockSaleHistoryStrings.paymentSaved,
        ResultError<LivestockSale>() => LivestockSaleHistoryStrings.paymentError,
        _ => null,
      };
      if (message != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    },
    builder: (context, state) {
      final sales = switch (state.history) {
        Data<List<LivestockSale>>(:final data) => data,
        _ => const <LivestockSale>[],
      };
      final total = sales.fold<int>(0, (sum, sale) => sum + sale.totalAmountCents);
      return Scaffold(
        appBar: LivestockSaleHistoryHeader(
          compact: _compactHeader,
          establishmentName: widget.establishmentName,
          totalCents: total,
          recordCount: sales.length,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: context.read<LivestockSaleHistoryCubit>().load,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: _selectorOverlayExtent)),
                    SliverToBoxAdapter(
                      child: LivestockSaleHistorySummary(
                        establishmentName: widget.establishmentName,
                        totalCents: total,
                        recordCount: sales.length,
                      ),
                    ),
                    if (state.payment is Loading<LivestockSale>)
                      const SliverToBoxAdapter(child: LinearProgressIndicator(minHeight: 2)),
                    _HistoryResult(state: state),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                ignoring: _compactHeader,
                child: AnimatedSlide(
                  offset: _compactHeader ? const Offset(0, -1) : Offset.zero,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedOpacity(
                    opacity: _compactHeader ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: FinancialMovementSelector(
                      salesSelected: true,
                      onSelectionChanged: (salesSelected) {
                        if (!salesSelected) widget.onExpensesSelected();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Resultado como sliver para desplazar resumen y tarjetas en una sola lista.
class _HistoryResult extends StatelessWidget {
  const _HistoryResult({required this.state});

  final LivestockSaleHistoryState state;

  @override
  Widget build(BuildContext context) {
    if (state.history case Data<List<LivestockSale>>(:final data) when data.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
        sliver: SliverList.separated(
          itemCount: data.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) =>
              _SaleCard(sale: data[index], collecting: state.payment is Loading<LivestockSale>),
        ),
      );
    }
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: switch (state.history) {
          Data<List<LivestockSale>>() => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text(LivestockSaleHistoryStrings.empty, textAlign: TextAlign.center),
          ),
          ResultError<List<LivestockSale>>() => const _HistoryError(),
          _ => const CircularProgressIndicator(),
        },
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(LivestockSaleHistoryStrings.loadError, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: context.read<LivestockSaleHistoryCubit>().load,
          icon: const Icon(Icons.refresh),
          label: const Text(LivestockSaleHistoryStrings.retry),
        ),
      ],
    ),
  );
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale, required this.collecting});

  final LivestockSale sale;
  final bool collecting;

  @override
  Widget build(BuildContext context) {
    final collected = sale.initialPayment?.amountCents ?? 0;
    final canCollect = sale.paymentCondition == LivestockSalePaymentCondition.pending && sale.initialPayment == null;
    final status = switch (sale.paymentCondition) {
      LivestockSalePaymentCondition.pending => LivestockSaleHistoryStrings.pending,
      LivestockSalePaymentCondition.partial => LivestockSaleHistoryStrings.partial,
      LivestockSalePaymentCondition.total => LivestockSaleHistoryStrings.collected,
    };
    return AppSurfaceCard(
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: canCollect && !collecting ? () => _confirmPayment(context) : null,
        child: Padding(
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
                        const Text(LivestockSaleHistoryStrings.buyer, style: AppTypography.formFieldHelper),
                        Text(
                          '${sale.buyerName} ${sale.buyerLastName ?? ''}'.trim(),
                          style: AppTypography.formFieldValueEmphasis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    ArgentineCurrencyInputFormatter.formatCents(sale.totalAmountCents),
                    style: AppTypography.secondaryEmphasis.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${DateDisplayFormatter.shortDate(sale.operationDate)} · '
                '${LivestockSaleHistoryStrings.animals(sale.animalIds.length)}',
                style: AppTypography.formFieldHelper,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${LivestockSaleHistoryStrings.paid}: ${ArgentineCurrencyInputFormatter.formatCents(collected)}',
                style: AppTypography.mediumEmphasis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${LivestockSaleHistoryStrings.balance}: ${ArgentineCurrencyInputFormatter.formatCents(sale.totalAmountCents - collected)}',
              ),
              const SizedBox(height: AppSpacing.sm),
              _PaymentStatusBadge(label: status, paid: sale.paymentCondition == LivestockSalePaymentCondition.total),
              if (canCollect)
                TextButton.icon(
                  onPressed: collecting ? null : () => _confirmPayment(context),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text(LivestockSaleHistoryStrings.collect),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPayment(BuildContext context) async {
    final cubit = context.read<LivestockSaleHistoryCubit>();
    final method = await showDialog<LivestockSalePaymentMethod>(
      context: context,
      builder: (_) => _PaymentDialog(sale: sale),
    );
    if (method != null && !cubit.isClosed) await cubit.collect(sale, method);
  }
}

/// Identifica el cobro con el mismo tratamiento de insignias que en egresos.
class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.label, required this.paid});

  final String label;
  final bool paid;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
    decoration: BoxDecoration(
      color: paid ? AppColors.backgroundSecondaryLight : AppColors.syncPendingContainer,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          paid ? Icons.check_circle_outline : Icons.payments_outlined,
          size: 16,
          color: paid ? AppColors.primary : AppColors.syncPending,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Flexible(
          child: Text(
            label,
            style: TextStyle(color: paid ? AppColors.primary : AppColors.syncPending, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

/// Confirma el cobro completo con su medio de pago antes de escribir SQLite.
class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.sale});

  final LivestockSale sale;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  LivestockSalePaymentMethod _method = LivestockSalePaymentMethod.cash;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(LivestockSaleHistoryStrings.collect),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          LivestockSaleHistoryStrings.confirmAmount(
            ArgentineCurrencyInputFormatter.formatCents(widget.sale.totalAmountCents),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<LivestockSalePaymentMethod>(
          initialValue: _method,
          decoration: const InputDecoration(labelText: LivestockSaleHistoryStrings.paymentMethod),
          items: const [
            DropdownMenuItem(value: LivestockSalePaymentMethod.cash, child: Text(LivestockSaleHistoryStrings.cash)),
            DropdownMenuItem(
              value: LivestockSalePaymentMethod.bankTransfer,
              child: Text(LivestockSaleHistoryStrings.bankTransfer),
            ),
            DropdownMenuItem(value: LivestockSalePaymentMethod.check, child: Text(LivestockSaleHistoryStrings.check)),
            DropdownMenuItem(value: LivestockSalePaymentMethod.card, child: Text(LivestockSaleHistoryStrings.card)),
          ],
          onChanged: (method) {
            if (method != null) setState(() => _method = method);
          },
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => context.pop(), child: const Text(LivestockSaleHistoryStrings.cancel)),
      FilledButton(
        onPressed: () => context.pop(_method),
        child: const Text(LivestockSaleHistoryStrings.confirm),
      ),
    ],
  );
}

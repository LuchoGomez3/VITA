import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_history.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_history_cubit.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';

/// Controles combinables del historial local de ventas.
class LivestockSaleHistoryFiltersView extends StatefulWidget {
  /// Crea los controles a partir del estado del Cubit.
  const LivestockSaleHistoryFiltersView({required this.state, super.key});

  /// Estado que contiene los filtros vigentes.
  final LivestockSaleHistoryState state;

  @override
  State<LivestockSaleHistoryFiltersView> createState() => _LivestockSaleHistoryFiltersViewState();
}

class _LivestockSaleHistoryFiltersViewState extends State<LivestockSaleHistoryFiltersView> {
  late final TextEditingController _buyerController;

  @override
  void initState() {
    super.initState();
    _buyerController = TextEditingController(text: widget.state.filters.buyer);
  }

  @override
  void didUpdateWidget(covariant LivestockSaleHistoryFiltersView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final buyer = widget.state.filters.buyer;
    if (_buyerController.text != buyer) {
      // El Cubit puede limpiar el filtro desde afuera. Sincronizar solo cuando
      // cambia realmente evita reconstruir el cursor en cada tecla ingresada.
      _buyerController.value = TextEditingValue(
        text: buyer,
        selection: TextSelection.collapsed(offset: buyer.length),
      );
    }
  }

  @override
  void dispose() {
    _buyerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.state.filters;
    final cubit = context.read<LivestockSaleHistoryCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: AppSurfaceCard(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          title: const Text(
            LivestockSaleHistoryStrings.filters,
            style: AppTypography.pageTitle,
          ),
          children: [
            _DateFilters(
              filters: filters,
              onPeriodSelected: cubit.selectPeriod,
              onCustomRangeSelected: cubit.selectCustomRange,
            ),
            const SizedBox(height: AppSpacing.md),
            _SaleTypeSelector(
              selectedType: filters.type,
              onSelected: cubit.selectType,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextFormField(
              controller: _buyerController,
              title: LivestockSaleHistoryStrings.buyerSearch,
              hintText: LivestockSaleHistoryStrings.buyerSearchHint,
              prefixIcon: const Icon(Icons.search),
              textInputAction: TextInputAction.search,
              onChanged: cubit.searchBuyer,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<LivestockSalePaymentCondition?>(
              key: ValueKey(
                'sale-payment-filter-${filters.paymentCondition?.value}',
              ),
              isExpanded: true,
              initialValue: filters.paymentCondition,
              decoration: const InputDecoration(
                labelText: LivestockSaleHistoryStrings.paymentStatus,
              ),
              items: const [
                DropdownMenuItem<LivestockSalePaymentCondition?>(
                  child: Text(
                    LivestockSaleHistoryStrings.allPaymentStatuses,
                  ),
                ),
                DropdownMenuItem(
                  value: LivestockSalePaymentCondition.pending,
                  child: Text(LivestockSaleHistoryStrings.paymentPending),
                ),
                DropdownMenuItem(
                  value: LivestockSalePaymentCondition.partial,
                  child: Text(LivestockSaleHistoryStrings.paymentPartial),
                ),
                DropdownMenuItem(
                  value: LivestockSalePaymentCondition.total,
                  child: Text(LivestockSaleHistoryStrings.paymentTotal),
                ),
              ],
              onChanged: cubit.selectPaymentCondition,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: filters.hasActiveFilters ? cubit.clearFilters : null,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text(
                  LivestockSaleHistoryStrings.clearFilters,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilters extends StatelessWidget {
  const _DateFilters({
    required this.filters,
    required this.onPeriodSelected,
    required this.onCustomRangeSelected,
  });

  final LivestockSaleHistoryFilters filters;
  final ValueChanged<LivestockSaleHistoryPeriod> onPeriodSelected;
  final void Function(DateTime from, DateTime to) onCustomRangeSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          LivestockSaleHistoryStrings.dateRange,
          style: AppTypography.secondaryEmphasis,
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _DateShortcutChip(
                label: LivestockSaleHistoryStrings.currentMonth,
                selected: filters.period == LivestockSaleHistoryPeriod.currentMonth,
                onTap: () => onPeriodSelected(
                  LivestockSaleHistoryPeriod.currentMonth,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _DateShortcutChip(
                label: LivestockSaleHistoryStrings.lastQuarter,
                selected: filters.period == LivestockSaleHistoryPeriod.lastQuarter,
                onTap: () => onPeriodSelected(
                  LivestockSaleHistoryPeriod.lastQuarter,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _DateShortcutChip(
                label: LivestockSaleHistoryStrings.allHistory,
                selected: filters.period == LivestockSaleHistoryPeriod.allHistory,
                onTap: () => onPeriodSelected(
                  LivestockSaleHistoryPeriod.allHistory,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppDateFormField(
                title: LivestockSaleHistoryStrings.dateFrom,
                hintText: LivestockSaleHistoryStrings.dateHint,
                value: filters.from,
                lastDate: today,
                onChanged: (from) {
                  final currentTo = filters.to ?? today;
                  final to = from.isAfter(currentTo) ? from : currentTo;
                  onCustomRangeSelected(from, to);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppDateFormField(
                title: LivestockSaleHistoryStrings.dateTo,
                hintText: LivestockSaleHistoryStrings.dateHint,
                value: filters.to,
                lastDate: today,
                onChanged: (to) {
                  final currentFrom = filters.from ?? to;
                  final from = to.isBefore(currentFrom) ? to : currentFrom;
                  onCustomRangeSelected(from, to);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateShortcutChip extends StatelessWidget {
  const _DateShortcutChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: selected ? 0.14 : 0.06),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: selected ? 0.45 : 0.15),
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(label, style: AppTypography.datePickerChip),
      ),
    );
  }
}

class _SaleTypeSelector extends StatelessWidget {
  const _SaleTypeSelector({
    required this.selectedType,
    required this.onSelected,
  });

  final LivestockSaleType? selectedType;
  final ValueChanged<LivestockSaleType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppChoiceSelector<LivestockSaleType>(
        title: LivestockSaleHistoryStrings.saleType,
        value: selectedType,
        options: const [
          AppChoiceOption(
            value: LivestockSaleType.bulk,
            label: LivestockSaleHistoryStrings.bulkSale,
          ),
          AppChoiceOption(
            value: LivestockSaleType.perKilogram,
            label: LivestockSaleHistoryStrings.perKilogramSale,
          ),
        ],
        onChanged: (type) {
          onSelected(type == selectedType ? null : type);
        },
      ),
    );
  }
}

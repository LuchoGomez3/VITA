import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_history_cubit.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/history/livestock_sale_history_card.dart';

/// Sliver que presenta carga, error, vacio o ventas filtradas.
class LivestockSaleHistoryResult extends StatelessWidget {
  /// Crea el resultado correspondiente al estado actual.
  const LivestockSaleHistoryResult({
    required this.state,
    required this.onSaleSelected,
    super.key,
  });

  /// Estado del historial que determina el contenido visible.
  final LivestockSaleHistoryState state;

  /// Abre el detalle local de la venta seleccionada.
  final ValueChanged<String> onSaleSelected;

  @override
  Widget build(BuildContext context) {
    return switch (state.history) {
      Data<List<LivestockSale>>(:final data) when data.isNotEmpty => SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        sliver: SliverList.separated(
          itemCount: data.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, index) => LivestockSaleHistoryCard(
            sale: data[index],
            onTap: () => onSaleSelected(data[index].id),
          ),
        ),
      ),
      Data<List<LivestockSale>>() => SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyHistory(filtered: state.filters.hasActiveFilters),
      ),
      ResultError<List<LivestockSale>>() => const SliverFillRemaining(
        hasScrollBody: false,
        child: _HistoryError(),
      ),
      _ => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          filtered ? LivestockSaleHistoryStrings.filteredEmpty : LivestockSaleHistoryStrings.empty,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              LivestockSaleHistoryStrings.loadError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: context.read<LivestockSaleHistoryCubit>().load,
              icon: const Icon(Icons.refresh),
              label: const Text(LivestockSaleHistoryStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

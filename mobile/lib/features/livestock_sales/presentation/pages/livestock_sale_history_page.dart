import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/widgets/app_toast_host.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/export_livestock_sales_csv_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_history_cubit.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/history/livestock_sale_history_filters.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/history/livestock_sale_history_header.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/history/livestock_sale_history_result.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/history/livestock_sale_history_summary.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

/// Factory del estado del historial de ventas.
typedef LivestockSaleHistoryCubitFactory = LivestockSaleHistoryCubit Function();

const _movementSelectorOverlayExtent = 60.0;
const _compactHeaderScrollThreshold = 96.0;

/// Historial local de ventas del establecimiento activo.
class LivestockSaleHistoryPage extends StatelessWidget {
  /// Crea la pantalla e inyecta su Cubit y navegacion a egresos.
  const LivestockSaleHistoryPage({
    required this.establishmentName,
    required this.createCubit,
    required this.onExpensesSelected,
    required this.onSaleSelected,
    super.key,
  });

  /// Nombre visible del establecimiento.
  final String establishmentName;

  /// Construye el Cubit sin exponer infraestructura a presentacion.
  final LivestockSaleHistoryCubitFactory createCubit;

  /// Abre la seccion de egresos del mismo establecimiento.
  final VoidCallback onExpensesSelected;

  /// Abre el detalle de una venta sin desmontar el historial.
  final ValueChanged<String> onSaleSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..load(),
      child: _LivestockSaleHistoryView(
        establishmentName: establishmentName,
        onExpensesSelected: onExpensesSelected,
        onSaleSelected: onSaleSelected,
      ),
    );
  }
}

class _LivestockSaleHistoryView extends StatefulWidget {
  const _LivestockSaleHistoryView({
    required this.establishmentName,
    required this.onExpensesSelected,
    required this.onSaleSelected,
  });

  final String establishmentName;
  final VoidCallback onExpensesSelected;
  final ValueChanged<String> onSaleSelected;

  @override
  State<_LivestockSaleHistoryView> createState() => _LivestockSaleHistoryViewState();
}

class _LivestockSaleHistoryViewState extends State<_LivestockSaleHistoryView> {
  static final _logger = Logger('LivestockSaleHistoryView');
  final _scrollController = ScrollController();
  bool _compactHeader = false;
  bool _exporting = false;

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

  Future<void> _export(List<LivestockSale> sales) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      const filename = 'ventas_hacienda.csv';
      final csv = const ExportLivestockSalesCsvUseCase()(sales);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(utf8.encode('\uFEFF$csv'), mimeType: 'text/csv', name: filename)],
          fileNameOverrides: const [filename],
          sharePositionOrigin: Offset.zero & MediaQuery.sizeOf(context),
        ),
      );
    } on Exception catch (error, stackTrace) {
      _logger.warning('No se pudo compartir el CSV de ventas.', error.runtimeType, stackTrace);
      if (mounted) {
        AppToastHost.show(context, LivestockSaleHistoryStrings.exportError);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivestockSaleHistoryCubit, LivestockSaleHistoryState>(
      builder: (context, state) {
        final sales = switch (state.history) {
          Data<List<LivestockSale>>(:final data) => data,
          _ => const <LivestockSale>[],
        };
        final totalCents = sales.fold<int>(
          0,
          (total, sale) => total + sale.totalAmountCents,
        );
        final pendingCount = sales
            .where(
              (sale) => sale.syncStatus == LivestockSaleSyncStatus.pending,
            )
            .length;

        return Scaffold(
          appBar: LivestockSaleHistoryHeader(
            compact: _compactHeader,
            establishmentName: widget.establishmentName,
            totalCents: totalCents,
            recordCount: sales.length,
            pendingCount: pendingCount,
            exporting: _exporting,
            onExport: sales.isEmpty ? null : () => unawaited(_export(sales)),
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
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: _movementSelectorOverlayExtent,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: LivestockSaleHistorySummary(
                          establishmentName: widget.establishmentName,
                          totalCents: totalCents,
                          recordCount: sales.length,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: LivestockSaleHistoryFiltersView(state: state),
                      ),
                      LivestockSaleHistoryResult(
                        state: state,
                        onSaleSelected: widget.onSaleSelected,
                      ),
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
                          if (!salesSelected) {
                            widget.onExpensesSelected();
                          }
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
}

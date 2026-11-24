import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_history.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_history_use_case.dart';

/// Estado del historial local y sus filtros combinables.
class LivestockSaleHistoryState {
  /// Crea un estado inmutable para la pantalla.
  const LivestockSaleHistoryState({
    required this.filters,
    required this.history,
  });

  /// Estado inicial antes de consultar SQLite.
  const LivestockSaleHistoryState.initial()
    : filters = const LivestockSaleHistoryFilters.initial(),
      history = const ResultState.initial();

  /// Filtros actualmente aplicados.
  final LivestockSaleHistoryFilters filters;

  /// Resultado visible despues de aplicar los filtros.
  final ResultState<List<LivestockSale>> history;
}

/// Carga las ventas una vez y resuelve filtros inmediatamente en memoria.
class LivestockSaleHistoryCubit extends Cubit<LivestockSaleHistoryState> {
  /// Crea el Cubit para un establecimiento autorizado.
  LivestockSaleHistoryCubit({
    required String establishmentId,
    required GetLivestockSaleHistoryUseCase getHistory,
    DateTime Function()? now,
  }) : _establishmentId = establishmentId,
       _getHistory = getHistory,
       _now = now ?? DateTime.now,
       super(const LivestockSaleHistoryState.initial()) {
    // Brick confirma, rechaza o reintenta despues de que la pantalla carga.
    // Releer SQLite conserva los filtros sin exigir al usuario actualizarla.
    _saleChanges = _getHistory.changes.listen(
      (_) => unawaited(_reloadFromChange()),
    );
  }

  final String _establishmentId;
  final GetLivestockSaleHistoryUseCase _getHistory;
  final DateTime Function() _now;
  List<LivestockSale> _allSales = const [];
  late final StreamSubscription<void> _saleChanges;
  int _requestVersion = 0;

  /// Lee SQLite y conserva el filtro vigente al actualizar el historial.
  Future<void> load() => _load(showLoading: true);

  Future<void> _reloadFromChange() => _load(showLoading: false);

  Future<void> _load({required bool showLoading}) async {
    final requestVersion = ++_requestVersion;
    if (showLoading) {
      emit(
        LivestockSaleHistoryState(
          filters: state.filters,
          history: const ResultState.loading(),
        ),
      );
    }
    final result = await _getHistory(_establishmentId);
    if (isClosed || requestVersion != _requestVersion) return;
    switch (result) {
      case Success<List<LivestockSale>>(:final data):
        _allSales = List.of(data)..sort(_mostRecentFirst);
        _emitFiltered(state.filters);
      case Failure<List<LivestockSale>>(:final error):
        emit(
          LivestockSaleHistoryState(
            filters: state.filters,
            history: ResultState.error(error),
          ),
        );
    }
  }

  /// Selecciona un atajo temporal sin volver a consultar persistencia.
  void selectPeriod(LivestockSaleHistoryPeriod period) {
    final today = _day(_now());
    final filters = switch (period) {
      LivestockSaleHistoryPeriod.currentMonth => state.filters.withRange(
        period: period,
        from: DateTime(today.year, today.month),
        to: today,
      ),
      LivestockSaleHistoryPeriod.lastQuarter => state.filters.withRange(
        period: period,
        from: DateTime(today.year, today.month - 2),
        to: today,
      ),
      LivestockSaleHistoryPeriod.allHistory => state.filters.withRange(
        period: period,
        from: null,
        to: null,
      ),
      LivestockSaleHistoryPeriod.custom => state.filters.withRange(
        period: period,
        from: state.filters.from,
        to: state.filters.to,
      ),
    };
    _emitFiltered(filters);
  }

  /// Aplica un intervalo personalizado e inclusivo.
  void selectCustomRange(DateTime from, DateTime to) {
    _emitFiltered(
      state.filters.withRange(
        period: LivestockSaleHistoryPeriod.custom,
        from: _day(from),
        to: _day(to),
      ),
    );
  }

  /// Filtra por modalidad de venta.
  void selectType(LivestockSaleType? type) {
    _emitFiltered(state.filters.withType(type));
  }

  /// Busca coincidencias parciales del comprador.
  void searchBuyer(String buyer) {
    _emitFiltered(state.filters.withBuyer(buyer));
  }

  /// Filtra por la condicion de cobro registrada.
  void selectPaymentCondition(LivestockSalePaymentCondition? condition) {
    _emitFiltered(state.filters.withPaymentCondition(condition));
  }

  /// Elimina todos los filtros y vuelve al historial completo.
  void clearFilters() {
    _emitFiltered(const LivestockSaleHistoryFilters.initial());
  }

  void _emitFiltered(LivestockSaleHistoryFilters filters) {
    final visible = _allSales.where(filters.matches).toList()..sort(_mostRecentFirst);
    emit(
      LivestockSaleHistoryState(
        filters: filters,
        history: ResultState.data(visible),
      ),
    );
  }

  static int _mostRecentFirst(LivestockSale left, LivestockSale right) {
    final operationComparison = right.operationDate.compareTo(
      left.operationDate,
    );
    if (operationComparison != 0) return operationComparison;
    return right.createdAt.compareTo(left.createdAt);
  }

  static DateTime _day(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  @override
  Future<void> close() async {
    await _saleChanges.cancel();
    return super.close();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

part 'operating_expense_history_cubit.freezed.dart';

/// Estado completo del historial y sus operaciones independientes.
@freezed
sealed class OperatingExpenseHistoryState with _$OperatingExpenseHistoryState {
  /// Crea el estado con filtros resueltos y resultados asincronos tipados.
  const factory OperatingExpenseHistoryState({
    required OperatingExpenseFilters filters,
    @Default(ResultState<OperatingExpenseHistory>.initial()) ResultState<OperatingExpenseHistory> history,
    @Default(ResultState<OperatingExpenseExport>.initial()) ResultState<OperatingExpenseExport> export,
    @Default(<OperatingExpenseCategory>[]) List<OperatingExpenseCategory> categories,
    @Default(false) bool refreshing,
    String? message,
  }) = _OperatingExpenseHistoryState;
}

/// Coordina cache, pull, filtros y exportacion sin acceder a infraestructura.
class OperatingExpenseHistoryCubit extends Cubit<OperatingExpenseHistoryState> {
  /// Crea el cubit para el establecimiento activo.
  OperatingExpenseHistoryCubit({
    required this.establishmentId,
    required GetOperatingExpenseHistoryUseCase getHistory,
    required OperatingExpenseCatalogUseCase localCatalog,
    required RefreshOperatingExpenseCatalogUseCase refreshCatalog,
    required ExportOperatingExpensesUseCase exportExpenses,
    DateTime Function()? now,
  }) : _getHistory = getHistory,
       _localCatalog = localCatalog,
       _refreshCatalog = refreshCatalog,
       _exportExpenses = exportExpenses,
       _now = now ?? DateTime.now,
       super(OperatingExpenseHistoryState(filters: OperatingExpenseFilters.initial((now ?? DateTime.now)())));

  /// UUID del establecimiento cuyo flujo financiero se consulta.
  final String establishmentId;
  final GetOperatingExpenseHistoryUseCase _getHistory;
  final OperatingExpenseCatalogUseCase _localCatalog;
  final RefreshOperatingExpenseCatalogUseCase _refreshCatalog;
  final ExportOperatingExpensesUseCase _exportExpenses;
  final DateTime Function() _now;
  int _requestVersion = 0;

  /// Muestra SQLite enseguida y refresca backend en segundo plano.
  Future<void> load() async {
    await _loadLocalCatalog();
    if (isClosed) return;
    await _showLocalThenRefresh(showLoadingWhenEmpty: true);
    if (isClosed) return;
    await _refreshRemoteCatalog();
  }

  /// Reintenta conservando filtros y contenido cacheado.
  Future<void> refresh() => _showLocalThenRefresh(showLoadingWhenEmpty: false);

  /// Cambia el atajo de fecha y actualiza el resultado inmediatamente.
  Future<void> selectPeriod(OperatingExpensePeriod period) async {
    final today = _day(_now());
    final filters = switch (period) {
      OperatingExpensePeriod.currentMonth => state.filters.copyWith(
        period: period,
        from: DateTime(today.year, today.month),
        to: today,
      ),
      OperatingExpensePeriod.lastQuarter => state.filters.copyWith(
        period: period,
        from: DateTime(today.year, today.month - 2),
        to: today,
      ),
      OperatingExpensePeriod.allHistory => state.filters.copyWith(period: period, from: null, to: null),
      OperatingExpensePeriod.custom => state.filters.copyWith(period: period),
    };
    emit(state.copyWith(filters: filters));
    if (period != OperatingExpensePeriod.custom) await _showLocalThenRefresh(showLoadingWhenEmpty: false);
  }

  /// Aplica un rango personalizado inclusivo.
  Future<void> selectCustomRange(DateTime from, DateTime to) async {
    emit(
      state.copyWith(
        filters: state.filters.copyWith(period: OperatingExpensePeriod.custom, from: _day(from), to: _day(to)),
      ),
    );
    await _showLocalThenRefresh(showLoadingWhenEmpty: false);
  }

  /// Cambia el tipo y limpia una categoria incompatible.
  Future<void> selectType(OperatingExpenseType? type) async {
    final selectedCategory = state.filters.category;
    final categoryRemainsValid =
        selectedCategory == null ||
        state.categories.any((item) => item.value == selectedCategory && (type == null || item.type == type));
    emit(
      state.copyWith(
        filters: state.filters.copyWith(type: type, category: categoryRemainsValid ? selectedCategory : null),
      ),
    );
    await _showLocalThenRefresh(showLoadingWhenEmpty: false);
  }

  /// Cambia la categoria dependiente del tipo activo.
  Future<void> selectCategory(String? category) async {
    emit(state.copyWith(filters: state.filters.copyWith(category: category)));
    await _showLocalThenRefresh(showLoadingWhenEmpty: false);
  }

  /// Restaura el mes actual y elimina clasificaciones.
  Future<void> clearFilters() async {
    emit(state.copyWith(filters: OperatingExpenseFilters.initial(_now())));
    await _showLocalThenRefresh(showLoadingWhenEmpty: false);
  }

  /// Solicita el CSV remoto usando el filtro inmutable del estado actual.
  Future<void> exportCsv() async {
    if (state.export is Loading<OperatingExpenseExport>) return;
    emit(state.copyWith(export: const ResultState.loading(), message: null));
    final result = await _exportExpenses(establishmentId, state.filters);
    if (isClosed) return;
    switch (result) {
      case Success<OperatingExpenseExport>(:final data):
        emit(state.copyWith(export: ResultState.data(data), message: OperatingExpenseStrings.exportSuccess));
      case Failure<OperatingExpenseExport>(:final error):
        emit(state.copyWith(export: ResultState.error(error), message: _messageFor(error)));
    }
  }

  /// Limpia el resultado de exportacion luego de compartir el archivo.
  void consumeExport() => emit(state.copyWith(export: const ResultState.initial(), message: null));

  Future<void> _showLocalThenRefresh({required bool showLoadingWhenEmpty}) async {
    final version = ++_requestVersion;
    final local = await _getHistory.local(establishmentId, state.filters);
    if (isClosed || version != _requestVersion) return;
    switch (local) {
      case Success<OperatingExpenseHistory>(:final data):
        emit(state.copyWith(history: ResultState.data(data), refreshing: true, message: null));
      case Failure<OperatingExpenseHistory>(:final error):
        if (showLoadingWhenEmpty) emit(state.copyWith(history: ResultState.error(error), refreshing: false));
        return;
    }
    await _refreshRemote(version);
  }

  Future<void> _refreshRemote(int version) async {
    final result = await _getHistory.refresh(establishmentId, state.filters);
    if (isClosed || version != _requestVersion) return;
    switch (result) {
      case Success<OperatingExpenseHistory>(:final data):
        emit(state.copyWith(history: ResultState.data(data), refreshing: false, message: null));
      case Failure<OperatingExpenseHistory>(:final error):
        emit(state.copyWith(refreshing: false, message: _messageFor(error)));
    }
  }

  Future<void> _loadLocalCatalog() async {
    final results = await Future.wait(
      OperatingExpenseType.values.map((type) => _localCatalog.getCategories(establishmentId, type)),
    );
    if (isClosed) return;
    final categories = results
        .whereType<Success<List<OperatingExpenseCategory>>>()
        .expand((item) => item.data)
        .toList();
    emit(state.copyWith(categories: categories));
  }

  Future<void> _refreshRemoteCatalog() async {
    final result = await _refreshCatalog(establishmentId);
    if (isClosed) return;
    if (result case Success<List<OperatingExpenseCategory>>(:final data)) {
      emit(state.copyWith(categories: data));
    }
  }

  String _messageFor(DomainException error) => OperatingExpenseStrings.failureMessage(error);

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}

import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';

part 'operating_expense_cubit.freezed.dart';

/// Estado integral del formulario de egresos.
@freezed
sealed class OperatingExpenseState with _$OperatingExpenseState {
  /// Crea el estado inicial con costo de produccion y fecha actual.
  const factory OperatingExpenseState({
    required OperatingExpenseType type,
    required DateTime date,
    @Default(<OperatingExpenseCategory>[]) List<OperatingExpenseCategory> categories,
    @Default(ResultState<void>.initial()) ResultState<void> saveState,
    String? selectedCategory,
    String? selectedCustomCategoryId,
    OperatingExpense? savedExpense,
    String? errorMessage,
  }) = _OperatingExpenseState;
}

/// Coordina catálogo y alta local sin acceder a infraestructura.
class OperatingExpenseCubit extends Cubit<OperatingExpenseState> {
  /// Crea el cubit para el establecimiento y usuario autenticados.
  OperatingExpenseCubit({
    required this.establishmentId,
    required this.userId,
    required this.userName,
    required CreateOperatingExpenseUseCase createExpense,
    required OperatingExpenseCatalogUseCase catalog,
    DateTime Function()? now,
    String Function()? createId,
  }) : _createExpense = createExpense,
       _catalog = catalog,
       _now = now ?? DateTime.now,
       _createId = createId ?? _fallbackId,
       super(OperatingExpenseState(type: OperatingExpenseType.productionCost, date: (now ?? DateTime.now)()));

  /// UUID del establecimiento activo.
  final String establishmentId;

  /// UUID del usuario autenticado.
  final String userId;

  /// Nombre visible usado para auditoria offline.
  final String userName;
  final CreateOperatingExpenseUseCase _createExpense;
  final OperatingExpenseCatalogUseCase _catalog;
  final DateTime Function() _now;
  final String Function() _createId;

  /// Carga el catálogo local necesario para completar el formulario.
  Future<void> load() => _loadCategories();

  /// Cambia el tipo y limpia una categoria que dejo de ser compatible.
  Future<void> selectType(OperatingExpenseType type) async {
    emit(state.copyWith(type: type, selectedCategory: null, selectedCustomCategoryId: null, errorMessage: null));
    await _loadCategories();
  }

  /// Selecciona una categoria del catalogo actual.
  void selectCategory(String? value) {
    final selected = state.categories.where((item) => item.value == value).firstOrNull;
    emit(state.copyWith(selectedCategory: value, selectedCustomCategoryId: selected?.id, errorMessage: null));
  }

  /// Actualiza la fecha elegida.
  void selectDate(DateTime value) => emit(state.copyWith(date: value, errorMessage: null));

  /// Crea una categoria offline y la selecciona.
  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;
    final result = await _catalog.createCategory(establishmentId, state.type, name);
    switch (result) {
      case Success<OperatingExpenseCategory>(:final data):
        await _loadCategories();
        selectCategory(data.value);
      case Failure<OperatingExpenseCategory>(:final error):
        emit(state.copyWith(errorMessage: error.message));
    }
  }

  /// Valida y persiste el alta local; no espera confirmacion remota.
  Future<bool> save({
    required int amountCents,
    required String supply,
    required String description,
    required String receiptNumber,
  }) async {
    if (state.saveState is Loading<void>) return false;
    final timestamp = _now().toUtc();
    final expense = OperatingExpense(
      id: _createId(),
      establishmentId: establishmentId,
      amountCents: amountCents,
      type: state.type,
      category: state.selectedCategory ?? '',
      supply: supply.trim(),
      date: state.date,
      description: description.trim().isEmpty ? null : description.trim(),
      receiptNumber: receiptNumber.trim().isEmpty ? null : receiptNumber.trim(),
      loadedById: userId,
      loadedByName: userName,
      createdAt: timestamp,
      updatedAt: timestamp,
      customCategoryId: state.selectedCustomCategoryId,
      syncStatus: OperatingExpenseSyncStatus.pending,
    );
    emit(state.copyWith(saveState: const ResultState.loading(), errorMessage: null));
    final result = await _createExpense(expense: expense, categories: state.categories, today: _now());
    if (result case Success<OperatingExpense>(:final data)) {
      return _saved(data);
    }
    if (result case Failure<OperatingExpense>(:final error)) {
      return _failed(error.message);
    }
    return _failed('No se pudo guardar el egreso en el dispositivo.');
  }

  /// Prepara el estado para registrar otro egreso en el mismo establecimiento.
  void startAnotherExpense() {
    emit(
      state.copyWith(
        date: _now(),
        saveState: const ResultState.initial(),
        selectedCategory: null,
        selectedCustomCategoryId: null,
        savedExpense: null,
        errorMessage: null,
      ),
    );
  }

  bool _saved(OperatingExpense expense) {
    emit(
      state.copyWith(
        saveState: const ResultState.data(null),
        savedExpense: expense,
      ),
    );
    return true;
  }

  bool _failed(String message) {
    emit(
      state.copyWith(
        saveState: ResultState.error(DomainException(message: message)),
        errorMessage: message,
      ),
    );
    return false;
  }

  Future<void> _loadCategories() async {
    final result = await _catalog.getCategories(establishmentId, state.type);
    switch (result) {
      case Success<List<OperatingExpenseCategory>>(:final data):
        emit(state.copyWith(categories: data));
      case Failure<List<OperatingExpenseCategory>>(:final error):
        emit(state.copyWith(errorMessage: error.message));
    }
  }

  static String _fallbackId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/use_cases/operating_expense_use_cases.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

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
       _createId = createId ?? generateUuidV4,
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
    final result = await _catalog.createCategory(establishmentId, state.type, name);
    switch (result) {
      case Success<OperatingExpenseCategory>(:final data):
        await _loadCategories();
        selectCategory(data.value);
      case Failure<OperatingExpenseCategory>(:final error):
        emit(state.copyWith(errorMessage: _messageFor(error)));
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
      return _failed(_messageFor(error));
    }
    return _failed(OperatingExpenseStrings.saveError);
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
        emit(state.copyWith(errorMessage: _messageFor(error)));
    }
  }

  String _messageFor(DomainException error) => OperatingExpenseStrings.failureMessage(error);
}

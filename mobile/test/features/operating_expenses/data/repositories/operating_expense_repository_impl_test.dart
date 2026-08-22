import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/repositories/operating_expense_repository_impl.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';

void main() {
  group('OperatingExpenseRepositoryImpl', () {
    test('devuelve el catalogo de dominio junto con las categorias custom', () async {
      final repository = _repository(
        categoryStore: _FakeCategoryStore(onGet: () async => const []),
      );

      final result = await repository.getCategories(
        establishmentId: 'establishment-id',
        type: OperatingExpenseType.productionCost,
      );

      final categories = (result as Success<List<OperatingExpenseCategory>>).data;
      expect(categories.map((category) => category.value), ['sanidad', 'alimentacion', 'identificacion']);
    });

    test('convierte una excepcion esperada de Brick en un error tipado', () async {
      final repository = _repository(
        categoryStore: _FakeCategoryStore(
          onGet: () => throw OfflineFirstException(Exception('sqlite unavailable')),
        ),
      );

      final result = await repository.getCategories(
        establishmentId: 'establishment-id',
        type: OperatingExpenseType.productionCost,
      );

      expect(
        (result as Failure<List<OperatingExpenseCategory>>).error.reason,
        OperatingExpensePersistenceError.loadCategories,
      );
    });

    test('deja propagar errores de programacion inesperados', () {
      final repository = _repository(
        categoryStore: _FakeCategoryStore(
          onGet: () => throw StateError('unexpected mapping state'),
        ),
      );

      expect(
        () => repository.getCategories(
          establishmentId: 'establishment-id',
          type: OperatingExpenseType.productionCost,
        ),
        throwsStateError,
      );
    });
  });
}

OperatingExpenseRepositoryImpl _repository({
  required OperatingExpenseCategoryBrickStore categoryStore,
}) => OperatingExpenseRepositoryImpl(
  expenseStore: _FakeExpenseStore(),
  categoryStore: categoryStore,
);

class _FakeCategoryStore implements OperatingExpenseCategoryBrickStore {
  _FakeCategoryStore({required this.onGet});

  final Future<List<BrickOperatingExpenseCategoryModel>> Function() onGet;

  @override
  Future<List<BrickOperatingExpenseCategoryModel>> getLocalCategories({
    required String establishmentId,
    required String type,
  }) => onGet();

  @override
  Future<BrickOperatingExpenseCategoryModel?> getById(String id) => throw UnimplementedError();

  @override
  Future<BrickOperatingExpenseCategoryModel> upsertCategory(
    BrickOperatingExpenseCategoryModel category,
  ) => throw UnimplementedError();
}

class _FakeExpenseStore implements OperatingExpenseBrickStore {
  @override
  Future<List<BrickOperatingExpenseModel>> getLocalExpenses(String? establishmentId) => throw UnimplementedError();

  @override
  Future<void> pullRemoteExpenses(String establishmentId) => throw UnimplementedError();

  @override
  Future<BrickOperatingExpenseModel> upsertExpense(BrickOperatingExpenseModel expense) => throw UnimplementedError();
}

import 'package:frontend_mayoral/brick/mappers/animal_productive_status_mapper.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/formatters/decimal_amount_formatter.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard_source.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';

/// Lee y mapea los datos locales que usa el tablero productivo.
class HomeDashboardRepositoryImpl implements HomeDashboardRepository {
  /// Crea el repositorio con los stores offline-first necesarios.
  HomeDashboardRepositoryImpl({
    required AnimalBrickStore animalStore,
    required CategoriaBrickStore categoryStore,
    required PesajeBrickStore pesajeStore,
    required SecureStorageService secureStorage,
    required OperatingExpenseBrickStore operatingExpenseStore,
  }) : _animalStore = animalStore,
       _categoryStore = categoryStore,
       _pesajeStore = pesajeStore,
       _establishmentCatalog = EstablishmentCatalog(
         secureStorage: secureStorage,
       ),
       _operatingExpenseStore = operatingExpenseStore;

  final AnimalBrickStore _animalStore;
  final CategoriaBrickStore _categoryStore;
  final PesajeBrickStore _pesajeStore;
  final EstablishmentCatalog _establishmentCatalog;
  final OperatingExpenseBrickStore _operatingExpenseStore;

  @override
  Future<Result<HomeDashboardSource>> getDashboardSource({
    Set<String>? establishmentIds,
  }) async {
    try {
      final storedAnimals = await _animalStore.getLocalAnimals();
      final animals = establishmentIds == null
          ? storedAnimals
          : storedAnimals
                .where(
                  (animal) => establishmentIds.contains(animal.establishmentId),
                )
                .toList();
      final weighings = await _pesajeStore.getLocalPesajes();
      final categories = await _categoryStore.getLocalCategorias();

      return Result.success(
        HomeDashboardSource(
          animals: [
            for (final animal in animals)
              HomeDashboardAnimal(
                id: animal.localId,
                productiveStatus: animal.productiveStatus.toDomain(),
                createdAt: animal.createdAt,
                deletedAt: animal.deletedAt,
                productiveStatusChangedAt: animal.productiveStatusChangedAt,
                categoryId: animal.categoryId,
                categoryName: animal.categoryName,
                lotName: animal.lotName,
                initialWeightKg: animal.initialWeight,
                initialWeighingDate: animal.weighingDate,
              ),
          ],
          weighings: [
            for (final weighing in weighings)
              HomeDashboardWeighing(
                animalId: weighing.animalId,
                weightKg: weighing.weightKg,
                date: weighing.date,
              ),
          ],
          categoryNamesById: {
            for (final category in categories) category.localId: category.name,
          },
          operatingExpensesCents: await _expensesFor(establishmentIds),
        ),
      );
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron leer los indicadores productivos.',
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments() async {
    try {
      final memberships = await _establishmentCatalog.getMemberships();
      return Result.success({
        for (final membership in memberships) membership.id: membership,
      });
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron leer los establecimientos disponibles.',
        ),
      );
    }
  }

  Future<int> _expensesFor(Set<String>? establishmentIds) async {
    if (establishmentIds == null) {
      return _sumExpenses(await _operatingExpenseStore.getLocalExpenses(null));
    }
    var total = 0;
    for (final id in establishmentIds) {
      total += _sumExpenses(
        await _operatingExpenseStore.getLocalExpenses(id),
      );
    }
    return total;
  }

  int _sumExpenses(Iterable<BrickOperatingExpenseModel> expenses) => expenses.fold(
    0,
    (total, expense) => total + DecimalAmountFormatter.decimalToCents(expense.amount),
  );
}

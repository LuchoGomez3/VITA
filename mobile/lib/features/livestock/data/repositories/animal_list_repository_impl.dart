import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/animal_list_repository.dart';
import 'package:logging/logging.dart';

/// Arma la lista de animales con lo guardado en SQLite (offline-first).
///
/// Los animales que se bajan del backend llegan sin el nombre de la categoría
/// ni del potrero (solo sus ids), así que se completan con los catálogos
/// locales. El último peso sale de la misma serie que usa el tablero de Inicio:
/// el peso inicial del alta más los pesajes posteriores.
class AnimalListRepositoryImpl implements AnimalListRepository {
  /// Crea el repositorio sobre los stores locales de Brick.
  AnimalListRepositoryImpl({
    required AnimalBrickStore animalStore,
    required PesajeBrickStore pesajeStore,
    required CategoriaBrickStore categoryStore,
    required LotBrickStore lotStore,
    required EstablishmentCatalog establishmentCatalog,
  }) : _establishmentCatalog = establishmentCatalog,
       _animalStore = animalStore,
       _pesajeStore = pesajeStore,
       _categoryStore = categoryStore,
       _lotStore = lotStore;

  static final _logger = Logger('AnimalListRepositoryImpl');

  final AnimalBrickStore _animalStore;
  final PesajeBrickStore _pesajeStore;
  final CategoriaBrickStore _categoryStore;
  final LotBrickStore _lotStore;
  final EstablishmentCatalog _establishmentCatalog;

  @override
  Future<Result<List<EstablishmentMembership>>> getEstablishments() async {
    try {
      return Result.success(await _establishmentCatalog.getMemberships());
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudieron leer los establecimientos', error, stackTrace);
      return const Result.failure(
        DomainException(message: 'No se pudieron leer tus establecimientos.'),
      );
    }
  }

  @override
  Future<Result<List<AnimalListEntry>>> getAnimals() async {
    try {
      final animals = (await _animalStore.getLocalAnimals()).where((animal) => animal.deletedAt == null).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final weighings = await _pesajeStore.getLocalPesajes();
      final categoryNames = {
        for (final category in await _categoryStore.getLocalCategorias()) category.localId: category.name,
      };
      final lotNames = <String, String>{};
      for (final establishmentId in animals.map((animal) => animal.establishmentId).toSet()) {
        for (final lot in await _lotStore.getLocalLots(establishmentId)) {
          lotNames[lot.localId] = lot.name;
        }
      }

      final lastWeighingByAnimal = <String, BrickPesajeModel>{};
      for (final weighing in weighings) {
        if (weighing.weightKg <= 0) {
          continue;
        }
        final current = lastWeighingByAnimal[weighing.animalId];
        if (current == null || weighing.date.isAfter(current.date)) {
          lastWeighingByAnimal[weighing.animalId] = weighing;
        }
      }

      return Result.success([
        for (final animal in animals) _toEntry(animal, lastWeighingByAnimal[animal.localId], categoryNames, lotNames),
      ]);
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudo leer la lista de animales', error, stackTrace);
      return const Result.failure(
        DomainException(message: 'No se pudieron leer los animales guardados en el celular.'),
      );
    }
  }

  AnimalListEntry _toEntry(
    BrickAnimalModel animal,
    BrickPesajeModel? lastWeighing,
    Map<String, String> categoryNames,
    Map<String, String> lotNames,
  ) {
    final initialWeight = animal.initialWeight;
    final hasInitialWeight = initialWeight != null && initialWeight > 0;
    final useWeighing = lastWeighing != null && (!hasInitialWeight || !lastWeighing.date.isBefore(animal.weighingDate));

    return AnimalListEntry(
      id: animal.localId,
      establishmentId: animal.establishmentId,
      visualTag: animal.visualTag,
      rfidTagNumber: animal.rfidTagNumber,
      breed: animal.breed,
      categoryName: animal.categoryName.isNotEmpty ? animal.categoryName : categoryNames[animal.categoryId] ?? '',
      lotName: animal.lotName.isNotEmpty ? animal.lotName : lotNames[animal.lotId] ?? '',
      lastWeightKg: useWeighing ? lastWeighing.weightKg : (hasInitialWeight ? initialWeight : null),
      lastWeighingDate: useWeighing ? lastWeighing.date : (hasInitialWeight ? animal.weighingDate : null),
    );
  }
}

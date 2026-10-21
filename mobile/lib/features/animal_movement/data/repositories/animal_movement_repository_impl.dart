import 'dart:convert';

import 'package:frontend_mayoral/brick/mappers/animal_productive_status_mapper.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:logging/logging.dart';

/// Lee animales, potreros y movimientos de SQLite: todo funciona sin señal.
class AnimalMovementRepositoryImpl implements AnimalMovementRepository {
  /// Crea el repositorio sobre los stores de Brick.
  const AnimalMovementRepositoryImpl({
    required AnimalBrickStore animalStore,
    required LotBrickStore lotStore,
    required CategoriaBrickStore categoryStore,
    required AnimalLotMovementBrickStore movementStore,
  }) : _animalStore = animalStore,
       _lotStore = lotStore,
       _categoryStore = categoryStore,
       _movementStore = movementStore;

  static final _logger = Logger('AnimalMovementRepository');

  final AnimalBrickStore _animalStore;
  final LotBrickStore _lotStore;
  final CategoriaBrickStore _categoryStore;
  final AnimalLotMovementBrickStore _movementStore;

  @override
  Future<Result<MovementAnimal?>> getAnimal(String animalId) => _guard('el animal', () async {
    final animal = await _animalStore.getAnimalById(animalId);
    return animal == null || !_isMovable(animal) ? null : await _toMovementAnimal(animal);
  });

  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(String tag) => _guard('la caravana', () async {
    final digits = tag.replaceAll(RegExp(r'\D'), '');
    final visual = _normalizeVisualTag(tag);
    for (final animal in await _animalStore.getLocalAnimals()) {
      if (!_isMovable(animal)) {
        continue;
      }
      final matchesRfid = digits.length == 15 && animal.rfidTagNumber.replaceAll(RegExp(r'\D'), '') == digits;
      if (matchesRfid || _normalizeVisualTag(animal.visualTag) == visual) {
        return _toMovementAnimal(animal);
      }
    }
    return null;
  });

  @override
  Future<Result<List<MovementDestination>>> getDestinations(String establishmentId) => _guard('los potreros', () async {
    final counts = <String, int>{};
    for (final animal in await _animalStore.getLocalAnimals()) {
      if (_isMovable(animal) && animal.establishmentId == establishmentId) {
        counts.update(animal.lotId, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    final lots =
        (await _lotStore.getLocalLots(
            establishmentId,
          )).where((lot) => lot.deletedAt == null && LotStatus.fromCode(lot.statusCode) == LotStatus.active).toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return [
      for (final lot in lots)
        MovementDestination(id: lot.localId, name: lot.name, animalCount: counts[lot.localId] ?? 0),
    ];
  });

  @override
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId) => _guard('el historial', () async {
    final animal = await _animalStore.getAnimalById(animalId);
    if (animal == null) {
      return const <MovementHistoryEntry>[];
    }
    final lotNames = {
      for (final lot in await _lotStore.getLocalLots(animal.establishmentId)) lot.localId: lot.name,
    };
    final entries = <MovementHistoryEntry>[];
    for (final movement in await _movementStore.getLocalMovements(animal.establishmentId)) {
      if (!_includesAnimal(movement, animalId)) {
        continue;
      }
      final sourceLotId = movement.sourceLotId;
      entries.add(
        MovementHistoryEntry(
          movementId: movement.localId,
          fromLotName: sourceLotId == null ? null : lotNames[sourceLotId] ?? '',
          toLotName: lotNames[movement.destinationLotId] ?? '',
          occurredAt: movement.occurredAt,
          reason: movement.reason,
          isPending: movement.syncStatus != BrickAnimalLotMovementSyncStatus.synchronized,
        ),
      );
    }
    entries.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return entries;
  });

  bool _isMovable(BrickAnimalModel animal) =>
      animal.deletedAt == null && animal.productiveStatus.toDomain().isInProductiveStock && animal.lotId.isNotEmpty;

  bool _includesAnimal(BrickAnimalLotMovementModel movement, String animalId) {
    final decoded = jsonDecode(movement.animalIdsJson);
    return decoded is List && decoded.contains(animalId);
  }

  Future<MovementAnimal> _toMovementAnimal(BrickAnimalModel animal) async {
    var categoryName = animal.categoryName;
    if (categoryName.isEmpty) {
      for (final category in await _categoryStore.getLocalCategorias()) {
        if (category.localId == animal.categoryId) {
          categoryName = category.name;
        }
      }
    }
    final lotName = animal.lotName.isNotEmpty
        ? animal.lotName
        : (await _lotStore.getLocalLot(animal.lotId))?.name ?? '';
    return MovementAnimal(
      id: animal.localId,
      establishmentId: animal.establishmentId,
      visualTag: animal.visualTag,
      rfidTagNumber: animal.rfidTagNumber,
      breed: animal.breed,
      categoryName: categoryName,
      lotId: animal.lotId,
      lotName: lotName,
    );
  }

  static String _normalizeVisualTag(String tag) => tag.replaceAll(RegExp(r'\s'), '').toLowerCase();

  Future<Result<T>> _guard<T>(String what, Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudo leer $what', error, stackTrace);
      return Result.failure(DomainException(message: 'No se pudo leer $what guardado en el celular.'));
    }
  }
}

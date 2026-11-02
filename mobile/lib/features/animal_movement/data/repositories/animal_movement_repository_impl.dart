import 'dart:convert';

import 'package:frontend_mayoral/brick/mappers/animal_productive_status_mapper.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/errors/movement_failure.dart';
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
    required Stream<Type> localChanges,
  }) : _animalStore = animalStore,
       _lotStore = lotStore,
       _categoryStore = categoryStore,
       _movementStore = movementStore,
       _localChanges = localChanges;

  static final _logger = Logger('AnimalMovementRepository');

  final AnimalBrickStore _animalStore;
  final LotBrickStore _lotStore;
  final CategoriaBrickStore _categoryStore;
  final AnimalLotMovementBrickStore _movementStore;
  final Stream<Type> _localChanges;

  @override
  Stream<void> get historyChanges => _localChanges
      .where((type) => type == BrickAnimalModel || type == BrickAnimalLotMovementModel || type == BrickLotModel)
      .map((_) {});

  @override
  Future<Result<MovementAnimal?>> getAnimal(String animalId) => _guard(MovementReadTarget.animal, () async {
    final animal = await _animalStore.getAnimalById(animalId);
    return animal == null || !_isMovable(animal) ? null : await _toMovementAnimal(animal);
  });

  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(String tag, {required String establishmentId}) =>
      _guard(MovementReadTarget.tag, () async {
        final digits = tag.replaceAll(RegExp(r'\D'), '');
        final visual = _normalizeVisualTag(tag);
        final animals = (await _animalStore.getLocalAnimals())
            .where((animal) => animal.establishmentId == establishmentId)
            .toList();
        final rfidMatches = digits.length == 15
            ? animals.where((animal) => animal.rfidTagNumber.replaceAll(RegExp(r'\D'), '') == digits).toList()
            : <BrickAnimalModel>[];
        // Un RFID reconocido no se reinterpreta como visual de otro animal
        // aunque su dueño ya no pueda trasladarse.
        final candidates = rfidMatches.isNotEmpty
            ? rfidMatches
            : animals.where((animal) => _normalizeVisualTag(animal.visualTag) == visual).toList();
        final matches = candidates.where(_isMovable).toList();
        if (rfidMatches.isNotEmpty && matches.isEmpty) {
          throw movementException(const MovementFailure.animalUnavailable());
        }
        if (matches.length > 1) {
          throw movementException(MovementFailure.ambiguousTag(tag));
        }
        return matches.isEmpty ? null : _toMovementAnimal(matches.single);
      });

  @override
  Future<Result<List<MovementDestination>>> getDestinations(String establishmentId) => _guard(
    MovementReadTarget.destinations,
    () async {
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
    },
  );

  @override
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId) =>
      _guard(MovementReadTarget.history, () async {
        final animal = await _animalStore.getAnimalById(animalId);
        if (animal == null) {
          return const <MovementHistoryEntry>[];
        }
        final lotNames = {
          for (final lot in await _lotStore.getLocalLots(animal.establishmentId, includeDeleted: true))
            lot.localId: lot.name,
        };
        final entries = <MovementHistoryEntry>[];
        final movements =
            (await _movementStore.getLocalMovements(
                animal.establishmentId,
              )).where((movement) => _includesAnimal(movement, animalId)).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final current = movements
            .where(
              (movement) =>
                  movement.destinationLotId == animal.lotId &&
                  movement.syncStatus != BrickAnimalLotMovementSyncStatus.rejected,
            )
            .firstOrNull;
        for (final movement in movements) {
          final sourceLotId = movement.sourceLotId;
          entries.add(
            MovementHistoryEntry(
              movementId: movement.localId,
              fromLotName: sourceLotId == null ? null : lotNames[sourceLotId] ?? '',
              toLotName: lotNames[movement.destinationLotId] ?? '',
              occurredAt: movement.occurredAt,
              reason: movement.reason,
              syncStatus: switch (movement.syncStatus) {
                BrickAnimalLotMovementSyncStatus.pending => MovementSyncStatus.pending,
                BrickAnimalLotMovementSyncStatus.synchronized => MovementSyncStatus.synchronized,
                BrickAnimalLotMovementSyncStatus.rejected => MovementSyncStatus.rejected,
              },
              isCurrent: movement.localId == current?.localId,
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

  Future<Result<T>> _guard<T>(MovementReadTarget target, Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on DomainException catch (error) {
      return Result.failure(error);
    } on Object catch (error, stackTrace) {
      _logger.severe('Local movement read failed: ${target.name}', error, stackTrace);
      return Result.failure(movementException(MovementFailure.localRead(target), code: DomainErrorCode.unknown));
    }
  }
}

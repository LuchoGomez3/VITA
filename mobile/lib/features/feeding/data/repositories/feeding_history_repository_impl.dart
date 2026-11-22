import 'dart:convert';

import 'package:frontend_mayoral/brick/mappers/animal_productive_status_mapper.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/feeding_record.model.dart';
import 'package:frontend_mayoral/brick/models/food.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/models/lot_forage_period.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/feeding_record_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/food_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_forage_period_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/feeding/data/mappers/feeding_brick_mapper.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/repositories/feeding_repositories.dart';
import 'package:frontend_mayoral/features/feeding/domain/services/grazing_history_builder.dart';
import 'package:logging/logging.dart';

/// Arma el historial de alimentación con lo que hay en SQLite.
class FeedingHistoryRepositoryImpl implements FeedingHistoryRepository {
  /// Crea el repositorio sobre los stores de Brick.
  FeedingHistoryRepositoryImpl({
    required AnimalBrickStore animalStore,
    required AnimalLotMovementBrickStore movementStore,
    required LotBrickStore lotStore,
    required LotForagePeriodBrickStore periodStore,
    required FoodBrickStore foodStore,
    required FeedingRecordBrickStore recordStore,
    required Stream<Type> localChanges,
    DateTime Function()? now,
  }) : _animalStore = animalStore,
       _movementStore = movementStore,
       _lotStore = lotStore,
       _periodStore = periodStore,
       _foodStore = foodStore,
       _recordStore = recordStore,
       _localChanges = localChanges,
       _now = now ?? DateTime.now;

  final AnimalBrickStore _animalStore;
  final AnimalLotMovementBrickStore _movementStore;
  final LotBrickStore _lotStore;
  final LotForagePeriodBrickStore _periodStore;
  final FoodBrickStore _foodStore;
  final FeedingRecordBrickStore _recordStore;
  final Stream<Type> _localChanges;
  final DateTime Function() _now;
  static final _logger = Logger('FeedingHistoryRepository');

  static const _relevantTypes = {
    BrickAnimalModel,
    BrickAnimalLotMovementModel,
    BrickLotModel,
    BrickLotForagePeriodModel,
    BrickFoodModel,
    BrickFeedingRecordModel,
  };

  @override
  Stream<void> get changes => _localChanges.where(_relevantTypes.contains).map((_) {});

  @override
  Future<Result<AnimalFeedingHistory>> getAnimalHistory(String animalId) async {
    try {
      final animal = await _animalStore.getAnimalById(animalId);
      if (animal == null) {
        return const Result.failure(
          DomainException(message: 'El animal no está disponible en este celular.', code: DomainErrorCode.notFound),
        );
      }
      final establishmentId = animal.establishmentId;
      final lots = await _lotStore.getLocalLots(establishmentId, includeDeleted: true);
      final lotNames = {for (final lot in lots) lot.localId: lot.name};
      final periods = await _periodStore.getLocalPeriods(establishmentId);
      final movements = (await _movementStore.getLocalMovements(establishmentId))
          .where(
            (m) => m.syncStatus != BrickAnimalLotMovementSyncStatus.rejected && _includes(m.animalIdsJson, animalId),
          )
          .toList();
      final productiveStatus = animal.productiveStatus.toDomain();

      final grazing = GrazingHistoryBuilder.build(
        animal: GrazingAnimalSnapshot(
          createdAt: animal.createdAt,
          updatedAt: animal.updatedAt,
          currentLotId: animal.lotId,
          exitedAt: productiveStatus.isInProductiveStock ? null : animal.productiveStatusChangedAt ?? animal.updatedAt,
        ),
        movements: [
          for (final m in movements)
            GrazingMovement(
              occurredAt: m.occurredAt,
              createdAt: m.createdAt,
              sourceLotId: m.sourceLotId,
              destinationLotId: m.destinationLotId,
              pending: m.syncStatus == BrickAnimalLotMovementSyncStatus.pending,
            ),
        ],
        periods: [
          for (final p in periods)
            GrazingForagePeriod(
              lotId: p.lotId,
              resourceCode: p.forageResourceCode,
              description: p.description,
              startDate: FeedingBrickMapper.parseDate(p.startDate),
              endDate: p.endDate == null ? null : FeedingBrickMapper.parseDate(p.endDate!),
            ),
        ],
        lotNames: lotNames,
        today: _now(),
      );

      final foodNames = {
        for (final food in await _foodStore.getLocalFoods(establishmentId)) food.localId: food.name,
      };
      final today = _day(_now());
      final supplements = [
        for (final record in await _recordStore.getLocalRecords(establishmentId))
          if (_includes(record.animalIdsJson, animalId))
            FeedingBrickMapper.toSupplementEntry(
              record,
              foodName: foodNames[record.foodId],
              lotName: record.lotId == null ? null : lotNames[record.lotId],
            ),
      ];

      final entries = <FeedingTimelineEntry>[...grazing, ...supplements]
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
      final current = grazing.where((g) => g.to == null).firstOrNull;
      final currentLot = lots.where((lot) => lot.localId == animal.lotId).firstOrNull;
      return Result.success(
        AnimalFeedingHistory(
          entries: entries,
          currentGrazing: current,
          ongoingSupplements: [
            for (final s in supplements)
              if (s.to == null || !s.to!.isBefore(today)) s,
          ],
          currentLotId: animal.lotId.isEmpty ? null : animal.lotId,
          currentLotHasForage: periods.any((p) => p.lotId == animal.lotId) || (currentLot?.forageResourceCode != null),
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudo armar el historial de alimentación.', error, stackTrace);
      return const Result.failure(
        DomainException(
          message: 'No se pudo leer la alimentación guardada en el celular.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }

  static bool _includes(String animalIdsJson, String animalId) {
    final decoded = jsonDecode(animalIdsJson);
    return decoded is List && decoded.contains(animalId);
  }

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}

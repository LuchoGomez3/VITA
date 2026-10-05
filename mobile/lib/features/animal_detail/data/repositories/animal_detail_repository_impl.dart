import 'dart:convert';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/animal_observation.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_observation_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/data/mappers/animal_detail_mapper.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';
import 'package:logging/logging.dart';

/// Implementacion offline-first del repository de detalle de animal.
class AnimalDetailRepositoryImpl implements AnimalDetailRepository {
  /// Crea el repository con cache Brick y fuente remota.
  const AnimalDetailRepositoryImpl({
    required AnimalObservationBrickStore observationStore,
    required AnimalPhotoStore photoStore,
    required AnimalBrickStore brickStore,
    required CategoriaBrickStore categoriaBrickStore,
    required PesajeBrickStore pesajeBrickStore,
    required AnimalDetailRemoteDataSource remoteDataSource,
    BrickAnimalLotMovementStore? movementStore,
    LotBrickStore? lotStore,
  }) : _movementStore = movementStore,
       _lotStore = lotStore,
       _observationStore = observationStore,
       _photoStore = photoStore,
       _brickStore = brickStore,
       _categoriaBrickStore = categoriaBrickStore,
       _pesajeBrickStore = pesajeBrickStore,
       _remoteDataSource = remoteDataSource;

  static final _logger = Logger('AnimalDetailRepository');
  final AnimalObservationBrickStore _observationStore;
  final BrickAnimalLotMovementStore? _movementStore;
  final LotBrickStore? _lotStore;
  final AnimalPhotoStore _photoStore;
  final AnimalBrickStore _brickStore;
  final CategoriaBrickStore _categoriaBrickStore;
  final PesajeBrickStore _pesajeBrickStore;
  final AnimalDetailRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AnimalDetail>> getById(String animalId, {bool refreshRemote = true}) async {
    try {
      final localAnimal = await _brickStore.getAnimalById(animalId);
      if (localAnimal != null) {
        var refreshedAnimal = localAnimal;
        if (refreshRemote) {
          try {
            await _brickStore.pullRemoteAnimals(localAnimal.establishmentId);
            refreshedAnimal = await _brickStore.getAnimalById(animalId) ?? localAnimal;
          } on Object catch (error, stackTrace) {
            _logger.fine('Se conserva la ficha local sin conexión.', error, stackTrace);
          }
        }
        return Result.success(
          await _enrichDetail(AnimalDetailMapper.fromBrick(refreshedAnimal), refreshRemote: refreshRemote),
        );
      }

      if (!refreshRemote) {
        return const Result.failure(
          DomainException(message: 'Animal no encontrado.', reason: AnimalDetailEditFailure.animalNotFound),
        );
      }
      // TODO(equipo): Analizar si este fallback remoto debe quedar en la feature.
      // El flujo objetivo es offline-first; esta consulta solo cubre animales
      // que todavia no fueron hidratados en SQLite.
      final remoteAnimal = await _remoteDataSource.getAnimalById(animalId);
      await _brickStore.cacheAnimal(
        AnimalDetailMapper.toBrickCache(remoteAnimal),
      );
      return Result.success(
        await _enrichDetail(AnimalDetailMapper.fromBackend(remoteAnimal)),
      );
    } on DomainException catch (error) {
      return Result.failure(error);
    } on FormatException {
      return const Result.failure(
        DomainException(
          message: 'El detalle del animal tiene datos invalidos.',
        ),
      );
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudo cargar la información del animal.',
        ),
      );
    }
  }

  @override
  Future<Result<AnimalDetail>> applyChange(String animalId, AnimalDetailChange change) async {
    try {
      final animal = await _brickStore.getAnimalById(animalId);
      if (animal == null) {
        return const Result.failure(
          DomainException(message: 'Animal no encontrado.', reason: AnimalDetailEditFailure.animalNotFound),
        );
      }
      // Una corrección siempre debe tener una versión posterior, aun si el reloj
      // del dispositivo volvió atrás o dos pulsaciones ocurrieron en el mismo ms.
      final now = DateTime.now().toUtc();
      final timestamp = now.isAfter(animal.updatedAt) ? now : animal.updatedAt.add(const Duration(milliseconds: 1));
      switch (change) {
        case RecordAnimalWeight(:final weightKg, :final date):
          await _pesajeBrickStore.upsertPesaje(
            BrickPesajeModel(
              localId: generateUuidV4(),
              establishmentId: animal.establishmentId,
              animalId: animal.localId,
              weightKg: weightKg,
              date: date,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
        case AddAnimalObservation(:final text, :final date):
          await _observationStore.addObservation(
            BrickAnimalObservationModel(
              localId: generateUuidV4(),
              establishmentId: animal.establishmentId,
              animalId: animal.localId,
              text: text,
              date: date,
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
        case ChangeAnimalCategory(:final categoryId):
          await _brickStore.updateAnimal(
            animal.copyWith(
              categoryId: categoryId,
              syncStatus: BrickAnimalSyncStatus.pending,
              syncErrorCode: null,
              updatedAt: timestamp,
            ),
          );
        case ChangeAnimalReproduction(:final status):
          await _brickStore.updateAnimal(
            animal.copyWith(
              reproductiveStatus: _reproductionCode(status),
              syncStatus: BrickAnimalSyncStatus.pending,
              syncErrorCode: null,
              updatedAt: timestamp,
            ),
          );
        case RecordAnimalDeath():
          await _brickStore.updateAnimal(
            animal.copyWith(
              status: 'muerto',
              syncStatus: BrickAnimalSyncStatus.pending,
              syncErrorCode: null,
              updatedAt: timestamp,
            ),
          );
        case UndoAnimalDeath(:final previousStatus, :final deathUpdatedAt):
          if (animal.status != 'muerto' || animal.updatedAt != deathUpdatedAt) {
            return const Result.failure(
              DomainException(message: 'La baja ya cambió.', reason: AnimalDetailEditFailure.staleUndo),
            );
          }
          await _brickStore.updateAnimal(
            animal.copyWith(
              status: _statusCode(previousStatus),
              syncStatus: BrickAnimalSyncStatus.pending,
              syncErrorCode: null,
              updatedAt: timestamp,
            ),
          );
      }
      final savedAnimal = await _brickStore.getAnimalById(animalId);
      return Result.success(await _enrichDetail(AnimalDetailMapper.fromBrick(savedAnimal!), refreshRemote: false));
    } on Object catch (error, stackTrace) {
      _logger.warning('No se pudo guardar la edición local.', error, stackTrace);
      return const Result.failure(
        DomainException(message: 'No se pudo guardar el cambio.', reason: AnimalDetailEditFailure.saveFailed),
      );
    }
  }

  String? _reproductionCode(AnimalReproductiveStatus? status) => switch (status) {
    null => null,
    AnimalReproductiveStatus.undetermined => 'sin_determinar',
    AnimalReproductiveStatus.empty => 'vacia',
    AnimalReproductiveStatus.pregnant => 'prenada',
  };

  String _statusCode(AnimalStatus status) => switch (status) {
    AnimalStatus.active => 'activo',
    AnimalStatus.dead => 'muerto',
    AnimalStatus.sold => 'vendido',
    AnimalStatus.inactive => 'baja',
  };

  /// Refresca datos relacionados y siempre termina leyendo la cache local.
  ///
  /// Los errores del pull no invalidan la ficha: en campo puede no haber red y
  /// tanto los pesajes como las categorias deben seguir disponibles en SQLite.
  Future<AnimalDetail> _enrichDetail(AnimalDetail detail, {bool refreshRemote = true}) async {
    List<BrickPesajeModel> localPesajes;
    try {
      if (!refreshRemote) {
        localPesajes = await _pesajeBrickStore.getLocalPesajesByAnimal(detail.id);
      } else {
        await _pesajeBrickStore.pullRemotePesajes(detail.establishmentId, animalId: detail.id);
        localPesajes = await _pesajeBrickStore.getLocalPesajesByAnimal(detail.id);
      }
    } on Object {
      // El fallback local es parte esperada del flujo offline-first.
      localPesajes = await _pesajeBrickStore.getLocalPesajesByAnimal(
        detail.id,
      );
    }

    if (refreshRemote) {
      try {
        await _categoriaBrickStore.pullRemoteCategorias(detail.establishmentId);
      } on Object {
        // Las categorias ya descargadas siguen resolviendo el nombre sin red.
      }

      try {
        await _observationStore.pullObservations(detail.establishmentId, detail.id);
      } on Object catch (error, stackTrace) {
        _logger.fine('Se conserva el historial local de notas sin red.', error, stackTrace);
      }
    }
    if (refreshRemote && _movementStore != null) {
      try {
        await _movementStore.pullMovements(detail.establishmentId);
      } on Object catch (error, stackTrace) {
        _logger.fine('Se conserva el historial local de lotes sin red.', error, stackTrace);
      }
    }
    final movements =
        await _movementStore?.getLocalMovements(detail.establishmentId) ?? <BrickAnimalLotMovementModel>[];
    final lots = await _lotStore?.getLocalLots(detail.establishmentId);
    String lotName(String id) =>
        lots?.where((lot) => lot.localId == id).firstOrNull?.name ??
        (id == detail.lotId && detail.lotName.isNotEmpty ? detail.lotName : id);
    final movementHistory = [
      for (final movement in movements.where((m) => (jsonDecode(m.animalIdsJson) as List).contains(detail.id)))
        AnimalLotMovementEvent(
          id: movement.localId,
          date: movement.occurredAt,
          sourceName: movement.sourceLotId == null ? null : lotName(movement.sourceLotId!),
          destinationName: lotName(movement.destinationLotId),
          reason: movement.reason,
          syncStatus: switch (movement.syncStatus) {
            BrickMovementSyncStatus.pending => AnimalSyncStatus.pending,
            BrickMovementSyncStatus.synchronized => AnimalSyncStatus.synchronized,
            BrickMovementSyncStatus.rejected => AnimalSyncStatus.rejected,
          },
          syncErrorCode: movement.syncErrorCode,
        ),
    ];
    final locatedAnimal = await _brickStore.getAnimalById(detail.id);
    final notes = await _observationStore.getLocalObservations(detail.establishmentId, detail.id);
    final localCategorias = await _categoriaBrickStore.getLocalCategorias(
      detail.establishmentId,
    );
    final weightHistory = AnimalDetailMapper.weightHistoryFromBrick(
      localPesajes,
    );
    final latestWeight = weightHistory.lastOrNull;
    final categoryName = localCategorias.where((category) => category.localId == detail.categoryId).firstOrNull?.name;

    final localPhotoPath = await _photoStore.findPhoto(
      establishmentId: detail.establishmentId,
      animalId: detail.id,
    );
    // Las capturas del dispositivo tienen prioridad sobre las fotos de ejemplo.
    final photoAssetPath = localPhotoPath == null ? await _photoStore.findBundledPhoto(detail.visualTag) : null;

    // El footer resume todas las escrituras de la ficha, no solo el animal:
    // una pesada o nota pendiente tampoco debe mostrarse como sincronizada.
    final relatedStatuses = [
      if (locatedAnimal == null) detail.syncStatus else AnimalDetailMapper.fromBrick(locatedAnimal).syncStatus,
      // Un rechazo histórico ya liberado no representa una ubicación pendiente
      // del animal actual; sigue visible en eventos, pero no bloquea su ficha.
      for (final movement in movementHistory)
        if (!(movement.syncErrorCode?.startsWith(BrickAnimalLotMovementStore.releasedDestinationPrefix) ?? false))
          movement.syncStatus,
      for (final weighing in localPesajes)
        switch (weighing.syncStatus) {
          BrickPesajeSyncStatus.pending => AnimalSyncStatus.pending,
          BrickPesajeSyncStatus.rejected => AnimalSyncStatus.rejected,
          BrickPesajeSyncStatus.synchronized => AnimalSyncStatus.synchronized,
        },
      for (final note in notes) AnimalDetailMapper.observationFromBrick(note).syncStatus,
    ];
    final syncStatus = relatedStatuses.contains(AnimalSyncStatus.rejected)
        ? AnimalSyncStatus.rejected
        : relatedStatuses.contains(AnimalSyncStatus.pending)
        ? AnimalSyncStatus.pending
        : AnimalSyncStatus.synchronized;
    final syncErrorCode =
        detail.syncErrorCode ??
        movementHistory
            .where(
              (m) =>
                  m.syncStatus == AnimalSyncStatus.rejected &&
                  !(m.syncErrorCode?.startsWith(BrickAnimalLotMovementStore.releasedDestinationPrefix) ?? false),
            )
            .firstOrNull
            ?.syncErrorCode ??
        localPesajes
            .where((weight) => weight.syncStatus == BrickPesajeSyncStatus.rejected)
            .firstOrNull
            ?.syncErrorCode ??
        notes.where((note) => note.syncStatus == BrickAnimalSyncStatus.rejected).firstOrNull?.syncErrorCode;
    return detail.copyWith(
      lotId: locatedAnimal?.lotId ?? detail.lotId,
      lotName: locatedAnimal == null || locatedAnimal.lotId.isEmpty ? detail.lotName : lotName(locatedAnimal.lotId),
      lotMovementHistory: movementHistory,
      syncStatus: syncStatus,
      syncErrorCode: syncErrorCode,
      localPhotoPath: localPhotoPath,
      photoAssetPath: photoAssetPath,
      categoryName: categoryName ?? detail.categoryName,
      categories: localCategorias.map(AnimalDetailMapper.categoryFromBrick).toList(growable: false),
      observationHistory: notes.map(AnimalDetailMapper.observationFromBrick).toList(growable: false),
      weightHistory: weightHistory,
      currentWeight: latestWeight?.weightKg ?? detail.currentWeight,
      weighingMethod: latestWeight?.method ?? detail.weighingMethod,
      weighingDate: latestWeight?.date ?? detail.weighingDate,
    );
  }
}

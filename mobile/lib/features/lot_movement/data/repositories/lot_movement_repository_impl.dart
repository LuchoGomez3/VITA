import 'dart:convert';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/entities/lot_movement.dart';
import 'package:frontend_mayoral/features/lot_movement/domain/repositories/lot_movement_repository.dart';
import 'package:logging/logging.dart';

/// Traduce Brick al dominio y reutiliza la cola y transacción compartidas.
class LotMovementRepositoryImpl implements LotMovementRepository {
  /// Stores resueltos por composición; ninguna dependencia de otra feature.
  const LotMovementRepositoryImpl({
    required AnimalBrickStore animals,
    required BrickLotStore lots,
    required BrickAnimalLotMovementStore movements,
  }) : _animals = animals,
       _lots = lots,
       _movements = movements;
  final AnimalBrickStore _animals;
  final BrickLotStore _lots;
  final BrickAnimalLotMovementStore _movements;
  static final _logger = Logger('LotMovementRepository');

  @override
  Stream<void> get changes => _movements.changes;

  @override
  Future<Result<MovementContext>> getContext(String establishmentId, {bool refreshRemote = false}) async {
    try {
      var cached = false;
      if (refreshRemote) {
        // Cada recurso conserva su fallback: fallar lotes no impide descargar
        // animales o historial. Sin lote_id, el GET trae todo el establecimiento;
        // el grupo sin asignación se identifica por lotId vacío en SQLite.
        for (final pull in <Future<void> Function()>[
          () => _lots.pullActiveLots(establishmentId),
          () => _movements.pullMovements(establishmentId),
          () => _animals.pullRemoteAnimals(establishmentId),
        ]) {
          try {
            await pull();
          } on Object catch (error, stack) {
            cached = true;
            _logger.fine('Se conserva la caché de movimientos.', error, stack);
          }
        }
      }
      final animals = await _animals.getLocalAnimals();
      final lots = await _lots.getLocalLots(establishmentId);
      final history = await _movements.getLocalMovements(establishmentId);
      return Result.success(
        MovementContext(
          animals: [
            for (final animal in animals.where(
              (a) => a.establishmentId == establishmentId && a.deletedAt == null && a.status == 'activo',
            ))
              MovementAnimal(
                id: animal.localId,
                tag: animal.visualTag.isEmpty ? animal.rfidTagNumber : animal.visualTag,
                lotId: animal.lotId.isEmpty ? null : animal.lotId,
                canMove: animal.lotSyncStatus == BrickAnimalSyncStatus.synchronized,
              ),
          ],
          origins: [for (final lot in lots) MovementLot(id: lot.localId, name: lot.name)],
          destinations: [
            // La caché permite trabajar offline, pero un lote creado solamente
            // en el celular todavía no es un destino válido para el backend.
            for (final lot in lots.where(
              (l) => {'activo', 'active'}.contains(l.statusCode) && l.syncStatus == BrickLotSyncStatus.synchronized,
            ))
              MovementLot(id: lot.localId, name: lot.name),
          ],
          history: history.map(_fromBrick).toList(),
          usingCachedData: cached,
        ),
      );
    } on Object catch (error, stack) {
      _logger.warning('No se pudo leer el contexto local.', error, stack);
      return const Result.failure(
        DomainException(message: 'No se pudieron cargar los datos del dispositivo.', code: DomainErrorCode.offline),
      );
    }
  }

  @override
  Future<Result<AnimalLotMovement>> save(AnimalLotMovement movement) async {
    try {
      final saved = await _movements.moveAnimals(
        BrickAnimalLotMovementModel(
          localId: movement.id,
          establishmentId: movement.establishmentId,
          sourceLotId: movement.sourceLotId,
          destinationLotId: movement.destinationLotId,
          animalIdsJson: jsonEncode(movement.animalIds),
          occurredAt: movement.occurredAt,
          reason: movement.reason,
          createdAt: movement.createdAt,
          updatedAt: movement.createdAt,
        ),
      );
      return Result.success(_fromBrick(saved));
    } on DomainException catch (error) {
      return Result.failure(error);
    } on Object catch (error, stack) {
      _logger.warning('No se pudo guardar el movimiento.', error, stack);
      return const Result.failure(
        DomainException(message: 'No se pudo guardar el movimiento en el dispositivo.', code: DomainErrorCode.offline),
      );
    }
  }

  @override
  Future<Result<void>> retry(String movementId) async {
    try {
      await _movements.retry(movementId);
      return const Result.success(null);
    } on Object catch (error, stack) {
      _logger.warning('No se pudo reintentar el movimiento.', error, stack);
      return const Result.failure(
        DomainException(message: 'No se pudo preparar el reintento.', code: DomainErrorCode.syncFailed),
      );
    }
  }

  /// Conserva el estado técnico para que pending nunca se muestre confirmado.
  static AnimalLotMovement _fromBrick(BrickAnimalLotMovementModel model) => AnimalLotMovement(
    id: model.localId,
    establishmentId: model.establishmentId,
    sourceLotId: model.sourceLotId,
    destinationLotId: model.destinationLotId,
    animalIds: (jsonDecode(model.animalIdsJson) as List).cast<String>(),
    occurredAt: model.occurredAt,
    reason: model.reason,
    createdAt: model.createdAt,
    syncStatus: MovementSyncStatus.values[model.syncStatus.index],
    syncErrorCode: model.syncErrorCode,
  );
}

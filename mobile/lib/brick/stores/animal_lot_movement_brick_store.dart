import 'dart:async';
import 'dart:convert';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:logging/logging.dart';

/// Contrato usado por la sincronización inicial y las features de lotes.
abstract class AnimalLotMovementBrickStore {
  /// Guarda un movimiento local.
  Future<BrickAnimalLotMovementModel> save(BrickAnimalLotMovementModel movement);

  /// Guarda animales y movimiento en una única transacción local.
  Future<BrickAnimalLotMovementModel> saveWithAnimals({
    required List<BrickAnimalModel> animals,
    required BrickAnimalLotMovementModel movement,
  });

  /// Descarga el historial remoto del establecimiento.
  Future<void> pullRemoteMovements(String establishmentId);

  /// Reconstruye y envía movimientos pendientes del establecimiento.
  Future<void> pushPendingMovements(String establishmentId);

  /// Mueve todos los animales o ninguno y registra el historial local.
  Future<BrickAnimalLotMovementModel> moveAnimals(
    BrickAnimalLotMovementModel movement,
  );
}

/// Transacción de ubicación, historial durable y outbox sobre la cola de Brick.
class BrickAnimalLotMovementStore implements AnimalLotMovementBrickStore {
  BrickAnimalLotMovementStore._(this._repository, {required bool enableRemoteSync})
    : _enableRemoteSync = enableRemoteSync {
    _subscription = _repository.syncResults.listen((result) {
      // Las respuestas se procesan en orden: un pull del historial no debe
      // competir con la confirmación y perder un rechazo o su fila local.
      _results = _results.then((_) => applySyncResult(result)).catchError((Object error, StackTrace stack) {
        _logger.warning('No se pudo aplicar el resultado del movimiento.', error, stack);
      });
    });
    if (enableRemoteSync) {
      _recoveryTimer = Timer.periodic(const Duration(seconds: 30), (_) => unawaited(recoverPending()));
      unawaited(recoverPending());
    }
  }

  static BrickAnimalLotMovementStore? _instance;
  static final _logger = Logger('BrickAnimalLotMovementStore');
  final AppBrickRepository _repository;
  final bool _enableRemoteSync;
  final _changes = StreamController<void>.broadcast();
  late final StreamSubscription<BackendSyncResult> _subscription;
  Timer? _recoveryTimer;
  Future<void> _results = Future<void>.value();
  bool _recovering = false;

  /// Marca un intento rechazado cuya ubicación local ya fue restaurada.
  /// Se conserva el rechazo original después del prefijo para auditarlo.
  static const releasedDestinationPrefix = 'released_local_destination:';

  /// Instancia configurada durante el bootstrap.
  static BrickAnimalLotMovementStore get instance =>
      _instance ?? (throw StateError('BrickAnimalLotMovementStore no fue inicializado.'));

  /// Activa el contrato confirmado; permite deshabilitar envíos en tests locales.
  static void configure(AppBrickRepository repository, {bool enableRemoteSync = true}) {
    _instance ??= BrickAnimalLotMovementStore._(repository, enableRemoteSync: enableRemoteSync);
  }

  /// Notifica cambios después de persistirlos, para actualizar el historial visible.
  Stream<void> get changes => _changes.stream;

  /// Lee el historial incluyendo operaciones que el servidor rechazó.
  Future<List<BrickAnimalLotMovementModel>> getLocalMovements(String establishmentId) async {
    final stored = await _repository.getLocal<BrickAnimalLotMovementModel>();
    return stored.where((m) => m.establishmentId == establishmentId && m.deletedAt == null).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  /// Conserva una operación local antes de persistir su request en la cola.
  @override
  Future<BrickAnimalLotMovementModel> save(BrickAnimalLotMovementModel movement) async {
    final saved = await _repository.upsertLocal(movement);
    _changes.add(null);
    await recoverPending();
    return saved;
  }

  /// Compatibilidad con escrituras compuestas existentes; no dispara PUT de animales.
  @override
  Future<BrickAnimalLotMovementModel> saveWithAnimals({
    required List<BrickAnimalModel> animals,
    required BrickAnimalLotMovementModel movement,
  }) async {
    final saved = await _repository.runLocalTransaction((transaction) async {
      for (final animal in animals) {
        await transaction.upsert<BrickAnimalModel>(animal);
      }
      return transaction.upsert<BrickAnimalLotMovementModel>(movement);
    });
    _changes.add(null);
    await recoverPending();
    return saved;
  }

  @override
  Future<void> pushPendingMovements(String establishmentId) async {
    if (!_enableRemoteSync) return;
    await recoverPending();
  }

  @override
  Future<void> pullRemoteMovements(String establishmentId) => pullMovements(establishmentId);

  /// Alias compatible con el flujo de sync previo al movimiento batch.
  Future<void> applyMovementSyncResult(BackendSyncResult result) async {
    await applySyncResult(result);
    if (!BrickAnimalLotMovementRequestTransformer.matchesMovementResource(
      result.resourcePath,
    )) {
      return;
    }
    final movements = await _repository.getLocal<BrickAnimalLotMovementModel>();
    final movement = movements.where((item) => item.localId == result.localId).firstOrNull;
    if (movement == null) return;
    final animalIds = (jsonDecode(movement.animalIdsJson) as List<dynamic>).cast<String>().toSet();
    final animals = await _repository.getLocal<BrickAnimalModel>();
    for (final animal in animals.where(
      (item) =>
          animalIds.contains(item.localId) &&
          item.lotId == movement.destinationLotId &&
          item.updatedAt.isAtSameMomentAs(movement.updatedAt),
    )) {
      await _repository.upsertLocal(
        animal.copyWith(
          syncStatus: result.synchronized ? BrickAnimalSyncStatus.synchronized : BrickAnimalSyncStatus.rejected,
          syncErrorCode: result.errorCode,
        ),
      );
    }
  }

  /// Revalida origen y destino dentro de SQLite y mueve todos los animales o ninguno.
  ///
  /// El UUID es estable. Repetir esta llamada devuelve la misma operación, sin
  /// aplicar otra vez la ubicación. Se bloquea un nuevo movimiento de animales
  /// cuya ubicación anterior sigue pendiente o rechazada, evitando cadenas que
  /// dependan de un origen que el servidor todavía no confirmó.
  @override
  Future<BrickAnimalLotMovementModel> moveAnimals(BrickAnimalLotMovementModel movement) async {
    final saved = await _repository.runLocalTransaction((transaction) async {
      final movements = await transaction.getLocal<BrickAnimalLotMovementModel>();
      final existing = movements.where((m) => m.localId == movement.localId).firstOrNull;
      if (existing != null) {
        if (existing.establishmentId != movement.establishmentId ||
            existing.sourceLotId != movement.sourceLotId ||
            existing.destinationLotId != movement.destinationLotId ||
            existing.animalIdsJson != movement.animalIdsJson ||
            existing.occurredAt != movement.occurredAt ||
            existing.reason != movement.reason) {
          throw const DomainException(
            message: 'El UUID ya identifica otro movimiento; su payload no puede cambiar.',
            code: DomainErrorCode.conflict,
          );
        }
        return existing;
      }
      final ids = (jsonDecode(movement.animalIdsJson) as List).cast<String>();
      if (ids.isEmpty || ids.toSet().length != ids.length || movement.reason.trim().isEmpty) {
        throw const DomainException(
          message: 'Seleccioná animales sin repetir e ingresá un motivo.',
          code: DomainErrorCode.validation,
        );
      }
      final lots = await transaction.getLocal<BrickLotModel>();
      final destination = lots.where((lot) => lot.localId == movement.destinationLotId).firstOrNull;
      if (destination == null ||
          destination.deletedAt != null ||
          destination.establishmentId != movement.establishmentId ||
          !{'activo', 'active'}.contains(destination.statusCode) ||
          destination.localId == movement.sourceLotId) {
        throw const DomainException(
          message: 'El destino debe ser otro lote activo del establecimiento.',
          code: DomainErrorCode.validation,
        );
      }
      final animals = await transaction.getLocal<BrickAnimalModel>();
      if (destination.syncStatus != BrickLotSyncStatus.synchronized) {
        throw const DomainException(
          message: 'El lote de destino debe sincronizarse antes de recibir animales.',
          code: DomainErrorCode.validation,
        );
      }
      final selected = [for (final id in ids) animals.where((a) => a.localId == id).firstOrNull];
      if (selected.any(
        (a) =>
            a == null ||
            a.deletedAt != null ||
            a.status != 'activo' ||
            a.establishmentId != movement.establishmentId ||
            (a.lotId.isEmpty ? null : a.lotId) != movement.sourceLotId ||
            a.lotSyncStatus != BrickAnimalSyncStatus.synchronized,
      )) {
        throw const DomainException(
          message: 'Los animales deben compartir origen y no tener otro traslado pendiente o rechazado.',
          code: DomainErrorCode.conflict,
        );
      }
      for (final animal in selected.cast<BrickAnimalModel>()) {
        await transaction.upsert<BrickAnimalModel>(
          animal.copyWith(
            lotId: destination.localId,
            lotName: destination.name,
            lotMovementId: movement.localId,
            lotSyncStatus: BrickAnimalSyncStatus.pending,
            lotSyncErrorCode: null,
          ),
        );
      }
      return transaction.upsert<BrickAnimalLotMovementModel>(movement);
    });
    _changes.add(null);
    await recoverPending();
    return saved;
  }

  /// Reconstruye jobs faltantes tras un cierre entre la transacción y la cola.
  /// No retransmite requests directamente: Brick decide cuándo enviar y reintentar.
  Future<void> recoverPending() async {
    if (!_enableRemoteSync || _recovering) return;
    _recovering = true;
    try {
      final movements = await _repository.getLocal<BrickAnimalLotMovementModel>();
      for (final movement in movements.where(
        (m) => m.syncStatus == BrickMovementSyncStatus.pending && m.deletedAt == null,
      )) {
        await _repository.queueRemoteUpsert(movement);
      }
      // Repara también rechazos persistidos por versiones anteriores. Primero
      // se retira el job; si Brick lo tiene en vuelo, el próximo ciclo reevalúa.
      // Nunca se revierte un pendiente: pudo haber llegado al servidor aunque
      // el celular todavía no haya recibido su confirmación.
      for (final movement in movements.where((m) => m.syncStatus == BrickMovementSyncStatus.rejected)) {
        await _releaseRejectedLocalDestination(movement);
      }
    } on Object catch (error, stack) {
      // La operación sigue en SQLite aunque falle la base separada de la cola.
      _logger.warning('El movimiento se conserva para reconstruir su envío.', error, stack);
    } finally {
      _recovering = false;
    }
  }

  /// Reencola el payload original con el mismo UUID; nunca crea otro traslado.
  Future<void> retry(String movementId) async {
    await _repository.runLocalTransaction((transaction) async {
      final stored = await transaction.getLocal<BrickAnimalLotMovementModel>();
      final movement = stored.where((m) => m.localId == movementId).firstOrNull;
      if (movement == null || movement.syncStatus == BrickMovementSyncStatus.synchronized) return;
      if (movement.syncErrorCode?.startsWith(releasedDestinationPrefix) ?? false) {
        throw const DomainException(
          message: 'Este intento fue liberado. Creá un movimiento nuevo hacia un lote sincronizado.',
          code: DomainErrorCode.conflict,
        );
      }
      await transaction.upsert(movement.withSync(BrickMovementSyncStatus.pending));
      final animals = await transaction.getLocal<BrickAnimalModel>();
      for (final animal in animals.where((a) => a.lotMovementId == movementId)) {
        await transaction.upsert(animal.copyWith(lotSyncStatus: BrickAnimalSyncStatus.pending, lotSyncErrorCode: null));
      }
    });
    _changes.add(null);
    await recoverPending();
  }

  /// Persiste confirmación o rechazo y sólo modifica el sync de ubicación.
  Future<void> applySyncResult(BackendSyncResult result) async {
    if (result.resourcePath != BrickAnimalLotMovementRequestTransformer.movementsPath) return;
    BrickAnimalLotMovementModel? authoritative;
    final responseData = result.responseData;
    if (result.synchronized && responseData != null && responseData.isNotEmpty) {
      authoritative = await _repository.modelFromRemoteData<BrickAnimalLotMovementModel>(responseData);
    }
    await _repository.runLocalTransaction((transaction) async {
      final stored = await transaction.getLocal<BrickAnimalLotMovementModel>();
      final movement = stored.where((m) => m.localId == result.localId).firstOrNull;
      if (movement == null || movement.syncStatus == BrickMovementSyncStatus.synchronized) return;
      if (movement.syncErrorCode?.startsWith(releasedDestinationPrefix) ?? false) return;
      authoritative?.primaryKey = movement.primaryKey;
      await transaction.upsert(
        (authoritative ?? movement).withSync(
          result.synchronized ? BrickMovementSyncStatus.synchronized : BrickMovementSyncStatus.rejected,
          errorCode: result.errorCode,
        ),
      );
      final animals = await transaction.getLocal<BrickAnimalModel>();
      for (final animal in animals.where((a) => a.lotMovementId == movement.localId)) {
        await transaction.upsert(
          animal.copyWith(
            lotSyncStatus: result.synchronized ? BrickAnimalSyncStatus.synchronized : BrickAnimalSyncStatus.rejected,
            lotSyncErrorCode: result.errorCode,
          ),
        );
      }
    });
    _changes.add(null);
    await recoverPending();
  }

  /// Devuelve al origen sólo animales que todavía pertenecen al intento fallido.
  /// La transacción conserva peso, categoría y otras ediciones independientes,
  /// y mantiene el movimiento rechazado como evidencia en el historial.
  Future<void> _releaseRejectedLocalDestination(BrickAnimalLotMovementModel movement) async {
    // Este rechazo ocurre antes de modificar animales en el backend. Errores
    // de sesión u origen requieren reconciliación y no prueban esta condición.
    if (movement.syncErrorCode != 'lote_destino_no_disponible') return;
    final lots = await _repository.getLocal<BrickLotModel>();
    final destination = lots.where((lot) => lot.localId == movement.destinationLotId).firstOrNull;
    if (destination?.syncStatus == BrickLotSyncStatus.synchronized) return;
    if (!await _repository.removeQueuedUpsert(movement)) return;
    final released = await _repository.runLocalTransaction((transaction) async {
      final stored = await transaction.getLocal<BrickAnimalLotMovementModel>();
      final current = stored.where((m) => m.localId == movement.localId).firstOrNull;
      if (current == null || current.syncStatus != BrickMovementSyncStatus.rejected) return false;
      final origin = lots.where((lot) => lot.localId == current.sourceLotId).firstOrNull;
      final animals = await transaction.getLocal<BrickAnimalModel>();
      for (final animal in animals.where(
        (a) => a.lotMovementId == current.localId && a.lotSyncStatus == BrickAnimalSyncStatus.rejected,
      )) {
        await transaction.upsert(
          animal.copyWith(
            lotId: current.sourceLotId ?? '',
            lotName: origin?.name ?? '',
            lotSyncStatus: BrickAnimalSyncStatus.synchronized,
            lotSyncErrorCode: null,
          ),
        );
      }
      await transaction.upsert(
        current.withSync(
          BrickMovementSyncStatus.rejected,
          errorCode: '$releasedDestinationPrefix${current.syncErrorCode ?? 'unknown'}',
        ),
      );
      return true;
    });
    if (released) _changes.add(null);
  }

  /// Hidrata historial remoto sin borrar rechazos que no están en el servidor.
  Future<void> pullMovements(String establishmentId) async {
    final remote = await _repository.remoteProvider.get<BrickAnimalLotMovementModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(request: BrickAnimalLotMovementRequestTransformer.listRequest(establishmentId)),
        ],
      ),
    );
    for (final movement in remote) {
      await applySyncResult(
        BackendSyncResult(
          resourcePath: BrickAnimalLotMovementRequestTransformer.movementsPath,
          localId: movement.localId,
          synchronized: true,
        ),
      );
      await _repository.runLocalTransaction((transaction) async {
        final local = await transaction.getLocal<BrickAnimalLotMovementModel>();
        movement.primaryKey = local.where((m) => m.localId == movement.localId).firstOrNull?.primaryKey;
        await transaction.upsert(movement.withSync(BrickMovementSyncStatus.synchronized));
      });
    }
    _changes.add(null);
    // El endpoint de animales es la fuente de ubicación entre dispositivos;
    // reproducir un movimiento histórico nunca vuelve a mover animales locales.
    await BrickAnimalStore.instance.pullRemoteAnimals(establishmentId);
  }

  /// Libera timer y canales en tests o al cerrar la infraestructura.
  Future<void> dispose() async {
    _recoveryTimer?.cancel();
    await _subscription.cancel();
    await _results;
    await _changes.close();
  }
}

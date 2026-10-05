import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_observation.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Acceso a notas locales y su sincronización, sin exponer Brick al dominio.
abstract class AnimalObservationBrickStore {
  /// Guarda una nueva nota antes de intentar el POST remoto.
  Future<BrickAnimalObservationModel> addObservation(BrickAnimalObservationModel observation);

  /// Intenta actualizar el historial remoto y conserva notas offline pendientes.
  Future<void> pullObservations(String establishmentId, String animalId);

  /// Lee notas vigentes del animal desde SQLite, más recientes primero.
  Future<List<BrickAnimalObservationModel>> getLocalObservations(String establishmentId, String animalId);
}

/// Store por entidad que protege las entradas pendientes frente al pull remoto.
class BrickAnimalObservationStore implements AnimalObservationBrickStore {
  BrickAnimalObservationStore._(this._repository) {
    _subscription = _repository.syncResults.listen(_applySyncResult);
  }

  static BrickAnimalObservationStore? _instance;
  final AppBrickRepository _repository;
  late final StreamSubscription<BackendSyncResult> _subscription;

  /// Store inicializado durante el arranque de Brick.
  static BrickAnimalObservationStore get instance =>
      _instance ?? (throw StateError('Observation store not initialized'));

  /// Configura la instancia compartida una sola vez.
  static void configure(AppBrickRepository repository) {
    _instance ??= BrickAnimalObservationStore._(repository);
  }

  @override
  Future<BrickAnimalObservationModel> addObservation(BrickAnimalObservationModel observation) async {
    final saved = await _repository.upsertLocal<BrickAnimalObservationModel>(observation);
    unawaited(_repository.enqueueRemoteUpsert<BrickAnimalObservationModel>(saved));
    return saved;
  }

  @override
  Future<void> pullObservations(String establishmentId, String animalId) async {
    final remote = await _repository.remoteProvider.get<BrickAnimalObservationModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(
            request: BrickAnimalObservationRequestTransformer.listForAnimal(establishmentId, animalId),
          ),
        ],
      ),
    );
    final local = await _repository.getLocal<BrickAnimalObservationModel>();
    final byId = {for (final note in local) note.localId: note};
    for (final note in remote) {
      final existing = byId[note.localId];
      if (existing != null && existing.syncStatus != BrickAnimalSyncStatus.synchronized) continue;
      final cached = note.withSync(BrickAnimalSyncStatus.synchronized, null)..primaryKey = existing?.primaryKey;
      await _repository.upsertLocal<BrickAnimalObservationModel>(cached);
    }
  }

  @override
  Future<List<BrickAnimalObservationModel>> getLocalObservations(String establishmentId, String animalId) async {
    final all = await _repository.getLocal<BrickAnimalObservationModel>();
    final byId = <String, BrickAnimalObservationModel>{};
    for (final note in all) {
      if (note.establishmentId == establishmentId && note.animalId == animalId && note.deletedAt == null) {
        byId[note.localId] = note;
      }
    }
    return byId.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Actualiza la nota que originó el POST, sin encolar un envío adicional.
  Future<void> _applySyncResult(BackendSyncResult result) async {
    if (!result.resourcePath.endsWith(BrickAnimalObservationRequestTransformer.observationsPath)) return;
    final all = await _repository.getLocal<BrickAnimalObservationModel>();
    for (final note in all) {
      if (note.localId != result.localId) continue;
      await _repository.upsertLocal<BrickAnimalObservationModel>(
        note.withSync(
          result.synchronized ? BrickAnimalSyncStatus.synchronized : BrickAnimalSyncStatus.rejected,
          result.errorCode,
        ),
      );
      return;
    }
  }

  /// Cancela la escucha al cerrar la infraestructura compartida.
  Future<void> dispose() => _subscription.cancel();
}

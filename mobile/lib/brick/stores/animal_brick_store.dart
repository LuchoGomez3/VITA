import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Contrato usado por features para persistir animales con Brick.
///
/// Las features dependen de este contrato para no conocer los detalles internos
/// de [AppBrickRepository], SQLite, REST provider ni cola offline.
abstract class AnimalBrickStore {
  /// Guarda [animal] localmente y lo deja listo para sincronizacion remota.
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal);

  /// Guarda datos remotos en SQLite sin generar una request de sincronizacion.
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal);

  /// Busca un animal en SQLite por el UUID generado en mobile/backend.
  Future<BrickAnimalModel?> getAnimalById(String animalId);

  /// Descarga animales remotos de [establishmentId] y los guarda en SQLite.
  Future<void> pullRemoteAnimals(String establishmentId);
}

/// Store Brick especifico para operaciones de animales.
///
/// Este store contiene logica propia de `BrickAnimalModel`: guardar primero en
/// SQLite, encolar el upsert remoto y aplicar los resultados de sync que llegan
/// desde el cliente HTTP autenticado.
class BrickAnimalStore implements AnimalBrickStore {
  BrickAnimalStore._(this._repository) {
    _syncSubscription = _repository.syncResults.listen(
      applyAnimalSyncResult,
    );
  }

  static BrickAnimalStore? _instance;

  final AppBrickRepository _repository;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;

  /// Instancia compartida configurada durante el bootstrap de Brick.
  static BrickAnimalStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError('BrickAnimalStore has not been initialized yet.');
    }
    return store;
  }

  /// Configura el store de animales una sola vez.
  static void configure(AppBrickRepository repository) {
    if (_instance != null) {
      return;
    }

    _instance = BrickAnimalStore._(repository);
  }

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) async {
    final savedAnimal = await _repository.upsertLocal<BrickAnimalModel>(animal);

    // El alta ya quedo guardada localmente. El request remoto corre en segundo
    // plano para que la UX siga siendo offline-first y no espere al backend.
    unawaited(_repository.enqueueRemoteUpsert<BrickAnimalModel>(savedAnimal));

    return savedAnimal;
  }

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) {
    return _repository.upsertLocal<BrickAnimalModel>(animal);
  }

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async {
    final storedAnimals = await _repository.getLocal<BrickAnimalModel>();

    for (final animal in storedAnimals) {
      if (animal.localId == animalId) {
        return animal;
      }
    }

    return null;
  }

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {
    final remoteAnimals = await _repository.remoteProvider.get<BrickAnimalModel>(
      repository: _repository,
      query: Query(
        forProviders: [
          RestProviderQuery(
            // La ruta se arma en el transformer del modelo para que este store
            // solo coordine el flujo offline-first y no duplique endpoints.
            request: BrickAnimalRequestTransformer.listByEstablishmentRequest(
              establishmentId,
            ),
          ),
        ],
      ),
    );
    final localAnimals = await _repository.getLocal<BrickAnimalModel>();
    final protectedLocalIds = localAnimals
        .where(
          (animal) =>
              animal.syncStatus == BrickAnimalSyncStatus.pending || animal.syncStatus == BrickAnimalSyncStatus.rejected,
        )
        .map((animal) => animal.localId)
        .toSet();

    for (final animal in remoteAnimals) {
      if (protectedLocalIds.contains(animal.localId)) {
        continue;
      }

      await _repository.upsertLocal<BrickAnimalModel>(
        animal.copyWith(
          syncStatus: BrickAnimalSyncStatus.synchronized,
          syncErrorCode: null,
        ),
      );
    }
  }

  /// Aplica la respuesta del backend al registro local.
  ///
  /// `2xx` marca el animal como sincronizado. Errores funcionales del backend
  /// marcan el registro como rechazado y guardan el codigo para mostrarlo en UI.
  Future<void> applyAnimalSyncResult(BackendSyncResult result) async {
    // El matcher vive junto a la ruta base para que el filtro de eventos de
    // sync cambie automaticamente si cambia el endpoint de animales.
    if (!BrickAnimalRequestTransformer.matchesAnimalResource(
      result.resourcePath,
    )) {
      return;
    }

    final storedAnimals = await _repository.getLocal<BrickAnimalModel>();

    for (final animal in storedAnimals) {
      if (animal.localId != result.localId) {
        continue;
      }

      final updatedAnimal = animal.copyWith(
        syncStatus: result.synchronized ? BrickAnimalSyncStatus.synchronized : BrickAnimalSyncStatus.rejected,
        syncErrorCode: result.errorCode,
      );
      await _repository.upsertLocal<BrickAnimalModel>(updatedAnimal);
      return;
    }
  }

  /// Libera la subscription interna del store.
  Future<void> dispose() async {
    await _syncSubscription.cancel();
  }
}

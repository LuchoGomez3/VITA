import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_update.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:meta/meta.dart';

/// Contrato usado por features para persistir animales con Brick.
///
/// Las features dependen de este contrato para no conocer los detalles internos
/// de [AppBrickRepository], SQLite, REST provider ni cola offline.
abstract class AnimalBrickStore {
  /// Guarda [animal] localmente y lo deja listo para sincronizacion remota.
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal);

  /// Guarda una edición y encola PUT al animal existente, sin recrear su alta.
  Future<BrickAnimalModel> updateAnimal(BrickAnimalModel animal);

  /// Guarda datos remotos en SQLite sin generar una request de sincronizacion.
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal);

  /// Busca un animal en SQLite por el UUID generado en mobile/backend.
  Future<BrickAnimalModel?> getAnimalById(String animalId);

  /// Busca en SQLite por RFID dentro de un establecimiento.
  ///
  /// Los animales con baja logica no participan de la identificacion.
  Future<BrickAnimalModel?> getAnimalByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  });

  /// Lee todos los animales locales, incluidas las bajas logicas.
  Future<List<BrickAnimalModel>> getLocalAnimals();

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
  Future<BrickAnimalModel> updateAnimal(BrickAnimalModel animal) async {
    final savedAnimal = await _repository.upsertLocal<BrickAnimalModel>(animal);
    unawaited(
      _repository.enqueueRemoteUpsert<BrickAnimalUpdateModel>(
        BrickAnimalUpdateModel(
          localId: savedAnimal.localId,
          categoryId: savedAnimal.categoryId.isEmpty ? null : savedAnimal.categoryId,
          status: savedAnimal.status,
          reproductiveStatus: savedAnimal.reproductiveStatus,
          updatedAt: savedAnimal.updatedAt,
        ),
      ),
    );
    return savedAnimal;
  }

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) {
    return _repository.upsertLocal<BrickAnimalModel>(animal);
  }

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async {
    final storedAnimals = await getLocalAnimals();

    for (final animal in storedAnimals) {
      if (animal.localId == animalId && animal.deletedAt == null) {
        return animal;
      }
    }

    return null;
  }

  @override
  Future<BrickAnimalModel?> getAnimalByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async {
    final storedAnimals = await getLocalAnimals();
    return selectAnimalForRfidLookup(
      animals: storedAnimals,
      rfidTagNumber: rfidTagNumber,
      establishmentId: establishmentId,
    );
  }

  /// Selecciona el animal identificable mas reciente dentro de datos locales.
  ///
  /// Se expone para pruebas del criterio de seleccion sin inicializar SQLite;
  /// la consulta real siempre obtiene primero [animals] desde Brick.
  @visibleForTesting
  static BrickAnimalModel? selectAnimalForRfidLookup({
    required Iterable<BrickAnimalModel> animals,
    required String rfidTagNumber,
    required String establishmentId,
  }) {
    BrickAnimalModel? matchedAnimal;

    for (final animal in animals) {
      final matchesRfid = animal.rfidTagNumber == rfidTagNumber;
      final belongsToEstablishment = animal.establishmentId == establishmentId;
      if (!matchesRfid || !belongsToEstablishment || animal.deletedAt != null) {
        continue;
      }

      if (matchedAnimal == null || animal.updatedAt.isAfter(matchedAnimal.updatedAt)) {
        matchedAnimal = animal;
      }
    }

    return matchedAnimal;
  }

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async {
    final storedAnimals = await _repository.getLocal<BrickAnimalModel>();
    final animalsById = <String, BrickAnimalModel>{};

    // Las versiones antiguas del pull podian insertar varias filas con el mismo
    // UUID. Se expone una sola version por animal para reparar esas instalaciones
    // sin borrar altas offline que todavia esten pendientes.
    for (final animal in storedAnimals) {
      final current = animalsById[animal.localId];
      animalsById[animal.localId] = current == null ? animal : _preferredAnimal(current, animal);
    }

    return animalsById.values.toList();
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
    // El merge comparte la transacción con la lectura local. Un movimiento
    // guardado mientras llegaba el GET conserva su destino y su propio sync.
    await _repository.runLocalTransaction<void>((transaction) async {
      final localAnimals = await transaction.getLocal<BrickAnimalModel>();
      final localAnimalsById = <String, BrickAnimalModel>{};
      for (final local in localAnimals) {
        final current = localAnimalsById[local.localId];
        localAnimalsById[local.localId] = current == null ? local : _preferredAnimal(current, local);
      }
      for (final animal in remoteAnimals) {
        final local = localAnimalsById[animal.localId];
        if (local != null && local.syncStatus != BrickAnimalSyncStatus.synchronized) continue;
        var synchronized = animal.copyWith(syncStatus: BrickAnimalSyncStatus.synchronized, syncErrorCode: null)
          ..primaryKey = local?.primaryKey;
        if (local != null && local.lotSyncStatus != BrickAnimalSyncStatus.synchronized) {
          synchronized = synchronized.copyWith(
            lotId: local.lotId,
            lotName: local.lotName,
            lotMovementId: local.lotMovementId,
            lotSyncStatus: local.lotSyncStatus,
            lotSyncErrorCode: local.lotSyncErrorCode,
          );
        }
        await transaction.upsert(synchronized);
      }
    });
  }

  BrickAnimalModel _preferredAnimal(
    BrickAnimalModel current,
    BrickAnimalModel candidate,
  ) {
    if (current.syncStatus != BrickAnimalSyncStatus.synchronized) {
      return current;
    }
    if (candidate.syncStatus != BrickAnimalSyncStatus.synchronized) {
      return candidate;
    }

    return candidate.updatedAt.isAfter(current.updatedAt) ? candidate : current;
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

    // La respuesta confirma sólo la edición del animal. Leer y escribir dentro
    // de la misma transacción evita restaurar por accidente un lotSyncStatus
    // viejo cuando el traslado se confirma al mismo tiempo.
    await _repository.runLocalTransaction<void>((transaction) async {
      final storedAnimals = await transaction.getLocal<BrickAnimalModel>();
      for (final animal in storedAnimals) {
        if (animal.localId != result.localId) continue;
        // Una respuesta de la baja no debe confirmar el deshacer más reciente.
        if (result.updatedAt != null && result.updatedAt!.isBefore(animal.updatedAt)) continue;
        await transaction.upsert(
          animal.copyWith(
            syncStatus: result.synchronized ? BrickAnimalSyncStatus.synchronized : BrickAnimalSyncStatus.rejected,
            syncErrorCode: result.errorCode,
          ),
        );
        return;
      }
    });
  }

  /// Libera la subscription interna del store.
  Future<void> dispose() async {
    await _syncSubscription.cancel();
  }
}

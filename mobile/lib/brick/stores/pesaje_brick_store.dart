import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Contrato usado por features para persistir pesajes con Brick.
///
/// Las features dependen de este contrato para no conocer los detalles internos
/// de [AppBrickRepository], SQLite, REST provider ni cola offline.
abstract class PesajeBrickStore {
  /// Guarda [pesaje] localmente y lo deja listo para sincronizacion remota.
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje);

  /// Descarga pesajes remotos de [establishmentId] y los guarda en SQLite.
  ///
  /// Si se pasa [animalId], baja solo el historial de ese animal (evolucion/GPD).
  Future<void> pullRemotePesajes(
    String establishmentId, {
    String? animalId,
  });

  /// Garantiza una carga inicial y luego devuelve la copia guardada en SQLite.
  Future<List<BrickPesajeModel>> loadPesajesByAnimal(
    String establishmentId,
    String animalId,
  );

  /// Lee desde SQLite el historial de pesajes de un animal, ordenado por fecha.
  Future<List<BrickPesajeModel>> getLocalPesajesByAnimal(String animalId);

  /// Lee todos los pesajes locales vigentes.
  Future<List<BrickPesajeModel>> getLocalPesajes();
}

/// Store Brick especifico para operaciones de pesajes.
///
/// El pesaje es transaccional, igual que el animal: guarda primero en SQLite,
/// encola el POST remoto y aplica los resultados de sync que llegan desde el
/// cliente HTTP autenticado.
class BrickPesajeStore implements PesajeBrickStore {
  BrickPesajeStore._(this._repository) {
    _syncSubscription = _repository.syncResults.listen(
      applyPesajeSyncResult,
    );
  }

  static BrickPesajeStore? _instance;

  final AppBrickRepository _repository;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;
  final Set<String> _hydratedAnimalIds = {};

  /// Instancia compartida configurada durante el bootstrap de Brick.
  static BrickPesajeStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError('BrickPesajeStore has not been initialized yet.');
    }
    return store;
  }

  /// Configura el store de pesajes una sola vez.
  static void configure(AppBrickRepository repository) {
    if (_instance != null) {
      return;
    }

    _instance = BrickPesajeStore._(repository);
  }

  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) async {
    final savedPesaje = await _repository.upsertLocal<BrickPesajeModel>(pesaje);

    // La pesada ya quedo guardada localmente. El request remoto corre en segundo
    // plano para que la UX siga siendo offline-first y no espere al backend.
    unawaited(_repository.enqueueRemoteUpsert<BrickPesajeModel>(savedPesaje));

    return savedPesaje;
  }

  @override
  Future<void> pullRemotePesajes(
    String establishmentId, {
    String? animalId,
  }) async {
    final request = animalId == null
        ? BrickPesajeRequestTransformer.listByEstablishmentRequest(
            establishmentId,
          )
        : BrickPesajeRequestTransformer.listByAnimalRequest(
            establishmentId,
            animalId,
          );

    final remotePesajes = await _repository.remoteProvider.get<BrickPesajeModel>(
      repository: _repository,
      query: Query(
        forProviders: [RestProviderQuery(request: request)],
      ),
    );

    // Las pesadas cargadas offline y todavia no confirmadas no deben ser
    // pisadas por el pull.
    final localPesajes = await _repository.getLocal<BrickPesajeModel>();
    final localPesajesById = {
      for (final pesaje in localPesajes) pesaje.localId: pesaje,
    };
    final protectedLocalIds = localPesajes
        .where(
          (pesaje) =>
              pesaje.syncStatus == BrickPesajeSyncStatus.pending ||
              pesaje.syncStatus == BrickPesajeSyncStatus.rejected,
        )
        .map((pesaje) => pesaje.localId)
        .toSet();

    for (final pesaje in remotePesajes) {
      if (protectedLocalIds.contains(pesaje.localId)) {
        continue;
      }

      final synchronizedPesaje = pesaje.copyWith(
        syncStatus: BrickPesajeSyncStatus.synchronized,
        syncErrorCode: null,
      )..primaryKey = localPesajesById[pesaje.localId]?.primaryKey;
      await _repository.upsertLocal<BrickPesajeModel>(synchronizedPesaje);
    }
  }

  @override
  Future<List<BrickPesajeModel>> loadPesajesByAnimal(
    String establishmentId,
    String animalId,
  ) async {
    final localPesajes = await getLocalPesajesByAnimal(animalId);
    if (localPesajes.isNotEmpty || _hydratedAnimalIds.contains(animalId)) {
      return localPesajes;
    }

    await pullRemotePesajes(establishmentId, animalId: animalId);
    _hydratedAnimalIds.add(animalId);
    return getLocalPesajesByAnimal(animalId);
  }

  @override
  Future<List<BrickPesajeModel>> getLocalPesajesByAnimal(
    String animalId,
  ) async {
    final pesajes = await getLocalPesajes();

    final pesajesById = <String, BrickPesajeModel>{};
    for (final pesaje in pesajes) {
      if (pesaje.animalId == animalId && pesaje.deletedAt == null) {
        pesajesById[pesaje.localId] = pesaje;
      }
    }

    final historial = pesajesById.values.toList()..sort((a, b) => a.date.compareTo(b.date));

    return historial;
  }

  @override
  Future<List<BrickPesajeModel>> getLocalPesajes() async {
    final pesajes = await _repository.getLocal<BrickPesajeModel>();
    final pesajesById = <String, BrickPesajeModel>{};

    // Se deduplica por UUID para sanear filas creadas por pulls anteriores que
    // no reconciliaban contra la clave primaria local.
    for (final pesaje in pesajes.where((item) => item.deletedAt == null)) {
      pesajesById[pesaje.localId] = pesaje;
    }

    return pesajesById.values.toList();
  }

  /// Aplica la respuesta del backend al pesaje local.
  ///
  /// `2xx` marca la pesada como sincronizada. Errores funcionales del backend la
  /// marcan como rechazada y guardan el codigo para mostrarlo en UI.
  Future<void> applyPesajeSyncResult(BackendSyncResult result) async {
    if (!BrickPesajeRequestTransformer.matchesPesajeResource(
      result.resourcePath,
    )) {
      return;
    }

    final storedPesajes = await _repository.getLocal<BrickPesajeModel>();

    for (final pesaje in storedPesajes) {
      if (pesaje.localId != result.localId) {
        continue;
      }

      final updatedPesaje = pesaje.copyWith(
        syncStatus: result.synchronized ? BrickPesajeSyncStatus.synchronized : BrickPesajeSyncStatus.rejected,
        syncErrorCode: result.errorCode,
      );
      await _repository.upsertLocal<BrickPesajeModel>(updatedPesaje);
      return;
    }
  }

  /// Libera la subscription interna del store.
  Future<void> dispose() async {
    await _syncSubscription.cancel();
  }
}

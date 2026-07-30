import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Contrato usado por features para acceder al catalogo de categorias con Brick.
///
/// Las features dependen de este contrato para no conocer los detalles internos
/// de [AppBrickRepository], SQLite, REST provider ni cola offline.
abstract class CategoriaBrickStore {
  /// Guarda una categoria propia localmente y la deja lista para sincronizar.
  Future<BrickCategoriaModel> upsertCategoria(BrickCategoriaModel categoria);

  /// Descarga el catalogo (global + propias) de [establishmentId] y lo cachea.
  Future<void> pullRemoteCategorias(String establishmentId);

  /// Lee desde SQLite las categorias visibles para [establishmentId].
  ///
  /// Devuelve el catalogo global (`establishmentId` null) mas las propias del
  /// establecimiento, excluyendo las borradas. Es la fuente del selector de
  /// categoria del alta de animal, disponible aun sin conexion.
  Future<List<BrickCategoriaModel>> getLocalCategorias(String establishmentId);
}

/// Store Brick especifico para operaciones de categorias.
///
/// La categoria es sobre todo un catalogo de lectura: el flujo pesado es el pull
/// remoto que cachea en SQLite para poblar selectores offline. Tambien admite
/// crear categorias propias offline, que se encolan como POST y se reconcilian
/// con los resultados de sync del backend.
class BrickCategoriaStore implements CategoriaBrickStore {
  BrickCategoriaStore._(this._repository) {
    _syncSubscription = _repository.syncResults.listen(
      applyCategoriaSyncResult,
    );
  }

  static BrickCategoriaStore? _instance;

  final AppBrickRepository _repository;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;

  /// Instancia compartida configurada durante el bootstrap de Brick.
  static BrickCategoriaStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError('BrickCategoriaStore has not been initialized yet.');
    }
    return store;
  }

  /// Configura el store de categorias una sola vez.
  static void configure(AppBrickRepository repository) {
    if (_instance != null) {
      return;
    }

    _instance = BrickCategoriaStore._(repository);
  }

  @override
  Future<BrickCategoriaModel> upsertCategoria(
    BrickCategoriaModel categoria,
  ) async {
    final savedCategoria = await _repository.upsertLocal<BrickCategoriaModel>(
      categoria,
    );

    // Igual que en animales: se guarda local primero y el POST remoto corre en
    // segundo plano para no bloquear la UX offline-first.
    unawaited(
      _repository.enqueueRemoteUpsert<BrickCategoriaModel>(savedCategoria),
    );

    return savedCategoria;
  }

  @override
  Future<void> pullRemoteCategorias(String establishmentId) async {
    final remoteCategorias = await _repository.remoteProvider
        .get<BrickCategoriaModel>(
          repository: _repository,
          query: Query(
            forProviders: [
              RestProviderQuery(
                request:
                    BrickCategoriaRequestTransformer.listByEstablishmentRequest(
                  establishmentId,
                ),
              ),
            ],
          ),
        );

    // Las categorias propias creadas offline y todavia no confirmadas no deben
    // ser pisadas por el pull (podrian no existir aun en el backend).
    final localCategorias = await _repository.getLocal<BrickCategoriaModel>();
    final localCategoriasById = {
      for (final categoria in localCategorias) categoria.localId: categoria,
    };
    final protectedLocalIds = localCategorias
        .where(
          (categoria) =>
              categoria.syncStatus == BrickCategoriaSyncStatus.pending ||
              categoria.syncStatus == BrickCategoriaSyncStatus.rejected,
        )
        .map((categoria) => categoria.localId)
        .toSet();

    for (final categoria in remoteCategorias) {
      if (protectedLocalIds.contains(categoria.localId)) {
        continue;
      }

      final synchronizedCategoria = categoria.copyWith(
        syncStatus: BrickCategoriaSyncStatus.synchronized,
        syncErrorCode: null,
      )..primaryKey = localCategoriasById[categoria.localId]?.primaryKey;
      await _repository.upsertLocal<BrickCategoriaModel>(
        synchronizedCategoria,
      );
    }
  }

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias(
    String establishmentId,
  ) async {
    final categorias = await _repository.getLocal<BrickCategoriaModel>();
    final categoriasById = <String, BrickCategoriaModel>{};

    // Las versiones previas podian duplicar el catalogo en cada pull. Se toma
    // una sola fila por UUID para que los consumidores vean una fuente estable.
    for (final categoria in categorias) {
      categoriasById[categoria.localId] = categoria;
    }

    return categoriasById.values
        .where(
          (categoria) =>
              categoria.deletedAt == null &&
              (categoria.establishmentId == null ||
                  categoria.establishmentId == establishmentId),
        )
        .toList();
  }

  /// Aplica la respuesta del backend a la categoria local.
  ///
  /// `2xx` la marca como sincronizada. Errores funcionales la marcan como
  /// rechazada y guardan el codigo para mostrarlo en UI.
  Future<void> applyCategoriaSyncResult(BackendSyncResult result) async {
    if (!BrickCategoriaRequestTransformer.matchesCategoriaResource(
      result.resourcePath,
    )) {
      return;
    }

    final storedCategorias = await _repository.getLocal<BrickCategoriaModel>();

    for (final categoria in storedCategorias) {
      if (categoria.localId != result.localId) {
        continue;
      }

      final updatedCategoria = categoria.copyWith(
        syncStatus: result.synchronized
            ? BrickCategoriaSyncStatus.synchronized
            : BrickCategoriaSyncStatus.rejected,
        syncErrorCode: result.errorCode,
      );
      await _repository.upsertLocal<BrickCategoriaModel>(updatedCategoria);
      return;
    }
  }

  /// Libera la subscription interna del store.
  Future<void> dispose() async {
    await _syncSubscription.cancel();
  }
}

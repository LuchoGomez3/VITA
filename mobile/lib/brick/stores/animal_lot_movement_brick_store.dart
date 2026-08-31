import 'dart:async';

import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';

/// Persistencia local y cola remota opcional para movimientos entre lotes.
class BrickAnimalLotMovementStore {
  BrickAnimalLotMovementStore._(
    this._repository, {
    required bool enableRemoteSync,
  }) : _enableRemoteSync = enableRemoteSync;

  static BrickAnimalLotMovementStore? _instance;

  final AppBrickRepository _repository;
  final bool _enableRemoteSync;

  /// Instancia configurada durante el bootstrap.
  static BrickAnimalLotMovementStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError('BrickAnimalLotMovementStore no fue inicializado.');
    }
    return store;
  }

  /// Configura el store una sola vez.
  static void configure(
    AppBrickRepository repository, {
    required bool enableRemoteSync,
  }) {
    _instance ??= BrickAnimalLotMovementStore._(
      repository,
      enableRemoteSync: enableRemoteSync,
    );
  }

  /// Guarda primero en SQLite y sólo encola REST cuando el contrato se habilite.
  Future<BrickAnimalLotMovementModel> save(
    BrickAnimalLotMovementModel movement,
  ) async {
    final saved = await _repository.upsertLocal(movement);
    if (_enableRemoteSync) {
      unawaited(_repository.enqueueRemoteUpsert(saved));
    }
    return saved;
  }

  // TODO(field-sync): escuchar BackendSyncResult y persistir estado
  // synchronized/rejected cuando backend implemente movimientos atómicos.
}

import 'dart:async';

import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/health_catalog.model.dart';
import 'package:frontend_mayoral/brick/models/health_event.model.dart';
import 'package:frontend_mayoral/brick/models/health_operation.model.dart';

/// Persiste todo el registro y los pendientes en la base principal de Brick.
class HealthBrickStore {
  /// Usa la base compartida de la aplicación.
  HealthBrickStore(this._repository);

  /// Instancia compartida por los flujos y la sincronización.
  static HealthBrickStore? instance;

  final AppBrickRepository _repository;
  Future<void> _tail = Future.value();

  /// Notifica cambios sanitarios después del commit.
  Stream<void> get changes => _repository.localChanges
      .where((type) => type == BrickHealthEventModel || type == BrickHealthOperationModel)
      .map((_) {});

  /// Serializa las lecturas que preceden a escrituras sanitarias locales.
  Future<T> serialize<T>(Future<T> Function() action) async {
    final previous = _tail;
    final completion = Completer<void>();
    _tail = completion.future;
    try {
      await previous;
      return await action();
    } finally {
      completion.complete();
    }
  }

  /// Lee el catálogo y cursor de un establecimiento.
  Future<BrickHealthCatalogModel?> catalog(String establishmentId) async =>
      (await _repository.getLocal<BrickHealthCatalogModel>())
          .where((row) => row.establishmentId == establishmentId)
          .firstOrNull;

  /// Lee los eventos locales del establecimiento y opcionalmente de un animal.
  Future<List<BrickHealthEventModel>> events(String establishmentId, {String? animalId}) async =>
      (await _repository.getLocal<BrickHealthEventModel>())
          .where((row) => row.establishmentId == establishmentId && (animalId == null || row.animalId == animalId))
          .toList();

  /// Lee pendientes y rechazos que pertenecen a esta cuenta.
  Future<List<BrickHealthOperationModel>> operations(String authorId, {String? establishmentId}) async {
    final rows =
        (await _repository.getLocal<BrickHealthOperationModel>())
            .where(
              (row) => row.authorId == authorId && (establishmentId == null || row.establishmentId == establishmentId),
            )
            .toList()
          ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return rows;
  }

  /// Encuentra las cargas locales que una actualización canónica deja sin efecto.
  Future<Iterable<BrickHealthOperationModel>> resultOperations(String establishmentId, Set<String> eventIds) async {
    if (eventIds.isEmpty) return const [];
    return (await _repository.getLocal<BrickHealthOperationModel>()).where(
      (row) => row.establishmentId == establishmentId && eventIds.contains(row.resultEventId),
    );
  }

  /// Escribe juntas las filas, la operación y el avance del historial.
  Future<void> save({
    Iterable<BrickHealthEventModel> events = const [],
    BrickHealthOperationModel? operation,
    Iterable<BrickHealthOperationModel> removing = const [],
    BrickHealthCatalogModel? catalog,
    void Function()? requireSession,
  }) => _repository.runLocalTransaction((transaction) async {
    requireSession?.call();
    for (final event in events) {
      await transaction.upsert(event);
    }
    if (operation != null) await transaction.upsert(operation);
    for (final previous in removing) {
      await transaction.delete(previous);
    }
    if (catalog != null) await transaction.upsert(catalog);
    requireSession?.call();
  });
}

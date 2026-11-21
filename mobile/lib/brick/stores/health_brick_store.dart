import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
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
      (await _repository.getLocal<BrickHealthCatalogModel>(
        query: Query.where('establishmentId', establishmentId, limit1: true),
      )).firstOrNull;

  /// Lee los eventos locales del establecimiento y opcionalmente de un animal.
  Future<List<BrickHealthEventModel>> events(String establishmentId, {String? animalId}) =>
      _repository.getLocal<BrickHealthEventModel>(
        query: Query(
          where: [
            Where('establishmentId').isExactly(establishmentId),
            if (animalId != null) Where('animalId').isExactly(animalId),
          ],
        ),
      );

  /// Lee un único evento dentro de su establecimiento.
  Future<BrickHealthEventModel?> event(String establishmentId, String eventId) async =>
      (await _repository.getLocal<BrickHealthEventModel>(
        query: Query(
          limit: 1,
          where: [
            Where('establishmentId').isExactly(establishmentId),
            Where('localId').isExactly(eventId),
          ],
        ),
      )).firstOrNull;

  /// Lee solo los eventos afectados por una operación o página.
  Future<List<BrickHealthEventModel>> eventsByIds(String establishmentId, Set<String> eventIds) =>
      _byEventIds(establishmentId, 'localId', eventIds);

  /// Lee pendientes y rechazos que pertenecen a esta cuenta.
  Future<List<BrickHealthOperationModel>> operations(String authorId, {String? establishmentId}) async {
    final rows = await _repository.getLocal<BrickHealthOperationModel>(
      query: Query(
        where: [
          Where('authorId').isExactly(authorId),
          if (establishmentId != null) Where('establishmentId').isExactly(establishmentId),
        ],
      ),
    );
    return rows.toList()..sort((left, right) => left.createdAt.compareTo(right.createdAt));
  }

  /// Encuentra las cargas locales que una actualización canónica deja sin efecto.
  Future<List<BrickHealthOperationModel>> resultOperations(String establishmentId, Set<String> eventIds) =>
      _byEventIds(establishmentId, 'resultEventId', eventIds);

  /// Lee los eventos de los que dependen los resultados pendientes.
  Future<List<BrickHealthEventModel>> resultParents(Map<String, Set<String>> idsByEstablishment) async => [
    for (final entry in idsByEstablishment.entries) ...await eventsByIds(entry.key, entry.value),
  ];

  Future<List<T>> _byEventIds<T extends OfflineFirstWithRestModel>(
    String establishmentId,
    String field,
    Set<String> eventIds,
  ) async {
    const batchSize = 500; // Deja margen para el resto de los parámetros SQL.
    final values = eventIds.toList();
    final rows = <T>[];
    for (var offset = 0; offset < values.length; offset += batchSize) {
      rows.addAll(
        await _repository.getLocal<T>(
          query: Query(
            where: [
              Where('establishmentId').isExactly(establishmentId),
              Where(field).isIn(values.skip(offset).take(batchSize).toList()),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  /// Escribe juntas las filas, las operaciones y el avance del historial.
  Future<void> save({
    Iterable<BrickHealthEventModel> events = const [],
    Iterable<BrickHealthOperationModel> operations = const [],
    Iterable<BrickHealthOperationModel> removing = const [],
    BrickHealthCatalogModel? catalog,
    void Function()? requireSession,
  }) => _repository.runLocalTransaction((transaction) async {
    requireSession?.call();
    for (final event in events) {
      await transaction.upsert(event);
    }
    for (final operation in operations) {
      await transaction.upsert(operation);
    }
    for (final previous in removing) {
      await transaction.delete(previous);
    }
    if (catalog != null) await transaction.upsert(catalog);
    requireSession?.call();
  });
}

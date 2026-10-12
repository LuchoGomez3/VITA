import 'dart:convert';

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const _unchangedMovementSyncErrorCode = Object();

/// Contrato REST de movimientos de hacienda entre lotes.
class BrickAnimalLotMovementRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer exigido por Brick.
  const BrickAnimalLotMovementRequestTransformer(super.query, super.instance);

  /// Endpoint acordado con backend.
  static const movementsPath = '/api/v1/movimientos_lotes';

  /// Crea el pull filtrado por establecimiento e incluyendo tombstones.
  static RestRequest listByEstablishmentRequest(String establishmentId) => RestRequest(
    url: '$movementsPath?establecimiento_id=${Uri.encodeQueryComponent(establishmentId)}&include_deleted=true',
    topLevelKey: 'data',
  );

  /// Identifica resultados de sincronización de movimientos.
  static bool matchesMovementResource(String resourcePath) => resourcePath.endsWith(movementsPath);

  @override
  RestRequest get get => const RestRequest(
    url: movementsPath,
    topLevelKey: 'data',
  );

  @override
  RestRequest get upsert => const RestRequest(
    method: 'POST',
    url: movementsPath,
  );
}

/// Movimiento durable de uno o varios animales entre lotes.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickAnimalLotMovementRequestTransformer.new,
  ),
)
class BrickAnimalLotMovementModel extends OfflineFirstWithRestModel {
  /// Crea el registro técnico persistido localmente.
  BrickAnimalLotMovementModel({
    required this.localId,
    required this.establishmentId,
    required this.sourceLotId,
    required this.destinationLotId,
    required this.animalIdsJson,
    required this.occurredAt,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
    this.responsibleId,
    this.deletedAt,
    this.syncStatus = BrickAnimalLotMovementSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado por mobile.
  @Rest(name: 'id')
  final String localId;

  /// Tenant al que pertenece el movimiento.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Lote de procedencia.
  @Rest(name: 'lote_origen_id')
  final String? sourceLotId;

  /// Lote de destino.
  @Rest(name: 'lote_destino_id')
  final String destinationLotId;

  /// UUID de animales serializados para SQLite y enviados como lista REST.
  @Rest(
    name: 'animal_ids',
    toGenerator: 'brickMovementAnimalIdsToBackend(%INSTANCE_PROPERTY%)',
    fromGenerator: 'brickMovementAnimalIdsFromBackend(%DATA_PROPERTY%)',
  )
  final String animalIdsJson;

  /// Fecha efectiva elegida por el usuario.
  @Rest(name: 'fecha_movimiento')
  final DateTime occurredAt;

  /// Motivo operativo obligatorio.
  @Rest(name: 'motivo')
  final String reason;

  /// Usuario responsable devuelto por backend a partir del JWT.
  @Rest(name: 'responsable_id', ignoreTo: true)
  final String? responsibleId;

  /// Auditoría offline-first.
  @Rest(name: 'created_at')
  final DateTime createdAt;

  /// Auditoría para resolución LWW futura.
  @Rest(name: 'updated_at')
  final DateTime updatedAt;

  /// Tombstone sincronizable.
  @Rest(name: 'deleted_at')
  final DateTime? deletedAt;

  /// Estado local de sincronización del agregado.
  @Rest(ignore: true)
  @Sqlite(
    fromGenerator: 'brickMovementSyncStatusFromSqlite(%DATA_PROPERTY%)',
    toGenerator: 'BrickAnimalLotMovementSyncStatus.values.indexOf(%INSTANCE_PROPERTY%)',
  )
  final BrickAnimalLotMovementSyncStatus syncStatus;

  /// Código funcional del último rechazo remoto.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Crea una copia reconciliada conservando la fila SQLite.
  BrickAnimalLotMovementModel copyWith({
    BrickAnimalLotMovementSyncStatus? syncStatus,
    Object? syncErrorCode = _unchangedMovementSyncErrorCode,
  }) {
    final nextSyncErrorCode =
        identical(
          syncErrorCode,
          _unchangedMovementSyncErrorCode,
        )
        ? this.syncErrorCode
        : syncErrorCode as String?;
    return BrickAnimalLotMovementModel(
      localId: localId,
      establishmentId: establishmentId,
      sourceLotId: sourceLotId,
      destinationLotId: destinationLotId,
      animalIdsJson: animalIdsJson,
      occurredAt: occurredAt,
      reason: reason,
      responsibleId: responsibleId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncErrorCode: nextSyncErrorCode,
    )..primaryKey = primaryKey;
  }
}

/// Estado técnico de sincronización de un movimiento.
enum BrickAnimalLotMovementSyncStatus {
  /// Existe localmente y espera confirmación remota.
  pending,

  /// Backend confirmó el movimiento atómico.
  synchronized,

  /// Backend rechazó el movimiento por una regla autoritativa.
  rejected,
}

/// Interpreta como pendiente una fila creada antes de incorporar el estado.
BrickAnimalLotMovementSyncStatus brickMovementSyncStatusFromSqlite(
  Object? value,
) {
  if (value is int && value >= 0 && value < BrickAnimalLotMovementSyncStatus.values.length) {
    return BrickAnimalLotMovementSyncStatus.values[value];
  }
  return BrickAnimalLotMovementSyncStatus.pending;
}

/// Convierte la representación SQLite a la lista esperada por REST.
Object brickMovementAnimalIdsToBackend(String encoded) => jsonDecode(encoded) as Object;

/// Convierte la lista REST a texto estable para SQLite.
String brickMovementAnimalIdsFromBackend(Object? value) => jsonEncode(value);

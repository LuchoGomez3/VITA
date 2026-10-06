import 'dart:convert';

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

/// Contrato REST batch de asignación inicial y traslado entre lotes.
class BrickAnimalLotMovementRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer exigido por Brick.
  const BrickAnimalLotMovementRequestTransformer(super.query, super.instance);

  /// Endpoint batch atómico e idempotente por UUID del cliente.
  static const movementsPath = '/api/v1/movimientos_lotes';

  /// Descarga el historial del establecimiento, incluidos tombstones.
  static RestRequest listRequest(String establishmentId) => RestRequest(
    url: '$movementsPath?establecimiento_id=${Uri.encodeQueryComponent(establishmentId)}&include_deleted=true',
    topLevelKey: 'data',
  );

  /// Alias conservado para los consumidores del sync inicial existente.
  static RestRequest listByEstablishmentRequest(String establishmentId) => listRequest(establishmentId);

  /// Indica si un resultado HTTP pertenece al recurso de movimientos.
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
    this.syncStatus = BrickMovementSyncStatus.pending,
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

  /// Auditoría recibida del servidor: jamás se envía un responsable desde mobile.
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

  /// Estado del movimiento independiente de las ediciones del animal.
  @Rest(ignore: true)
  @Sqlite(fromGenerator: 'brickMovementStatusFromSqlite(%DATA_PROPERTY%)')
  final BrickMovementSyncStatus syncStatus;

  /// Rechazo durable que permite mostrar y reintentar la misma operación.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Cambia el resultado técnico conservando UUID, payload y fila SQLite.
  BrickAnimalLotMovementModel withSync(BrickMovementSyncStatus status, {String? errorCode}) =>
      BrickAnimalLotMovementModel(
        localId: localId,
        establishmentId: establishmentId,
        sourceLotId: sourceLotId,
        destinationLotId: destinationLotId,
        animalIdsJson: animalIdsJson,
        occurredAt: occurredAt,
        reason: reason,
        createdAt: createdAt,
        updatedAt: updatedAt,
        responsibleId: responsibleId,
        deletedAt: deletedAt,
        syncStatus: status,
        syncErrorCode: errorCode,
      )..primaryKey = primaryKey;
}

/// Resultado durable del envío del movimiento.
enum BrickMovementSyncStatus {
  /// Guardado localmente y todavía no confirmado.
  pending,

  /// Confirmado por el servidor.
  synchronized,

  /// Rechazado; conserva el payload para revisión y reintento explícito.
  rejected,
}

/// Nombre histórico conservado para no romper consumidores existentes.
typedef BrickAnimalLotMovementSyncStatus = BrickMovementSyncStatus;

/// Las filas previas a la migración todavía no tienen un estado de sync.
BrickMovementSyncStatus brickMovementStatusFromSqlite(Object? value) =>
    BrickMovementSyncStatus.values[(value as int?) ?? 0];

/// Convierte la representación SQLite a la lista esperada por REST.
Object brickMovementAnimalIdsToBackend(String encoded) => jsonDecode(encoded) as Object;

/// Convierte la lista REST a texto estable para SQLite.
String brickMovementAnimalIdsFromBackend(Object? value) => jsonEncode(value);

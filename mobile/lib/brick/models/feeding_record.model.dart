import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const _unchangedFeedingSyncErrorCode = Object();

/// Contrato REST de los registros de alimentación.
class BrickFeedingRecordRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer exigido por Brick.
  const BrickFeedingRecordRequestTransformer(super.query, super.instance);

  /// Endpoint acordado con backend (adr-0015).
  static const recordsPath = '/api/v1/registros_alimentacion';

  /// Crea el pull filtrado por establecimiento e incluyendo tombstones.
  static RestRequest listByEstablishmentRequest(String establishmentId) => RestRequest(
    url: '$recordsPath?establecimiento_id=${Uri.encodeQueryComponent(establishmentId)}&include_deleted=true',
    topLevelKey: 'data',
  );

  /// Identifica resultados de sincronización de registros.
  static bool matchesRecordResource(String resourcePath) => resourcePath.endsWith(recordsPath);

  @override
  RestRequest get get => const RestRequest(url: recordsPath, topLevelKey: 'data');

  @override
  RestRequest get upsert => const RestRequest(method: 'POST', url: recordsPath);
}

/// Suplemento o dieta que recibieron uno o varios animales.
///
/// Las fechas son días calendario (`yyyy-MM-dd`) guardados como texto, y la
/// cantidad viaja como decimal en texto para no perder precisión.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(requestTransformer: BrickFeedingRecordRequestTransformer.new),
)
class BrickFeedingRecordModel extends OfflineFirstWithRestModel {
  /// Crea el registro técnico persistido localmente.
  BrickFeedingRecordModel({
    required this.localId,
    required this.establishmentId,
    required this.type,
    required this.foodId,
    required this.startDate,
    required this.quantity,
    required this.unit,
    required this.quantityBasis,
    required this.animalIdsJson,
    required this.createdAt,
    required this.updatedAt,
    this.lotId,
    this.endDate,
    this.reason,
    this.responsibleId,
    this.deletedAt,
    this.syncStatus = BrickFeedingRecordSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado por mobile: clave de idempotencia de la cola.
  @Rest(name: 'id')
  final String localId;

  /// Tenant del registro.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// `suplemento` o `dieta`.
  @Rest(name: 'tipo')
  final String type;

  /// Alimento suministrado.
  @Rest(name: 'alimento_id')
  final String foodId;

  /// Potrero donde se suministró; null = corral o manga.
  @Rest(name: 'lote_id')
  final String? lotId;

  /// Primer día (`yyyy-MM-dd`).
  @Rest(name: 'fecha_desde')
  final String startDate;

  /// Último día (`yyyy-MM-dd`); null = en curso.
  @Rest(name: 'fecha_hasta')
  final String? endDate;

  /// Cantidad decimal en texto.
  @Rest(
    name: 'cantidad',
    fromGenerator: 'brickFeedingQuantityFromBackend(%DATA_PROPERTY%)',
  )
  final String quantity;

  /// Código de `UnidadAlimento`.
  @Rest(name: 'unidad')
  final String unit;

  /// `por_animal_dia` o `grupo_dia`.
  @Rest(name: 'base_cantidad')
  final String quantityBasis;

  /// Motivo opcional ("Sequía").
  @Rest(name: 'motivo')
  final String? reason;

  /// UUID de animales serializados para SQLite y enviados como lista REST.
  @Rest(
    name: 'animal_ids',
    toGenerator: 'brickMovementAnimalIdsToBackend(%INSTANCE_PROPERTY%)',
    fromGenerator: 'brickMovementAnimalIdsFromBackend(%DATA_PROPERTY%)',
  )
  final String animalIdsJson;

  /// Responsable devuelto por backend a partir del JWT.
  @Rest(name: 'responsable_id', ignoreTo: true)
  final String? responsibleId;

  /// Auditoría offline-first.
  @Rest(name: 'created_at')
  final DateTime createdAt;

  /// Resolución de conflictos last-write-wins.
  @Rest(name: 'updated_at')
  final DateTime updatedAt;

  /// Tombstone sincronizable.
  @Rest(name: 'deleted_at')
  final DateTime? deletedAt;

  /// Estado local de sincronización.
  @Rest(ignore: true)
  @Sqlite(
    fromGenerator: 'brickFeedingRecordSyncStatusFromSqlite(%DATA_PROPERTY%)',
    toGenerator: 'BrickFeedingRecordSyncStatus.values.indexOf(%INSTANCE_PROPERTY%)',
  )
  final BrickFeedingRecordSyncStatus syncStatus;

  /// Código funcional del último rechazo remoto.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Crea una copia conservando la fila SQLite.
  BrickFeedingRecordModel copyWith({
    BrickFeedingRecordSyncStatus? syncStatus,
    Object? syncErrorCode = _unchangedFeedingSyncErrorCode,
  }) => BrickFeedingRecordModel(
    localId: localId,
    establishmentId: establishmentId,
    type: type,
    foodId: foodId,
    lotId: lotId,
    startDate: startDate,
    endDate: endDate,
    quantity: quantity,
    unit: unit,
    quantityBasis: quantityBasis,
    reason: reason,
    animalIdsJson: animalIdsJson,
    responsibleId: responsibleId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncErrorCode: identical(syncErrorCode, _unchangedFeedingSyncErrorCode)
        ? this.syncErrorCode
        : syncErrorCode as String?,
  )..primaryKey = primaryKey;
}

/// Estado técnico de sincronización de un registro.
enum BrickFeedingRecordSyncStatus {
  /// Existe localmente y espera confirmación remota.
  pending,

  /// Backend lo confirmó.
  synchronized,

  /// Backend lo rechazó.
  rejected,
}

/// Interpreta como pendiente un valor desconocido.
BrickFeedingRecordSyncStatus brickFeedingRecordSyncStatusFromSqlite(Object? value) {
  if (value is int && value >= 0 && value < BrickFeedingRecordSyncStatus.values.length) {
    return BrickFeedingRecordSyncStatus.values[value];
  }
  return BrickFeedingRecordSyncStatus.pending;
}

/// Backend devuelve la cantidad como texto ("2.500"); se tolera un número.
String brickFeedingQuantityFromBackend(Object? value) => value?.toString() ?? '0';

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const _unchangedForagePeriodSyncErrorCode = Object();

/// Contrato REST del historial de recursos forrajeros de los lotes.
class BrickLotForagePeriodRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer exigido por Brick.
  const BrickLotForagePeriodRequestTransformer(super.query, super.instance);

  /// Endpoint acordado con backend (adr-0015).
  static const periodsPath = '/api/v1/lotes_recursos_forrajeros';

  /// Crea el pull filtrado por establecimiento e incluyendo tombstones.
  static RestRequest listByEstablishmentRequest(String establishmentId) => RestRequest(
    url: '$periodsPath?establecimiento_id=${Uri.encodeQueryComponent(establishmentId)}&include_deleted=true',
    topLevelKey: 'data',
  );

  /// Identifica resultados de sincronización de períodos.
  static bool matchesPeriodResource(String resourcePath) => resourcePath.endsWith(periodsPath);

  @override
  RestRequest get get => const RestRequest(url: periodsPath, topLevelKey: 'data');

  @override
  RestRequest get upsert => const RestRequest(method: 'POST', url: periodsPath);
}

/// Período en el que un lote tuvo un recurso forrajero.
///
/// Las fechas son días calendario (`yyyy-MM-dd`) y se guardan como texto: un
/// `DateTime` a medianoche se correría de día al pasar por UTC.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickLotForagePeriodRequestTransformer.new,
  ),
)
class BrickLotForagePeriodModel extends OfflineFirstWithRestModel {
  /// Crea el registro técnico persistido localmente.
  BrickLotForagePeriodModel({
    required this.localId,
    required this.establishmentId,
    required this.lotId,
    required this.forageResourceCode,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.endDate,
    this.registeredById,
    this.deletedAt,
    this.syncStatus = BrickLotForagePeriodSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado por mobile.
  @Rest(name: 'id')
  final String localId;

  /// Tenant al que pertenece el lote.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Lote al que se refiere el período.
  @Rest(name: 'lote_id')
  final String lotId;

  /// Código del catálogo `RecursoForrajero`.
  @Rest(name: 'recurso_forrajero_codigo')
  final String forageResourceCode;

  /// Detalle libre; obligatorio cuando el código es `otro`.
  @Rest(name: 'descripcion')
  final String? description;

  /// Primer día del período (`yyyy-MM-dd`).
  @Rest(name: 'fecha_desde')
  final String startDate;

  /// Último día de un corte explícito (`yyyy-MM-dd`); null si sigue vigente.
  @Rest(name: 'fecha_hasta')
  final String? endDate;

  /// Usuario que lo registró, devuelto por backend a partir del JWT.
  @Rest(name: 'registrado_por_id', ignoreTo: true)
  final String? registeredById;

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
    fromGenerator: 'brickForagePeriodSyncStatusFromSqlite(%DATA_PROPERTY%)',
    toGenerator: 'BrickLotForagePeriodSyncStatus.values.indexOf(%INSTANCE_PROPERTY%)',
  )
  final BrickLotForagePeriodSyncStatus syncStatus;

  /// Código funcional del último rechazo remoto.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Crea una copia conservando la fila SQLite.
  BrickLotForagePeriodModel copyWith({
    BrickLotForagePeriodSyncStatus? syncStatus,
    Object? syncErrorCode = _unchangedForagePeriodSyncErrorCode,
  }) {
    final nextSyncErrorCode = identical(syncErrorCode, _unchangedForagePeriodSyncErrorCode)
        ? this.syncErrorCode
        : syncErrorCode as String?;
    return BrickLotForagePeriodModel(
      localId: localId,
      establishmentId: establishmentId,
      lotId: lotId,
      forageResourceCode: forageResourceCode,
      description: description,
      startDate: startDate,
      endDate: endDate,
      registeredById: registeredById,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncErrorCode: nextSyncErrorCode,
    )..primaryKey = primaryKey;
  }
}

/// Estado técnico de sincronización de un período.
enum BrickLotForagePeriodSyncStatus {
  /// Existe localmente y espera confirmación remota.
  pending,

  /// Backend confirmó el período.
  synchronized,

  /// Backend lo rechazó por una regla autoritativa.
  rejected,
}

/// Interpreta como pendiente un valor desconocido.
BrickLotForagePeriodSyncStatus brickForagePeriodSyncStatusFromSqlite(Object? value) {
  if (value is int && value >= 0 && value < BrickLotForagePeriodSyncStatus.values.length) {
    return BrickLotForagePeriodSyncStatus.values[value];
  }
  return BrickLotForagePeriodSyncStatus.pending;
}

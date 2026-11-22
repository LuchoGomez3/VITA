import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const _unchangedFoodSyncErrorCode = Object();

/// Contrato REST del catálogo de alimentos del establecimiento.
class BrickFoodRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer exigido por Brick.
  const BrickFoodRequestTransformer(super.query, super.instance);

  /// Endpoint acordado con backend (adr-0015).
  static const foodsPath = '/api/v1/alimentos';

  /// Crea el pull filtrado por establecimiento e incluyendo tombstones.
  static RestRequest listByEstablishmentRequest(String establishmentId) => RestRequest(
    url: '$foodsPath?establecimiento_id=${Uri.encodeQueryComponent(establishmentId)}&include_deleted=true',
    topLevelKey: 'data',
  );

  /// Identifica resultados de sincronización de alimentos.
  static bool matchesFoodResource(String resourcePath) => resourcePath.endsWith(foodsPath);

  @override
  RestRequest get get => const RestRequest(url: foodsPath, topLevelKey: 'data');

  @override
  RestRequest get upsert => const RestRequest(method: 'POST', url: foodsPath);
}

/// Alimento del catálogo (grano, rollo, núcleo, sales...).
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(requestTransformer: BrickFoodRequestTransformer.new),
)
class BrickFoodModel extends OfflineFirstWithRestModel {
  /// Crea el registro técnico persistido localmente.
  BrickFoodModel({
    required this.localId,
    required this.name,
    required this.category,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
    this.establishmentId,
    this.createdById,
    this.deletedAt,
    this.syncStatus = BrickFoodSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado por mobile.
  @Rest(name: 'id')
  final String localId;

  /// Tenant; null en el catálogo global, que es de solo lectura.
  @Rest(name: 'establecimiento_id')
  final String? establishmentId;

  /// Nombre visible ("Maíz partido").
  @Rest(name: 'nombre')
  final String name;

  /// Código de `CategoriaAlimento`.
  @Rest(name: 'categoria')
  final String category;

  /// Código de `UnidadAlimento` por defecto.
  @Rest(name: 'unidad')
  final String unit;

  /// Autor, devuelto por backend a partir del JWT.
  @Rest(name: 'creado_por_id', ignoreTo: true)
  final String? createdById;

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
    fromGenerator: 'brickFoodSyncStatusFromSqlite(%DATA_PROPERTY%)',
    toGenerator: 'BrickFoodSyncStatus.values.indexOf(%INSTANCE_PROPERTY%)',
  )
  final BrickFoodSyncStatus syncStatus;

  /// Código funcional del último rechazo remoto.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Crea una copia conservando la fila SQLite.
  BrickFoodModel copyWith({
    BrickFoodSyncStatus? syncStatus,
    Object? syncErrorCode = _unchangedFoodSyncErrorCode,
  }) => BrickFoodModel(
    localId: localId,
    establishmentId: establishmentId,
    name: name,
    category: category,
    unit: unit,
    createdById: createdById,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncErrorCode: identical(syncErrorCode, _unchangedFoodSyncErrorCode)
        ? this.syncErrorCode
        : syncErrorCode as String?,
  )..primaryKey = primaryKey;
}

/// Estado técnico de sincronización de un alimento.
enum BrickFoodSyncStatus {
  /// Existe localmente y espera confirmación remota.
  pending,

  /// Backend lo confirmó.
  synchronized,

  /// Backend lo rechazó.
  rejected,
}

/// Interpreta como pendiente un valor desconocido.
BrickFoodSyncStatus brickFoodSyncStatusFromSqlite(Object? value) {
  if (value is int && value >= 0 && value < BrickFoodSyncStatus.values.length) {
    return BrickFoodSyncStatus.values[value];
  }
  return BrickFoodSyncStatus.pending;
}

// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickLotModel> _$BrickLotModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickLotModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    name: data['nombre'] as String,
    boundaryJson: brickLotGeometryFromBackend(data['geometria_local']),
    geometryMode: data['geometry_mode'] as String,
    surfaceTenths: brickLotSurfaceFromBackend(data['superficie_ha']),
    forageResourceCode: data['recurso_forrajero_codigo'] == null ? null : data['recurso_forrajero_codigo'] as String?,
    hasWater: data['tiene_agua'] as bool,
    statusCode: data['estado'] as String,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickLotModelToRest(
  BrickLotModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'nombre': instance.name,
    'geometria_local': brickLotGeometryToBackend(instance.boundaryJson),
    'geometry_mode': instance.geometryMode,
    'superficie_ha': brickLotSurfaceToBackend(instance.surfaceTenths),
    'recurso_forrajero_codigo': instance.forageResourceCode,
    'tiene_agua': instance.hasWater,
    'estado': instance.statusCode,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickLotModel> _$BrickLotModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickLotModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    name: data['name'] as String,
    boundaryJson: data['boundary_json'] as String,
    geometryMode: data['geometry_mode'] as String,
    surfaceTenths: data['surface_tenths'] as int,
    forageResourceCode: data['forage_resource_code'] == null ? null : data['forage_resource_code'] as String?,
    hasWater: data['has_water'] == 1,
    statusCode: data['status_code'] as String,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
    syncStatus: BrickLotSyncStatus.values[data['sync_status'] as int],
    syncErrorCode: data['sync_error_code'] == null ? null : data['sync_error_code'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickLotModelToSqlite(
  BrickLotModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'name': instance.name,
    'boundary_json': instance.boundaryJson,
    'geometry_mode': instance.geometryMode,
    'surface_tenths': instance.surfaceTenths,
    'forage_resource_code': instance.forageResourceCode,
    'has_water': instance.hasWater ? 1 : 0,
    'status_code': instance.statusCode,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
    'sync_status': BrickLotSyncStatus.values.indexOf(instance.syncStatus),
    'sync_error_code': instance.syncErrorCode,
  };
}

/// Construct a [BrickLotModel]
class BrickLotModelAdapter extends OfflineFirstWithRestAdapter<BrickLotModel> {
  BrickLotModelAdapter();

  @override
  final restRequest = BrickLotRequestTransformer.new;
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'localId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'local_id',
      iterable: false,
      type: String,
    ),
    'establishmentId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'establishment_id',
      iterable: false,
      type: String,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name',
      iterable: false,
      type: String,
    ),
    'boundaryJson': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'boundary_json',
      iterable: false,
      type: String,
    ),
    'geometryMode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'geometry_mode',
      iterable: false,
      type: String,
    ),
    'surfaceTenths': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'surface_tenths',
      iterable: false,
      type: int,
    ),
    'forageResourceCode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'forage_resource_code',
      iterable: false,
      type: String,
    ),
    'hasWater': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_water',
      iterable: false,
      type: bool,
    ),
    'statusCode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status_code',
      iterable: false,
      type: String,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: DateTime,
    ),
    'updatedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'updated_at',
      iterable: false,
      type: DateTime,
    ),
    'deletedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'deleted_at',
      iterable: false,
      type: DateTime,
    ),
    'syncStatus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sync_status',
      iterable: false,
      type: BrickLotSyncStatus,
    ),
    'syncErrorCode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sync_error_code',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BrickLotModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickLotModel';

  @override
  Future<BrickLotModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLotModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickLotModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLotModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickLotModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLotModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickLotModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLotModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

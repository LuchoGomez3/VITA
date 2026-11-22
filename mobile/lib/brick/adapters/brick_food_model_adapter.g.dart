// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickFoodModel> _$BrickFoodModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickFoodModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] == null
        ? null
        : data['establecimiento_id'] as String?,
    name: data['nombre'] as String,
    category: data['categoria'] as String,
    unit: data['unidad'] as String,
    createdById: data['creado_por_id'] == null
        ? null
        : data['creado_por_id'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickFoodModelToRest(
  BrickFoodModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'nombre': instance.name,
    'categoria': instance.category,
    'unidad': instance.unit,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickFoodModel> _$BrickFoodModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickFoodModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] == null
        ? null
        : data['establishment_id'] as String?,
    name: data['name'] as String,
    category: data['category'] as String,
    unit: data['unit'] as String,
    createdById: data['created_by_id'] == null
        ? null
        : data['created_by_id'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
    syncStatus: brickFoodSyncStatusFromSqlite(data['sync_status']),
    syncErrorCode: data['sync_error_code'] == null
        ? null
        : data['sync_error_code'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickFoodModelToSqlite(
  BrickFoodModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'name': instance.name,
    'category': instance.category,
    'unit': instance.unit,
    'created_by_id': instance.createdById,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
    'sync_status': BrickFoodSyncStatus.values.indexOf(instance.syncStatus),
    'sync_error_code': instance.syncErrorCode,
  };
}

/// Construct a [BrickFoodModel]
class BrickFoodModelAdapter
    extends OfflineFirstWithRestAdapter<BrickFoodModel> {
  BrickFoodModelAdapter();

  @override
  final restRequest = BrickFoodRequestTransformer.new;
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
    'category': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'category',
      iterable: false,
      type: String,
    ),
    'unit': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'unit',
      iterable: false,
      type: String,
    ),
    'createdById': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_by_id',
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
      type: BrickFoodSyncStatus,
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
    BrickFoodModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickFoodModel';

  @override
  Future<BrickFoodModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickFoodModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickFoodModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickFoodModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickFoodModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickFoodModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickFoodModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickFoodModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

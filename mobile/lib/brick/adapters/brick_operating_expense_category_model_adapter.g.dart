// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickOperatingExpenseCategoryModel> _$BrickOperatingExpenseCategoryModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickOperatingExpenseCategoryModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    type: data['tipo'] as String,
    name: data['nombre'] as String,
    value: data['valor'] as String,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickOperatingExpenseCategoryModelToRest(
  BrickOperatingExpenseCategoryModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'tipo': instance.type,
    'nombre': instance.name,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickOperatingExpenseCategoryModel> _$BrickOperatingExpenseCategoryModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickOperatingExpenseCategoryModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    type: data['type'] as String,
    name: data['name'] as String,
    value: data['value'] as String,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
    syncStatus: BrickOperatingExpenseCategorySyncStatus.values[data['sync_status'] as int],
    syncErrorCode: data['sync_error_code'] == null ? null : data['sync_error_code'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickOperatingExpenseCategoryModelToSqlite(
  BrickOperatingExpenseCategoryModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'type': instance.type,
    'name': instance.name,
    'value': instance.value,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
    'sync_status': BrickOperatingExpenseCategorySyncStatus.values.indexOf(
      instance.syncStatus,
    ),
    'sync_error_code': instance.syncErrorCode,
  };
}

/// Construct a [BrickOperatingExpenseCategoryModel]
class BrickOperatingExpenseCategoryModelAdapter
    extends OfflineFirstWithRestAdapter<BrickOperatingExpenseCategoryModel> {
  BrickOperatingExpenseCategoryModelAdapter();

  @override
  final restRequest = BrickOperatingExpenseCategoryRequestTransformer.new;
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
    'type': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'type',
      iterable: false,
      type: String,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name',
      iterable: false,
      type: String,
    ),
    'value': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'value',
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
      type: BrickOperatingExpenseCategorySyncStatus,
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
    BrickOperatingExpenseCategoryModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickOperatingExpenseCategoryModel';

  @override
  Future<BrickOperatingExpenseCategoryModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickOperatingExpenseCategoryModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickOperatingExpenseCategoryModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickOperatingExpenseCategoryModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickOperatingExpenseCategoryModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickOperatingExpenseCategoryModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickOperatingExpenseCategoryModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickOperatingExpenseCategoryModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickCategoriaModel> _$BrickCategoriaModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickCategoriaModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] == null
        ? null
        : data['establecimiento_id'] as String?,
    name: data['nombre'] as String,
    description: data['descripcion'] == null
        ? null
        : data['descripcion'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickCategoriaModelToRest(
  BrickCategoriaModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'nombre': instance.name,
    'descripcion': instance.description,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickCategoriaModel> _$BrickCategoriaModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickCategoriaModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] == null
        ? null
        : data['establishment_id'] as String?,
    name: data['name'] as String,
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    syncStatus: BrickCategoriaSyncStatus.values[data['sync_status'] as int],
    syncErrorCode: data['sync_error_code'] == null
        ? null
        : data['sync_error_code'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickCategoriaModelToSqlite(
  BrickCategoriaModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'name': instance.name,
    'description': instance.description,
    'sync_status': BrickCategoriaSyncStatus.values.indexOf(instance.syncStatus),
    'sync_error_code': instance.syncErrorCode,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

/// Construct a [BrickCategoriaModel]
class BrickCategoriaModelAdapter
    extends OfflineFirstWithRestAdapter<BrickCategoriaModel> {
  BrickCategoriaModelAdapter();

  @override
  final restRequest = BrickCategoriaRequestTransformer.new;
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
    'description': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description',
      iterable: false,
      type: String,
    ),
    'syncStatus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sync_status',
      iterable: false,
      type: BrickCategoriaSyncStatus,
    ),
    'syncErrorCode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sync_error_code',
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
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BrickCategoriaModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickCategoriaModel';

  @override
  Future<BrickCategoriaModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickCategoriaModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickCategoriaModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickCategoriaModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickCategoriaModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickCategoriaModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickCategoriaModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickCategoriaModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

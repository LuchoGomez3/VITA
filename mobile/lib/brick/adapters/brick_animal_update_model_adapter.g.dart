// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickAnimalUpdateModel> _$BrickAnimalUpdateModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickAnimalUpdateModel(
    localId: data['id'] as String,
    categoryId: data['categoria_id'] == null
        ? null
        : data['categoria_id'] as String?,
    status: data['estado'] as String,
    reproductiveStatus: data['estado_reproductivo'] == null
        ? null
        : data['estado_reproductivo'] as String?,
    updatedAt: DateTime.parse(data['updated_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickAnimalUpdateModelToRest(
  BrickAnimalUpdateModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'categoria_id': instance.categoryId,
    'estado': instance.status,
    'estado_reproductivo': instance.reproductiveStatus,
    'updated_at': instance.updatedAt.toIso8601String(),
  };
}

Future<BrickAnimalUpdateModel> _$BrickAnimalUpdateModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickAnimalUpdateModel(
    localId: data['local_id'] as String,
    categoryId: data['category_id'] == null
        ? null
        : data['category_id'] as String?,
    status: data['status'] as String,
    reproductiveStatus: data['reproductive_status'] == null
        ? null
        : data['reproductive_status'] as String?,
    updatedAt: DateTime.parse(data['updated_at'] as String),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickAnimalUpdateModelToSqlite(
  BrickAnimalUpdateModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'category_id': instance.categoryId,
    'status': instance.status,
    'reproductive_status': instance.reproductiveStatus,
    'updated_at': instance.updatedAt.toIso8601String(),
  };
}

/// Construct a [BrickAnimalUpdateModel]
class BrickAnimalUpdateModelAdapter
    extends OfflineFirstWithRestAdapter<BrickAnimalUpdateModel> {
  BrickAnimalUpdateModelAdapter();

  @override
  final restRequest = BrickAnimalUpdateRequestTransformer.new;
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
    'categoryId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'category_id',
      iterable: false,
      type: String,
    ),
    'status': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status',
      iterable: false,
      type: String,
    ),
    'reproductiveStatus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'reproductive_status',
      iterable: false,
      type: String,
    ),
    'updatedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'updated_at',
      iterable: false,
      type: DateTime,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BrickAnimalUpdateModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickAnimalUpdateModel';

  @override
  Future<BrickAnimalUpdateModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalUpdateModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickAnimalUpdateModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalUpdateModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickAnimalUpdateModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalUpdateModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickAnimalUpdateModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalUpdateModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

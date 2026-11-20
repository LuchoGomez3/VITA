// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickHealthCatalogModel> _$BrickHealthCatalogModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickHealthCatalogModel(
    establishmentId: data['establishment_id'] as String,
    payload: data['payload'] == null ? null : data['payload'] as String?,
    cursor: data['cursor'] == null ? null : data['cursor'] as String?,
  );
}

Future<Map<String, dynamic>> _$BrickHealthCatalogModelToRest(
  BrickHealthCatalogModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'establishment_id': instance.establishmentId,
    'payload': instance.payload,
    'cursor': instance.cursor,
  };
}

Future<BrickHealthCatalogModel> _$BrickHealthCatalogModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickHealthCatalogModel(
    establishmentId: data['establishment_id'] as String,
    payload: data['payload'] == null ? null : data['payload'] as String?,
    cursor: data['cursor'] == null ? null : data['cursor'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickHealthCatalogModelToSqlite(
  BrickHealthCatalogModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'establishment_id': instance.establishmentId,
    'payload': instance.payload,
    'cursor': instance.cursor,
  };
}

/// Construct a [BrickHealthCatalogModel]
class BrickHealthCatalogModelAdapter
    extends OfflineFirstWithRestAdapter<BrickHealthCatalogModel> {
  BrickHealthCatalogModelAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'establishmentId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'establishment_id',
      iterable: false,
      type: String,
    ),
    'payload': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'payload',
      iterable: false,
      type: String,
    ),
    'cursor': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'cursor',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BrickHealthCatalogModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `BrickHealthCatalogModel` WHERE establishment_id = ? LIMIT 1''',
      [instance.establishmentId],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'BrickHealthCatalogModel';

  @override
  Future<BrickHealthCatalogModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthCatalogModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickHealthCatalogModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthCatalogModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickHealthCatalogModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthCatalogModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickHealthCatalogModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthCatalogModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

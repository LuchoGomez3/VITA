// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickHealthOperationModel> _$BrickHealthOperationModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickHealthOperationModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    authorId: data['author_id'] as String,
    createdAt: DateTime.parse(data['created_at'] as String),
    payload: data['payload'] as String,
    resultEventId: data['result_event_id'] == null
        ? null
        : data['result_event_id'] as String?,
    rejection: data['rejection'] == null ? null : data['rejection'] as String?,
  );
}

Future<Map<String, dynamic>> _$BrickHealthOperationModelToRest(
  BrickHealthOperationModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'author_id': instance.authorId,
    'created_at': instance.createdAt.toIso8601String(),
    'payload': instance.payload,
    'result_event_id': instance.resultEventId,
    'rejection': instance.rejection,
  };
}

Future<BrickHealthOperationModel> _$BrickHealthOperationModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickHealthOperationModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    authorId: data['author_id'] as String,
    createdAt: DateTime.parse(data['created_at'] as String),
    payload: data['payload'] as String,
    resultEventId: data['result_event_id'] == null
        ? null
        : data['result_event_id'] as String?,
    rejection: data['rejection'] == null ? null : data['rejection'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickHealthOperationModelToSqlite(
  BrickHealthOperationModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'author_id': instance.authorId,
    'created_at': instance.createdAt.toIso8601String(),
    'payload': instance.payload,
    'result_event_id': instance.resultEventId,
    'rejection': instance.rejection,
  };
}

/// Construct a [BrickHealthOperationModel]
class BrickHealthOperationModelAdapter
    extends OfflineFirstWithRestAdapter<BrickHealthOperationModel> {
  BrickHealthOperationModelAdapter();

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
    'authorId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'author_id',
      iterable: false,
      type: String,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: DateTime,
    ),
    'payload': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'payload',
      iterable: false,
      type: String,
    ),
    'resultEventId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'result_event_id',
      iterable: false,
      type: String,
    ),
    'rejection': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rejection',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BrickHealthOperationModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `BrickHealthOperationModel` WHERE local_id = ? LIMIT 1''',
      [instance.localId],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'BrickHealthOperationModel';

  @override
  Future<BrickHealthOperationModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthOperationModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickHealthOperationModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthOperationModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickHealthOperationModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthOperationModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickHealthOperationModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthOperationModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

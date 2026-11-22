// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickHealthEventModel> _$BrickHealthEventModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickHealthEventModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    animalId: data['animal_id'] as String,
    payload: data['payload'] as String,
  );
}

Future<Map<String, dynamic>> _$BrickHealthEventModelToRest(
  BrickHealthEventModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'animal_id': instance.animalId,
    'payload': instance.payload,
  };
}

Future<BrickHealthEventModel> _$BrickHealthEventModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickHealthEventModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    animalId: data['animal_id'] as String,
    payload: data['payload'] as String,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickHealthEventModelToSqlite(
  BrickHealthEventModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'animal_id': instance.animalId,
    'payload': instance.payload,
  };
}

/// Construct a [BrickHealthEventModel]
class BrickHealthEventModelAdapter
    extends OfflineFirstWithRestAdapter<BrickHealthEventModel> {
  BrickHealthEventModelAdapter();

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
    'animalId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'animal_id',
      iterable: false,
      type: String,
    ),
    'payload': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'payload',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BrickHealthEventModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `BrickHealthEventModel` WHERE local_id = ? LIMIT 1''',
      [instance.localId],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'BrickHealthEventModel';

  @override
  Future<BrickHealthEventModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthEventModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickHealthEventModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthEventModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickHealthEventModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthEventModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickHealthEventModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickHealthEventModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

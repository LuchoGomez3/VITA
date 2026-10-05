// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickAnimalObservationModel> _$BrickAnimalObservationModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickAnimalObservationModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    animalId: data['animal_id'] as String,
    text: data['texto'] as String,
    date: DateTime.parse(data['fecha'] as String),
    authorId: data['autor_id'] == null ? null : data['autor_id'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickAnimalObservationModelToRest(
  BrickAnimalObservationModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'animal_id': instance.animalId,
    'texto': instance.text,
    'fecha': instance.date.toIso8601String(),
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickAnimalObservationModel> _$BrickAnimalObservationModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickAnimalObservationModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    animalId: data['animal_id'] as String,
    text: data['text'] as String,
    date: DateTime.parse(data['date'] as String),
    authorId: data['author_id'] == null ? null : data['author_id'] as String?,
    syncStatus: BrickAnimalSyncStatus.values[data['sync_status'] as int],
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

Future<Map<String, dynamic>> _$BrickAnimalObservationModelToSqlite(
  BrickAnimalObservationModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'animal_id': instance.animalId,
    'text': instance.text,
    'date': instance.date.toIso8601String(),
    'author_id': instance.authorId,
    'sync_status': BrickAnimalSyncStatus.values.indexOf(instance.syncStatus),
    'sync_error_code': instance.syncErrorCode,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

/// Construct a [BrickAnimalObservationModel]
class BrickAnimalObservationModelAdapter
    extends OfflineFirstWithRestAdapter<BrickAnimalObservationModel> {
  BrickAnimalObservationModelAdapter();

  @override
  final restRequest = BrickAnimalObservationRequestTransformer.new;
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
    'text': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'text',
      iterable: false,
      type: String,
    ),
    'date': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'date',
      iterable: false,
      type: DateTime,
    ),
    'authorId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'author_id',
      iterable: false,
      type: String,
    ),
    'syncStatus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sync_status',
      iterable: false,
      type: BrickAnimalSyncStatus,
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
    BrickAnimalObservationModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickAnimalObservationModel';

  @override
  Future<BrickAnimalObservationModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalObservationModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickAnimalObservationModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalObservationModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickAnimalObservationModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalObservationModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickAnimalObservationModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalObservationModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickPesajeModel> _$BrickPesajeModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickPesajeModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    animalId: data['animal_id'] as String,
    weightKg: brickPesoFromBackend(data['peso_kg']),
    date: brickPesajeDateTimeFromBackend(data['fecha']),
    method: brickPesajeMethodFromBackend(data['metodo'] as String?),
    isEstimated: data['es_estimado'] as bool,
    bodyCondition: data['condicion_corporal'] == null
        ? null
        : brickNullablePesoFromBackend(data['condicion_corporal']),
    photoUrl: data['foto_url'] == null ? null : data['foto_url'] as String?,
    responsibleId: data['responsable_id'] == null
        ? null
        : data['responsable_id'] as String?,
    observations: data['observaciones'] == null
        ? null
        : data['observaciones'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickPesajeModelToRest(
  BrickPesajeModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'animal_id': instance.animalId,
    'peso_kg': instance.weightKg,
    'fecha': instance.date.toIso8601String(),
    'metodo': brickPesajeMethodToBackend(instance.method),
    'es_estimado': instance.isEstimated,
    'condicion_corporal': instance.bodyCondition,
    'foto_url': instance.photoUrl,
    'responsable_id': instance.responsibleId,
    'observaciones': instance.observations,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickPesajeModel> _$BrickPesajeModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickPesajeModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    animalId: data['animal_id'] as String,
    weightKg: data['weight_kg'] as double,
    date: DateTime.parse(data['date'] as String),
    method: BrickPesajeMethod.values[data['method'] as int],
    isEstimated: data['is_estimated'] == 1,
    bodyCondition: data['body_condition'] == null
        ? null
        : data['body_condition'] as double?,
    photoUrl: data['photo_url'] == null ? null : data['photo_url'] as String?,
    responsibleId: data['responsible_id'] == null
        ? null
        : data['responsible_id'] as String?,
    observations: data['observations'] == null
        ? null
        : data['observations'] as String?,
    syncStatus: BrickPesajeSyncStatus.values[data['sync_status'] as int],
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

Future<Map<String, dynamic>> _$BrickPesajeModelToSqlite(
  BrickPesajeModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'animal_id': instance.animalId,
    'weight_kg': instance.weightKg,
    'date': instance.date.toIso8601String(),
    'method': BrickPesajeMethod.values.indexOf(instance.method),
    'is_estimated': instance.isEstimated ? 1 : 0,
    'body_condition': instance.bodyCondition,
    'photo_url': instance.photoUrl,
    'responsible_id': instance.responsibleId,
    'observations': instance.observations,
    'sync_status': BrickPesajeSyncStatus.values.indexOf(instance.syncStatus),
    'sync_error_code': instance.syncErrorCode,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

/// Construct a [BrickPesajeModel]
class BrickPesajeModelAdapter
    extends OfflineFirstWithRestAdapter<BrickPesajeModel> {
  BrickPesajeModelAdapter();

  @override
  final restRequest = BrickPesajeRequestTransformer.new;
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
    'weightKg': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'weight_kg',
      iterable: false,
      type: double,
    ),
    'date': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'date',
      iterable: false,
      type: DateTime,
    ),
    'method': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'method',
      iterable: false,
      type: BrickPesajeMethod,
    ),
    'isEstimated': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_estimated',
      iterable: false,
      type: bool,
    ),
    'bodyCondition': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'body_condition',
      iterable: false,
      type: double,
    ),
    'photoUrl': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'photo_url',
      iterable: false,
      type: String,
    ),
    'responsibleId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'responsible_id',
      iterable: false,
      type: String,
    ),
    'observations': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'observations',
      iterable: false,
      type: String,
    ),
    'syncStatus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sync_status',
      iterable: false,
      type: BrickPesajeSyncStatus,
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
    BrickPesajeModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickPesajeModel';

  @override
  Future<BrickPesajeModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickPesajeModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickPesajeModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickPesajeModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickPesajeModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickPesajeModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickPesajeModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickPesajeModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

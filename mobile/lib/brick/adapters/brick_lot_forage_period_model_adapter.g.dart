// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickLotForagePeriodModel> _$BrickLotForagePeriodModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickLotForagePeriodModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    lotId: data['lote_id'] as String,
    forageResourceCode: data['recurso_forrajero_codigo'] as String,
    description: data['descripcion'] == null
        ? null
        : data['descripcion'] as String?,
    startDate: data['fecha_desde'] as String,
    endDate: data['fecha_hasta'] == null
        ? null
        : data['fecha_hasta'] as String?,
    registeredById: data['registrado_por_id'] == null
        ? null
        : data['registrado_por_id'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickLotForagePeriodModelToRest(
  BrickLotForagePeriodModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'lote_id': instance.lotId,
    'recurso_forrajero_codigo': instance.forageResourceCode,
    'descripcion': instance.description,
    'fecha_desde': instance.startDate,
    'fecha_hasta': instance.endDate,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickLotForagePeriodModel> _$BrickLotForagePeriodModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickLotForagePeriodModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    lotId: data['lot_id'] as String,
    forageResourceCode: data['forage_resource_code'] as String,
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    startDate: data['start_date'] as String,
    endDate: data['end_date'] == null ? null : data['end_date'] as String?,
    registeredById: data['registered_by_id'] == null
        ? null
        : data['registered_by_id'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
    syncStatus: brickForagePeriodSyncStatusFromSqlite(data['sync_status']),
    syncErrorCode: data['sync_error_code'] == null
        ? null
        : data['sync_error_code'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickLotForagePeriodModelToSqlite(
  BrickLotForagePeriodModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'lot_id': instance.lotId,
    'forage_resource_code': instance.forageResourceCode,
    'description': instance.description,
    'start_date': instance.startDate,
    'end_date': instance.endDate,
    'registered_by_id': instance.registeredById,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
    'sync_status': BrickLotForagePeriodSyncStatus.values.indexOf(
      instance.syncStatus,
    ),
    'sync_error_code': instance.syncErrorCode,
  };
}

/// Construct a [BrickLotForagePeriodModel]
class BrickLotForagePeriodModelAdapter
    extends OfflineFirstWithRestAdapter<BrickLotForagePeriodModel> {
  BrickLotForagePeriodModelAdapter();

  @override
  final restRequest = BrickLotForagePeriodRequestTransformer.new;
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
    'lotId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'lot_id',
      iterable: false,
      type: String,
    ),
    'forageResourceCode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'forage_resource_code',
      iterable: false,
      type: String,
    ),
    'description': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description',
      iterable: false,
      type: String,
    ),
    'startDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'start_date',
      iterable: false,
      type: String,
    ),
    'endDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'end_date',
      iterable: false,
      type: String,
    ),
    'registeredById': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'registered_by_id',
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
      type: BrickLotForagePeriodSyncStatus,
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
    BrickLotForagePeriodModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickLotForagePeriodModel';

  @override
  Future<BrickLotForagePeriodModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLotForagePeriodModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickLotForagePeriodModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLotForagePeriodModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickLotForagePeriodModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLotForagePeriodModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickLotForagePeriodModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLotForagePeriodModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

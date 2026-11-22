// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickFeedingRecordModel> _$BrickFeedingRecordModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickFeedingRecordModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    type: data['tipo'] as String,
    foodId: data['alimento_id'] as String,
    lotId: data['lote_id'] == null ? null : data['lote_id'] as String?,
    startDate: data['fecha_desde'] as String,
    endDate: data['fecha_hasta'] == null
        ? null
        : data['fecha_hasta'] as String?,
    quantity: brickFeedingQuantityFromBackend(data['cantidad']),
    unit: data['unidad'] as String,
    quantityBasis: data['base_cantidad'] as String,
    reason: data['motivo'] == null ? null : data['motivo'] as String?,
    animalIdsJson: brickMovementAnimalIdsFromBackend(data['animal_ids']),
    responsibleId: data['responsable_id'] == null
        ? null
        : data['responsable_id'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickFeedingRecordModelToRest(
  BrickFeedingRecordModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'tipo': instance.type,
    'alimento_id': instance.foodId,
    'lote_id': instance.lotId,
    'fecha_desde': instance.startDate,
    'fecha_hasta': instance.endDate,
    'cantidad': instance.quantity,
    'unidad': instance.unit,
    'base_cantidad': instance.quantityBasis,
    'motivo': instance.reason,
    'animal_ids': brickMovementAnimalIdsToBackend(instance.animalIdsJson),
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickFeedingRecordModel> _$BrickFeedingRecordModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickFeedingRecordModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    type: data['type'] as String,
    foodId: data['food_id'] as String,
    lotId: data['lot_id'] == null ? null : data['lot_id'] as String?,
    startDate: data['start_date'] as String,
    endDate: data['end_date'] == null ? null : data['end_date'] as String?,
    quantity: data['quantity'] as String,
    unit: data['unit'] as String,
    quantityBasis: data['quantity_basis'] as String,
    reason: data['reason'] == null ? null : data['reason'] as String?,
    animalIdsJson: data['animal_ids_json'] as String,
    responsibleId: data['responsible_id'] == null
        ? null
        : data['responsible_id'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
    syncStatus: brickFeedingRecordSyncStatusFromSqlite(data['sync_status']),
    syncErrorCode: data['sync_error_code'] == null
        ? null
        : data['sync_error_code'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickFeedingRecordModelToSqlite(
  BrickFeedingRecordModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'type': instance.type,
    'food_id': instance.foodId,
    'lot_id': instance.lotId,
    'start_date': instance.startDate,
    'end_date': instance.endDate,
    'quantity': instance.quantity,
    'unit': instance.unit,
    'quantity_basis': instance.quantityBasis,
    'reason': instance.reason,
    'animal_ids_json': instance.animalIdsJson,
    'responsible_id': instance.responsibleId,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
    'sync_status': BrickFeedingRecordSyncStatus.values.indexOf(
      instance.syncStatus,
    ),
    'sync_error_code': instance.syncErrorCode,
  };
}

/// Construct a [BrickFeedingRecordModel]
class BrickFeedingRecordModelAdapter
    extends OfflineFirstWithRestAdapter<BrickFeedingRecordModel> {
  BrickFeedingRecordModelAdapter();

  @override
  final restRequest = BrickFeedingRecordRequestTransformer.new;
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
    'foodId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'food_id',
      iterable: false,
      type: String,
    ),
    'lotId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'lot_id',
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
    'quantity': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'quantity',
      iterable: false,
      type: String,
    ),
    'unit': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'unit',
      iterable: false,
      type: String,
    ),
    'quantityBasis': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'quantity_basis',
      iterable: false,
      type: String,
    ),
    'reason': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'reason',
      iterable: false,
      type: String,
    ),
    'animalIdsJson': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'animal_ids_json',
      iterable: false,
      type: String,
    ),
    'responsibleId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'responsible_id',
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
      type: BrickFeedingRecordSyncStatus,
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
    BrickFeedingRecordModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickFeedingRecordModel';

  @override
  Future<BrickFeedingRecordModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickFeedingRecordModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickFeedingRecordModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickFeedingRecordModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickFeedingRecordModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickFeedingRecordModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickFeedingRecordModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickFeedingRecordModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

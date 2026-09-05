// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickAnimalLotMovementModel> _$BrickAnimalLotMovementModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickAnimalLotMovementModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    sourceLotId: data['lote_origen_id'] as String,
    destinationLotId: data['lote_destino_id'] as String,
    animalIdsJson: brickMovementAnimalIdsFromBackend(data['animal_ids']),
    occurredAt: DateTime.parse(data['fecha_movimiento'] as String),
    reason: data['motivo'] as String,
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

Future<Map<String, dynamic>> _$BrickAnimalLotMovementModelToRest(
  BrickAnimalLotMovementModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'lote_origen_id': instance.sourceLotId,
    'lote_destino_id': instance.destinationLotId,
    'animal_ids': brickMovementAnimalIdsToBackend(instance.animalIdsJson),
    'fecha_movimiento': instance.occurredAt.toIso8601String(),
    'motivo': instance.reason,
    'responsable_id': instance.responsibleId,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickAnimalLotMovementModel> _$BrickAnimalLotMovementModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickAnimalLotMovementModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    sourceLotId: data['source_lot_id'] as String,
    destinationLotId: data['destination_lot_id'] as String,
    animalIdsJson: data['animal_ids_json'] as String,
    occurredAt: DateTime.parse(data['occurred_at'] as String),
    reason: data['reason'] as String,
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
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickAnimalLotMovementModelToSqlite(
  BrickAnimalLotMovementModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'source_lot_id': instance.sourceLotId,
    'destination_lot_id': instance.destinationLotId,
    'animal_ids_json': instance.animalIdsJson,
    'occurred_at': instance.occurredAt.toIso8601String(),
    'reason': instance.reason,
    'responsible_id': instance.responsibleId,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

/// Construct a [BrickAnimalLotMovementModel]
class BrickAnimalLotMovementModelAdapter
    extends OfflineFirstWithRestAdapter<BrickAnimalLotMovementModel> {
  BrickAnimalLotMovementModelAdapter();

  @override
  final restRequest = BrickAnimalLotMovementRequestTransformer.new;
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
    'sourceLotId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'source_lot_id',
      iterable: false,
      type: String,
    ),
    'destinationLotId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'destination_lot_id',
      iterable: false,
      type: String,
    ),
    'animalIdsJson': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'animal_ids_json',
      iterable: false,
      type: String,
    ),
    'occurredAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'occurred_at',
      iterable: false,
      type: DateTime,
    ),
    'reason': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'reason',
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
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BrickAnimalLotMovementModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickAnimalLotMovementModel';

  @override
  Future<BrickAnimalLotMovementModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalLotMovementModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickAnimalLotMovementModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalLotMovementModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickAnimalLotMovementModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalLotMovementModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickAnimalLotMovementModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalLotMovementModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

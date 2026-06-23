// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickAnimalModel> _$BrickAnimalModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickAnimalModel(
    localId: data['id'] as String,
    rfidTagNumber: data['nro_caravana_rfid'] as String,
    visualTag: data['caravana_visual'] as String,
    sex: brickAnimalSexFromBackend(data['sexo'] as String),
    breed: data['raza'] as String,
    birthDate: DateTime.parse(data['fecha_nacimiento'] as String),
    categoryId: data['categoria_id'] as String,
    lotId: data['lote_id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    initialWeight: data['peso_inicial'] as double,
    weighingMethod: brickAnimalWeighingMethodFromBackend(
      data['metodo_pesaje'] as String?,
    ),
    weighingDate: DateTime.parse(data['fecha_pesaje'] as String),
    motherId: data['madre_id'] == null ? null : data['madre_id'] as String?,
    fatherId: data['padre_id'] == null ? null : data['padre_id'] as String?,
    coat: data['pelaje'] == null ? null : data['pelaje'] as String?,
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

Future<Map<String, dynamic>> _$BrickAnimalModelToRest(
  BrickAnimalModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'nro_caravana_rfid': instance.rfidTagNumber,
    'caravana_visual': instance.visualTag,
    'sexo': brickAnimalSexToBackend(instance.sex),
    'raza': instance.breed,
    'fecha_nacimiento': brickDateToBackend(instance.birthDate),
    'categoria_id': instance.categoryId,
    'lote_id': instance.lotId,
    'establecimiento_id': instance.establishmentId,
    'peso_inicial': instance.initialWeight,
    'metodo_pesaje': brickAnimalWeighingMethodToBackend(
      instance.weighingMethod,
    ),
    'fecha_pesaje': instance.weighingDate.toIso8601String(),
    'madre_id': instance.motherId,
    'padre_id': instance.fatherId,
    'pelaje': instance.coat,
    'observaciones': instance.observations,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickAnimalModel> _$BrickAnimalModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickAnimalModel(
    localId: data['local_id'] as String,
    rfidTagNumber: data['rfid_tag_number'] as String,
    visualTag: data['visual_tag'] as String,
    sex: BrickAnimalSex.values[data['sex'] as int],
    breed: data['breed'] as String,
    birthDate: DateTime.parse(data['birth_date'] as String),
    categoryId: data['category_id'] as String,
    categoryName: data['category_name'] as String,
    lotId: data['lot_id'] as String,
    lotName: data['lot_name'] as String,
    establishmentId: data['establishment_id'] as String,
    initialWeight: data['initial_weight'] as double,
    weighingMethod:
        BrickAnimalWeighingMethod.values[data['weighing_method'] as int],
    weighingDate: DateTime.parse(data['weighing_date'] as String),
    motherId: data['mother_id'] == null ? null : data['mother_id'] as String?,
    fatherId: data['father_id'] == null ? null : data['father_id'] as String?,
    coat: data['coat'] == null ? null : data['coat'] as String?,
    observations: data['observations'] == null
        ? null
        : data['observations'] as String?,
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

Future<Map<String, dynamic>> _$BrickAnimalModelToSqlite(
  BrickAnimalModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'rfid_tag_number': instance.rfidTagNumber,
    'visual_tag': instance.visualTag,
    'sex': BrickAnimalSex.values.indexOf(instance.sex),
    'breed': instance.breed,
    'birth_date': instance.birthDate.toIso8601String(),
    'category_id': instance.categoryId,
    'category_name': instance.categoryName,
    'lot_id': instance.lotId,
    'lot_name': instance.lotName,
    'establishment_id': instance.establishmentId,
    'initial_weight': instance.initialWeight,
    'weighing_method': BrickAnimalWeighingMethod.values.indexOf(
      instance.weighingMethod,
    ),
    'weighing_date': instance.weighingDate.toIso8601String(),
    'mother_id': instance.motherId,
    'father_id': instance.fatherId,
    'coat': instance.coat,
    'observations': instance.observations,
    'sync_status': BrickAnimalSyncStatus.values.indexOf(instance.syncStatus),
    'sync_error_code': instance.syncErrorCode,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

/// Construct a [BrickAnimalModel]
class BrickAnimalModelAdapter
    extends OfflineFirstWithRestAdapter<BrickAnimalModel> {
  BrickAnimalModelAdapter();

  @override
  final restRequest = BrickAnimalRequestTransformer.new;
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
    'rfidTagNumber': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'rfid_tag_number',
      iterable: false,
      type: String,
    ),
    'visualTag': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'visual_tag',
      iterable: false,
      type: String,
    ),
    'sex': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sex',
      iterable: false,
      type: BrickAnimalSex,
    ),
    'breed': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'breed',
      iterable: false,
      type: String,
    ),
    'birthDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'birth_date',
      iterable: false,
      type: DateTime,
    ),
    'categoryId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'category_id',
      iterable: false,
      type: String,
    ),
    'categoryName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'category_name',
      iterable: false,
      type: String,
    ),
    'lotId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'lot_id',
      iterable: false,
      type: String,
    ),
    'lotName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'lot_name',
      iterable: false,
      type: String,
    ),
    'establishmentId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'establishment_id',
      iterable: false,
      type: String,
    ),
    'initialWeight': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'initial_weight',
      iterable: false,
      type: double,
    ),
    'weighingMethod': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'weighing_method',
      iterable: false,
      type: BrickAnimalWeighingMethod,
    ),
    'weighingDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'weighing_date',
      iterable: false,
      type: DateTime,
    ),
    'motherId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'mother_id',
      iterable: false,
      type: String,
    ),
    'fatherId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'father_id',
      iterable: false,
      type: String,
    ),
    'coat': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'coat',
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
    BrickAnimalModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickAnimalModel';

  @override
  Future<BrickAnimalModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickAnimalModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickAnimalModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickAnimalModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickAnimalModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

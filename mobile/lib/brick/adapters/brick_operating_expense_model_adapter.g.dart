// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickOperatingExpenseModel> _$BrickOperatingExpenseModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickOperatingExpenseModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    amount: data['monto'] as String,
    type: data['tipo'] as String,
    category: data['categoria'] as String,
    supply: data['insumo'] as String,
    date: DateTime.parse(data['fecha'] as String),
    description: data['descripcion'] == null
        ? null
        : data['descripcion'] as String?,
    receiptNumber: data['numero_comprobante'] == null
        ? null
        : data['numero_comprobante'] as String?,
    loadedById: data['cargado_por_id'] == null
        ? null
        : data['cargado_por_id'] as String?,
    loadedByName: data['cargado_por'] == null
        ? null
        : brickOperatingExpenseLoadedByName(data['cargado_por']),
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickOperatingExpenseModelToRest(
  BrickOperatingExpenseModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'monto': instance.amount,
    'tipo': instance.type,
    'categoria': instance.category,
    'insumo': instance.supply,
    'fecha': brickOperatingExpenseDateToBackend(instance.date),
    'descripcion': instance.description,
    'numero_comprobante': instance.receiptNumber,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickOperatingExpenseModel> _$BrickOperatingExpenseModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickOperatingExpenseModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    amount: data['amount'] as String,
    type: data['type'] as String,
    category: data['category'] as String,
    supply: data['supply'] as String,
    date: DateTime.parse(data['date'] as String),
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    receiptNumber: data['receipt_number'] == null
        ? null
        : data['receipt_number'] as String?,
    loadedById: data['loaded_by_id'] == null
        ? null
        : data['loaded_by_id'] as String?,
    loadedByName: data['loaded_by_name'] == null
        ? null
        : data['loaded_by_name'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
    customCategoryId: data['custom_category_id'] == null
        ? null
        : data['custom_category_id'] as String?,
    syncStatus:
        BrickOperatingExpenseSyncStatus.values[data['sync_status'] as int],
    syncErrorCode: data['sync_error_code'] == null
        ? null
        : data['sync_error_code'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickOperatingExpenseModelToSqlite(
  BrickOperatingExpenseModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'amount': instance.amount,
    'type': instance.type,
    'category': instance.category,
    'supply': instance.supply,
    'date': instance.date.toIso8601String(),
    'description': instance.description,
    'receipt_number': instance.receiptNumber,
    'loaded_by_id': instance.loadedById,
    'loaded_by_name': instance.loadedByName,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
    'custom_category_id': instance.customCategoryId,
    'sync_status': BrickOperatingExpenseSyncStatus.values.indexOf(
      instance.syncStatus,
    ),
    'sync_error_code': instance.syncErrorCode,
  };
}

/// Construct a [BrickOperatingExpenseModel]
class BrickOperatingExpenseModelAdapter
    extends OfflineFirstWithRestAdapter<BrickOperatingExpenseModel> {
  BrickOperatingExpenseModelAdapter();

  @override
  final restRequest = BrickOperatingExpenseRequestTransformer.new;
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
    'amount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'amount',
      iterable: false,
      type: String,
    ),
    'type': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'type',
      iterable: false,
      type: String,
    ),
    'category': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'category',
      iterable: false,
      type: String,
    ),
    'supply': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'supply',
      iterable: false,
      type: String,
    ),
    'date': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'date',
      iterable: false,
      type: DateTime,
    ),
    'description': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description',
      iterable: false,
      type: String,
    ),
    'receiptNumber': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'receipt_number',
      iterable: false,
      type: String,
    ),
    'loadedById': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'loaded_by_id',
      iterable: false,
      type: String,
    ),
    'loadedByName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'loaded_by_name',
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
    'customCategoryId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'custom_category_id',
      iterable: false,
      type: String,
    ),
    'syncStatus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sync_status',
      iterable: false,
      type: BrickOperatingExpenseSyncStatus,
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
    BrickOperatingExpenseModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickOperatingExpenseModel';

  @override
  Future<BrickOperatingExpenseModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickOperatingExpenseModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickOperatingExpenseModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickOperatingExpenseModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickOperatingExpenseModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickOperatingExpenseModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickOperatingExpenseModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickOperatingExpenseModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

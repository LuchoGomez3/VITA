// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BrickLivestockSaleModel> _$BrickLivestockSaleModelFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickLivestockSaleModel(
    localId: data['id'] as String,
    establishmentId: data['establecimiento_id'] as String,
    operationDate: DateTime.parse(data['fecha_operacion'] as String),
    buyerType: data['tipo_comprador'] as String,
    buyerName: data['nombre_comprador'] as String,
    isCompany: data['es_empresa'] as bool,
    buyerLastName: data['apellido_comprador'] == null
        ? null
        : data['apellido_comprador'] as String?,
    dteNumber: data['nro_dte'] as String,
    saleType: data['tipo_venta'] as String,
    totalWeightKg: data['peso_total_kg'] == null
        ? null
        : data['peso_total_kg'] as String?,
    pricePerKg: data['precio_por_kg'] == null
        ? null
        : data['precio_por_kg'] as String?,
    totalAmount: data['monto_total'] as String,
    observations: data['observaciones'] == null
        ? null
        : data['observaciones'] as String?,
    animalIdsJson: brickLivestockSaleJsonFromBackend(data['animal_ids']),
    paymentCondition: data['condicion_cobro'] as String,
    initialPaymentJson: data['cobro_inicial'] == null
        ? null
        : brickLivestockSaleNullableJsonFromBackend(data['cobro_inicial']),
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
  );
}

Future<Map<String, dynamic>> _$BrickLivestockSaleModelToRest(
  BrickLivestockSaleModel instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'id': instance.localId,
    'establecimiento_id': instance.establishmentId,
    'fecha_operacion': brickLivestockSaleDateToBackend(instance.operationDate),
    'tipo_comprador': instance.buyerType,
    'nombre_comprador': instance.buyerName,
    'es_empresa': instance.isCompany,
    'apellido_comprador': instance.buyerLastName,
    'nro_dte': instance.dteNumber,
    'tipo_venta': instance.saleType,
    'peso_total_kg': instance.totalWeightKg,
    'precio_por_kg': instance.pricePerKg,
    'monto_total': instance.totalAmount,
    'observaciones': instance.observations,
    'animal_ids': brickLivestockSaleJsonToBackend(instance.animalIdsJson),
    'condicion_cobro': instance.paymentCondition,
    'cobro_inicial': brickLivestockSaleNullableJsonToBackend(
      instance.initialPaymentJson,
    ),
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
  };
}

Future<BrickLivestockSaleModel> _$BrickLivestockSaleModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return BrickLivestockSaleModel(
    localId: data['local_id'] as String,
    establishmentId: data['establishment_id'] as String,
    operationDate: DateTime.parse(data['operation_date'] as String),
    buyerType: data['buyer_type'] as String,
    buyerName: data['buyer_name'] as String,
    isCompany: data['is_company'] == 1,
    buyerLastName: data['buyer_last_name'] == null
        ? null
        : data['buyer_last_name'] as String?,
    dteNumber: data['dte_number'] as String,
    saleType: data['sale_type'] as String,
    totalWeightKg: data['total_weight_kg'] == null
        ? null
        : data['total_weight_kg'] as String?,
    pricePerKg: data['price_per_kg'] == null
        ? null
        : data['price_per_kg'] as String?,
    totalAmount: data['total_amount'] as String,
    observations: data['observations'] == null
        ? null
        : data['observations'] as String?,
    animalIdsJson: data['animal_ids_json'] as String,
    paymentCondition: data['payment_condition'] as String,
    initialPaymentJson: data['initial_payment_json'] == null
        ? null
        : data['initial_payment_json'] as String?,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: DateTime.parse(data['updated_at'] as String),
    deletedAt: data['deleted_at'] == null
        ? null
        : data['deleted_at'] == null
        ? null
        : DateTime.tryParse(data['deleted_at'] as String),
    syncStatus: BrickLivestockSaleSyncStatus.values[data['sync_status'] as int],
    syncErrorCode: data['sync_error_code'] == null
        ? null
        : data['sync_error_code'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BrickLivestockSaleModelToSqlite(
  BrickLivestockSaleModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'local_id': instance.localId,
    'establishment_id': instance.establishmentId,
    'operation_date': instance.operationDate.toIso8601String(),
    'buyer_type': instance.buyerType,
    'buyer_name': instance.buyerName,
    'is_company': instance.isCompany ? 1 : 0,
    'buyer_last_name': instance.buyerLastName,
    'dte_number': instance.dteNumber,
    'sale_type': instance.saleType,
    'total_weight_kg': instance.totalWeightKg,
    'price_per_kg': instance.pricePerKg,
    'total_amount': instance.totalAmount,
    'observations': instance.observations,
    'animal_ids_json': instance.animalIdsJson,
    'payment_condition': instance.paymentCondition,
    'initial_payment_json': instance.initialPaymentJson,
    'created_at': instance.createdAt.toIso8601String(),
    'updated_at': instance.updatedAt.toIso8601String(),
    'deleted_at': instance.deletedAt?.toIso8601String(),
    'sync_status': BrickLivestockSaleSyncStatus.values.indexOf(
      instance.syncStatus,
    ),
    'sync_error_code': instance.syncErrorCode,
  };
}

/// Construct a [BrickLivestockSaleModel]
class BrickLivestockSaleModelAdapter
    extends OfflineFirstWithRestAdapter<BrickLivestockSaleModel> {
  BrickLivestockSaleModelAdapter();

  @override
  final restRequest = BrickLivestockSaleRequestTransformer.new;
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
    'operationDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'operation_date',
      iterable: false,
      type: DateTime,
    ),
    'buyerType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'buyer_type',
      iterable: false,
      type: String,
    ),
    'buyerName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'buyer_name',
      iterable: false,
      type: String,
    ),
    'isCompany': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_company',
      iterable: false,
      type: bool,
    ),
    'buyerLastName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'buyer_last_name',
      iterable: false,
      type: String,
    ),
    'dteNumber': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'dte_number',
      iterable: false,
      type: String,
    ),
    'saleType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sale_type',
      iterable: false,
      type: String,
    ),
    'totalWeightKg': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'total_weight_kg',
      iterable: false,
      type: String,
    ),
    'pricePerKg': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'price_per_kg',
      iterable: false,
      type: String,
    ),
    'totalAmount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'total_amount',
      iterable: false,
      type: String,
    ),
    'observations': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'observations',
      iterable: false,
      type: String,
    ),
    'animalIdsJson': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'animal_ids_json',
      iterable: false,
      type: String,
    ),
    'paymentCondition': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'payment_condition',
      iterable: false,
      type: String,
    ),
    'initialPaymentJson': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'initial_payment_json',
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
      type: BrickLivestockSaleSyncStatus,
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
    BrickLivestockSaleModel instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BrickLivestockSaleModel';

  @override
  Future<BrickLivestockSaleModel> fromRest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLivestockSaleModelFromRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toRest(
    BrickLivestockSaleModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLivestockSaleModelToRest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BrickLivestockSaleModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLivestockSaleModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BrickLivestockSaleModel input, {
    required provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async => await _$BrickLivestockSaleModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

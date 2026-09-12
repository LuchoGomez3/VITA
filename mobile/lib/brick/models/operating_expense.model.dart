import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

/// Estado visual de sincronizacion de un egreso.
enum BrickOperatingExpenseSyncStatus { pending, synchronized, rejected }

/// Configura altas y pull incremental de egresos operativos.
class BrickOperatingExpenseRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer requerido por Brick.
  const BrickOperatingExpenseRequestTransformer(super.query, super.instance);

  /// Endpoint principal del recurso.
  static const expensesPath = '/api/v1/egresos_operativos';

  /// Arma el pull filtrado por establecimiento e incluye tombstones.
  static RestRequest listByEstablishmentRequest(String establishmentId) => RestRequest(
    url: '$expensesPath?establecimiento_id=${Uri.encodeQueryComponent(establishmentId)}&include_deleted=true',
    topLevelKey: 'data',
  );

  @override
  RestRequest get get => const RestRequest(url: expensesPath, topLevelKey: 'data');

  @override
  RestRequest get upsert => const RestRequest(
    method: 'POST',
    url: expensesPath,
  );
}

/// Egreso operativo persistido primero en SQLite y sincronizado por Brick.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickOperatingExpenseRequestTransformer.new,
  ),
)
class BrickOperatingExpenseModel extends OfflineFirstWithRestModel {
  /// Crea un egreso tecnico de persistencia.
  BrickOperatingExpenseModel({
    required this.localId,
    required this.establishmentId,
    required this.amount,
    required this.type,
    required this.category,
    required this.supply,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.receiptNumber,
    this.loadedById,
    this.loadedByName,
    this.deletedAt,
    this.customCategoryId,
    this.syncStatus = BrickOperatingExpenseSyncStatus.pending,
    this.syncErrorCode,
  });

  @Rest(name: 'id')
  final String localId;
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Decimal canonico; se conserva como texto para no perder centavos.
  @Rest(name: 'monto')
  final String amount;
  @Rest(name: 'tipo')
  final String type;
  @Rest(name: 'categoria')
  final String category;
  @Rest(name: 'insumo')
  final String supply;
  @Rest(
    name: 'fecha',
    toGenerator: 'brickOperatingExpenseDateToBackend(%INSTANCE_PROPERTY%)',
  )
  final DateTime date;
  @Rest(name: 'descripcion')
  final String? description;
  @Rest(name: 'numero_comprobante')
  final String? receiptNumber;
  @Rest(name: 'cargado_por_id', ignoreTo: true)
  final String? loadedById;

  /// Nombre de auditoria aplanado para el historial offline.
  @Rest(
    name: 'cargado_por',
    ignoreTo: true,
    fromGenerator: 'brickOperatingExpenseLoadedByName(%DATA_PROPERTY%)',
  )
  final String? loadedByName;
  @Rest(name: 'created_at')
  final DateTime createdAt;
  @Rest(name: 'updated_at')
  final DateTime updatedAt;
  @Rest(name: 'deleted_at')
  final DateTime? deletedAt;

  /// UUID local de la categoria que debe sincronizarse antes del egreso.
  @Rest(ignore: true)
  final String? customCategoryId;
  @Rest(ignore: true)
  final BrickOperatingExpenseSyncStatus syncStatus;
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Crea una copia reconciliada sin crear otra fila SQLite.
  BrickOperatingExpenseModel copyWith({
    BrickOperatingExpenseSyncStatus? syncStatus,
    String? syncErrorCode,
  }) => BrickOperatingExpenseModel(
    localId: localId,
    establishmentId: establishmentId,
    amount: amount,
    type: type,
    category: category,
    supply: supply,
    date: date,
    description: description,
    receiptNumber: receiptNumber,
    loadedById: loadedById,
    loadedByName: loadedByName,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    customCategoryId: customCategoryId,
    syncStatus: syncStatus ?? this.syncStatus,
    syncErrorCode: syncErrorCode,
  )..primaryKey = primaryKey;
}

/// Extrae el nombre completo del objeto de auditoria devuelto por backend.
String? brickOperatingExpenseLoadedByName(Object? data) {
  if (data is! Map<String, dynamic>) return null;
  final firstName = data['nombre'] as String? ?? '';
  final lastName = data['apellido'] as String? ?? '';
  final fullName = '$firstName $lastName'.trim();
  return fullName.isEmpty ? data['email'] as String? : fullName;
}

/// Serializa la fecha contable sin hora ni zona, como exige el backend.
String brickOperatingExpenseDateToBackend(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

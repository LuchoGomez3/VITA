import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

/// Estado local de sincronizacion compartido por las categorias de egresos.
enum BrickOperatingExpenseCategorySyncStatus { pending, synchronized, rejected }

/// Configura el endpoint REST de categorias personalizadas de egresos.
class BrickOperatingExpenseCategoryRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer requerido por Brick.
  const BrickOperatingExpenseCategoryRequestTransformer(super.query, super.instance);

  /// Endpoint de categorias personalizadas.
  static const categoriesPath = '/api/v1/egresos_operativos/categorias';

  @override
  RestRequest get get => const RestRequest(url: categoriesPath, topLevelKey: 'data');

  @override
  RestRequest get upsert => const RestRequest(
    method: 'POST',
    url: categoriesPath,
  );
}

/// Categoria personalizada disponible offline para un establecimiento y tipo.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickOperatingExpenseCategoryRequestTransformer.new,
  ),
)
class BrickOperatingExpenseCategoryModel extends OfflineFirstWithRestModel {
  /// Crea una categoria persistible y sincronizable.
  BrickOperatingExpenseCategoryModel({
    required this.localId,
    required this.establishmentId,
    required this.type,
    required this.name,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = BrickOperatingExpenseCategorySyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado en el dispositivo.
  @Rest(name: 'id')
  final String localId;

  /// Establecimiento propietario de la categoria.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Tipo de egreso al que pertenece.
  @Rest(name: 'tipo')
  final String type;

  /// Nombre visible elegido por el usuario.
  @Rest(name: 'nombre')
  final String name;

  /// Valor estable normalizado usado por los egresos.
  ///
  /// El backend lo completa en la respuesta. Offline se usa la misma
  /// normalizacion determinista para poder seleccionar la categoria enseguida.
  @Rest(name: 'valor', ignoreTo: true)
  final String value;

  /// Momento de creacion generado localmente.
  @Rest(name: 'created_at')
  final DateTime createdAt;

  /// Version usada para resolver conflictos last-write-wins.
  @Rest(name: 'updated_at')
  final DateTime updatedAt;

  /// Marca de borrado logico.
  @Rest(name: 'deleted_at')
  final DateTime? deletedAt;

  /// Estado exclusivo de SQLite, nunca enviado al backend.
  @Rest(ignore: true)
  final BrickOperatingExpenseCategorySyncStatus syncStatus;

  /// Codigo funcional del ultimo rechazo permanente.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Crea una copia reconciliada conservando la clave SQLite.
  BrickOperatingExpenseCategoryModel copyWith({
    String? value,
    BrickOperatingExpenseCategorySyncStatus? syncStatus,
    String? syncErrorCode,
  }) => BrickOperatingExpenseCategoryModel(
    localId: localId,
    establishmentId: establishmentId,
    type: type,
    name: name,
    value: value ?? this.value,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncErrorCode: syncErrorCode,
  )..primaryKey = primaryKey;
}

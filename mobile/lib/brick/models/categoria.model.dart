import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

const _unchangedSyncErrorCode = Object();

/// Estado local de sincronizacion de la categoria.
///
/// No viaja al backend. Sirve para que mobile sepa si una categoria propia
/// creada offline esta pendiente, confirmada o rechazada tras el intento de sync.
/// El catalogo global (`establishmentId` null) llega ya `synchronized` desde el
/// pull remoto.
enum BrickCategoriaSyncStatus {
  /// Guardada localmente y pendiente de sincronizar.
  pending,

  /// Confirmada por el backend (o bajada del catalogo global).
  synchronized,

  /// Rechazada por el backend y pendiente de correccion/revision.
  rejected,
}

/// Define las rutas REST que Brick usa para sincronizar categorias.
///
/// El alta de una categoria propia se envia a `POST /api/v1/categorias`; el
/// listado devuelve el catalogo global (`establecimiento_id` null) mas las
/// categorias del establecimiento, envuelto en `StandardResponse.data`.
class BrickCategoriaRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer de requests para categorias.
  const BrickCategoriaRequestTransformer(super.query, super.instance);

  /// Ruta base del recurso de categorias en el backend.
  ///
  /// Se centraliza aca para que stores, adapters generados y flujos de sync
  /// usen el mismo contrato HTTP. Si el endpoint cambia, se ajusta una sola vez.
  static const String categoriesPath = '/api/v1/categorias';

  /// Request usado por Brick para listar categorias desde backend.
  ///
  /// `topLevelKey` indica que la lista real esta dentro de `data`.
  static const RestRequest listRequest = RestRequest(
    url: categoriesPath,
    topLevelKey: 'data',
  );

  /// Request usado por Brick para enviar altas/updates de categorias.
  static const RestRequest upsertRequest = RestRequest(
    method: 'POST',
    url: categoriesPath,
  );

  /// Crea el request de listado (catalogo global + propias) del establecimiento.
  ///
  /// El `establishmentId` se codifica como query param para que un caracter
  /// especial no rompa la URL final.
  static RestRequest listByEstablishmentRequest(String establishmentId) {
    final encodedEstablishmentId = Uri.encodeQueryComponent(establishmentId);

    return RestRequest(
      url: '$categoriesPath?establecimiento_id=$encodedEstablishmentId',
      topLevelKey: 'data',
    );
  }

  /// Indica si un resultado de sync corresponde al recurso de categorias.
  ///
  /// Se valida por sufijo contra la ruta centralizada porque algunos clientes
  /// reportan el path completo con base URL incluida.
  static bool matchesCategoriaResource(String resourcePath) {
    return resourcePath.endsWith(categoriesPath);
  }

  /// Request usado por Brick para hidratar categorias desde backend.
  @override
  RestRequest get get => listRequest;

  /// Request usado por Brick para enviar altas/updates al backend.
  @override
  RestRequest get upsert => upsertRequest;
}

/// Modelo Brick offline-first para categorias productivas.
///
/// Es sobre todo un catalogo de lectura: el flujo pesado es el pull (bajar
/// global + propias y cachearlas para poblar el selector del alta de animal).
/// Tambien admite crear categorias propias offline, que se encolan como POST.
///
/// Reglas de responsabilidad:
/// - Campos con `@Rest(name: ...)` forman parte del contrato con backend.
/// - Campos con `@Rest(ignore: true)` se guardan solo localmente para UX/sync.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickCategoriaRequestTransformer.new,
  ),
)
class BrickCategoriaModel extends OfflineFirstWithRestModel {
  /// Crea una categoria persistible y sincronizable por Brick.
  BrickCategoriaModel({
    required this.localId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.establishmentId,
    this.description,
    this.deletedAt,
    this.syncStatus = BrickCategoriaSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado por mobile. Viaja al backend como `id`.
  @Rest(name: 'id')
  final String localId;

  /// ID backend del establecimiento duenio de la categoria.
  ///
  /// `null` = categoria del catalogo global (compartida, no editable por el
  /// usuario). Con valor = categoria propia del establecimiento.
  @Rest(name: 'establecimiento_id')
  final String? establishmentId;

  /// Nombre visible de la categoria (Ternero, Vaquillona, Novillo, ...).
  @Rest(name: 'nombre')
  final String name;

  /// Descripcion opcional de la categoria.
  @Rest(name: 'descripcion')
  final String? description;

  /// Estado local de sincronizacion. No se envia al backend.
  @Rest(ignore: true)
  final BrickCategoriaSyncStatus syncStatus;

  /// Codigo de error local del ultimo rechazo de sync. No se envia al backend.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Timestamp de creacion generado por mobile para offline-first.
  final DateTime createdAt;

  /// Timestamp de ultima modificacion de negocio.
  final DateTime updatedAt;

  /// Timestamp de borrado logico para sync de deletes.
  final DateTime? deletedAt;

  /// Crea una copia cambiando solo campos locales de sync.
  ///
  /// Se usa cuando llega la respuesta del backend y hay que actualizar el estado
  /// local (`pending` -> `synchronized` / `rejected`) sin reencolar el request.
  BrickCategoriaModel copyWith({
    BrickCategoriaSyncStatus? syncStatus,
    Object? syncErrorCode = _unchangedSyncErrorCode,
    DateTime? updatedAt,
  }) {
    final nextSyncErrorCode = identical(syncErrorCode, _unchangedSyncErrorCode)
        ? this.syncErrorCode
        : syncErrorCode as String?;

    return BrickCategoriaModel(
      localId: localId,
      establishmentId: establishmentId,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncErrorCode: nextSyncErrorCode,
    )..primaryKey = primaryKey;
  }
}

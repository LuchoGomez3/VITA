import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

/// Define las rutas REST que Brick usa para sincronizar categorias.
///
/// El listado devuelve el catalogo global dentro de `StandardResponse.data`.
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
    url: '$categoriesPath?include_deleted=true',
    topLevelKey: 'data',
  );

  /// Request usado por Brick para hidratar categorias desde backend.
  @override
  RestRequest get get => listRequest;
}

/// Modelo Brick offline-first para categorias productivas.
///
/// Es un catalogo global de solo lectura administrado por backend. Mobile lo
/// descarga y cachea para resolver nombres y poblar selectores sin conexion.
///
/// Reglas de responsabilidad:
/// - Campos con `@Rest(name: ...)` forman parte del contrato con backend.
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
    this.description,
    this.deletedAt,
  });

  /// UUID estable administrado por backend.
  @Rest(name: 'id')
  final String localId;

  /// Nombre visible de la categoria (Ternero, Vaquillona, Novillo, ...).
  @Rest(name: 'nombre')
  final String name;

  /// Descripcion opcional de la categoria.
  @Rest(name: 'descripcion')
  final String? description;

  /// Timestamp de creacion recibido desde backend.
  final DateTime createdAt;

  /// Timestamp de ultima modificacion recibido desde backend.
  final DateTime updatedAt;

  /// Timestamp de borrado logico para sync de deletes.
  final DateTime? deletedAt;
}

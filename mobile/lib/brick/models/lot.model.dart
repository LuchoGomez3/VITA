import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

/// Configuración REST futura del recurso; la Fase 2 no invoca este endpoint.
class BrickLotRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer exigido por el modelo offline-first.
  const BrickLotRequestTransformer(super.query, super.instance);

  /// Ruta reservada para la futura fase de sincronización.
  static const lotsPath = '/api/v1/lotes';

  @override
  RestRequest get get => const RestRequest(url: lotsPath, topLevelKey: 'data');

  @override
  RestRequest get upsert => const RestRequest(method: 'POST', url: lotsPath);
}

/// Lote almacenado exclusivamente en SQLite durante la Fase 2.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickLotRequestTransformer.new,
  ),
)
class BrickLotModel extends OfflineFirstWithRestModel {
  /// Crea el modelo técnico de persistencia local.
  BrickLotModel({
    required this.localId,
    required this.establishmentId,
    required this.name,
    required this.boundaryJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// UUID generado por el dispositivo para identificar el lote offline.
  @Rest(name: 'id')
  final String localId;

  /// UUID del establecimiento propietario.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Nombre elegido por el usuario dentro del establecimiento.
  @Rest(name: 'nombre')
  final String name;

  /// Geometría cartesiana versionada; no es WGS84 ni GeoJSON.
  @Rest(name: 'geometria_local')
  final String boundaryJson;

  /// Momento de creación generado en el dispositivo.
  @Rest(name: 'created_at')
  final DateTime createdAt;

  /// Momento de la última modificación local.
  @Rest(name: 'updated_at')
  final DateTime updatedAt;

  /// Marca de borrado lógico reservada para futuras operaciones.
  @Rest(name: 'deleted_at')
  final DateTime? deletedAt;
}

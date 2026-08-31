import 'dart:convert';

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

/// Configuración REST futura del recurso; la Fase 2 no invoca este endpoint.
class BrickLotRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer exigido por el modelo offline-first.
  const BrickLotRequestTransformer(super.query, super.instance);

  /// Ruta reservada para la futura fase de sincronización.
  // TODO(field-backend): validar con backend ruta, upsert, pull incremental,
  // tombstones y códigos de rechazo antes de habilitar el feature flag.
  static const lotsPath = '/api/v1/lotes';

  /// Crea el pull incremental filtrado por tenant.
  static RestRequest listByEstablishmentRequest(String establishmentId) => RestRequest(
    url: '$lotsPath?establecimiento_id=${Uri.encodeQueryComponent(establishmentId)}&include_deleted=true',
    topLevelKey: 'data',
  );

  /// Identifica eventos de sync correspondientes a lotes.
  static bool matchesLotResource(String resourcePath) => resourcePath.endsWith(lotsPath);

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
    required this.surfaceTenths,
    required this.hasWater,
    required this.statusCode,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.forageResourceCode,
    this.syncStatus = BrickLotSyncStatus.pending,
    this.syncErrorCode,
    this.geometryMode = 'local_schematic',
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
  // TODO(field-geo): agregar una geometría geográfica GeoJSON/WGS84 separada
  // cuando exista mapa real; conservar esta geometría como fallback offline.
  @Rest(
    name: 'geometria_local',
    toGenerator: 'brickLotGeometryToBackend(%INSTANCE_PROPERTY%)',
    fromGenerator: 'brickLotGeometryFromBackend(%DATA_PROPERTY%)',
  )
  final String boundaryJson;

  /// Distingue el esquema local de una geometría geográfica futura.
  // TODO(field-geo): acordar con backend los modos y la estrategia para lotes
  // creados en el lienzo local que todavía no tengan coordenadas reales.
  @Rest(name: 'geometry_mode')
  final String geometryMode;

  /// Superficie productiva exacta; 457 representa 45,7 hectáreas.
  @Rest(
    name: 'superficie_ha',
    toGenerator: 'brickLotSurfaceToBackend(%INSTANCE_PROPERTY%)',
    fromGenerator: 'brickLotSurfaceFromBackend(%DATA_PROPERTY%)',
  )
  final int surfaceTenths;

  /// Código estable del catálogo de recurso forrajero.
  @Rest(name: 'recurso_forrajero_codigo')
  final String? forageResourceCode;

  /// Disponibilidad actual de agua.
  @Rest(name: 'tiene_agua')
  final bool hasWater;

  /// Estado operativo persistido como código para tolerar versiones futuras.
  @Rest(name: 'estado')
  final String statusCode;

  /// Momento de creación generado en el dispositivo.
  @Rest(name: 'created_at')
  final DateTime createdAt;

  /// Momento de la última modificación local.
  @Rest(name: 'updated_at')
  final DateTime updatedAt;

  /// Marca de borrado lógico reservada para futuras operaciones.
  @Rest(name: 'deleted_at')
  final DateTime? deletedAt;

  /// Estado técnico local; nunca forma parte del payload de negocio.
  @Rest(ignore: true)
  final BrickLotSyncStatus syncStatus;

  /// Último código de rechazo remoto, si la sincronización está habilitada.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Crea una copia reconciliada conservando la fila SQLite.
  BrickLotModel copyWith({
    BrickLotSyncStatus? syncStatus,
    String? syncErrorCode,
  }) => BrickLotModel(
    localId: localId,
    establishmentId: establishmentId,
    name: name,
    boundaryJson: boundaryJson,
    geometryMode: geometryMode,
    surfaceTenths: surfaceTenths,
    forageResourceCode: forageResourceCode,
    hasWater: hasWater,
    statusCode: statusCode,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncErrorCode: syncErrorCode,
  )..primaryKey = primaryKey;
}

/// Estado técnico de sincronización de un lote.
enum BrickLotSyncStatus {
  /// Guardado en el dispositivo y todavía no confirmado por backend.
  pending,

  /// Confirmado por backend.
  synchronized,

  /// Rechazado por una regla autoritativa de backend.
  rejected,
}

/// Serializa décimas exactas como decimal de hectáreas.
double brickLotSurfaceToBackend(int tenths) => tenths / 10;

/// Recupera hectáreas decimales en décimas exactas.
int brickLotSurfaceFromBackend(Object? value) {
  if (value is num) return (value.toDouble() * 10).round();
  final parsed = double.tryParse(value?.toString() ?? '');
  if (parsed == null) return 0;
  return (parsed * 10).round();
}

/// Envía la geometría versionada como objeto JSON y no como texto escapado.
// TODO(field-geo): ramificar este serializador por geometryMode cuando exista
// GeoJSON real; nunca interpretar el lienzo 0..1000 como latitud/longitud.
Object brickLotGeometryToBackend(String encoded) {
  final decoded = jsonDecode(encoded) as Object?;
  return decoded ?? const <String, Object?>{};
}

/// Conserva el objeto remoto como texto canónico para SQLite.
String brickLotGeometryFromBackend(Object? value) {
  if (value is String) return value;
  return jsonEncode(value);
}

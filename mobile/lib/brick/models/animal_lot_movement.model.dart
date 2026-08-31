import 'dart:convert';

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

/// Contrato REST preparado para movimientos de hacienda entre lotes.
class BrickAnimalLotMovementRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer exigido por Brick.
  const BrickAnimalLotMovementRequestTransformer(super.query, super.instance);

  /// Endpoint acordado provisionalmente con backend.
  // TODO(field-backend): validar el contrato batch, la atomicidad y los códigos
  // de conflicto antes de habilitar la sincronización de movimientos.
  static const movementsPath = '/api/v1/movimientos_lotes';

  @override
  RestRequest get get => const RestRequest(
    url: movementsPath,
    topLevelKey: 'data',
  );

  @override
  RestRequest get upsert => const RestRequest(
    method: 'POST',
    url: movementsPath,
  );
}

/// Movimiento durable de uno o varios animales entre lotes.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickAnimalLotMovementRequestTransformer.new,
  ),
)
class BrickAnimalLotMovementModel extends OfflineFirstWithRestModel {
  /// Crea el registro técnico persistido localmente.
  BrickAnimalLotMovementModel({
    required this.localId,
    required this.establishmentId,
    required this.sourceLotId,
    required this.destinationLotId,
    required this.animalIdsJson,
    required this.occurredAt,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
    this.responsibleId,
    this.deletedAt,
  });

  /// UUID generado por mobile.
  @Rest(name: 'id')
  final String localId;

  /// Tenant al que pertenece el movimiento.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Lote de procedencia.
  @Rest(name: 'lote_origen_id')
  final String sourceLotId;

  /// Lote de destino.
  @Rest(name: 'lote_destino_id')
  final String destinationLotId;

  /// UUID de animales serializados para SQLite y enviados como lista REST.
  @Rest(
    name: 'animal_ids',
    toGenerator: 'brickMovementAnimalIdsToBackend(%INSTANCE_PROPERTY%)',
    fromGenerator: 'brickMovementAnimalIdsFromBackend(%DATA_PROPERTY%)',
  )
  final String animalIdsJson;

  /// Fecha efectiva elegida por el usuario.
  @Rest(name: 'fecha_movimiento')
  final DateTime occurredAt;

  /// Motivo operativo obligatorio.
  @Rest(name: 'motivo')
  final String reason;

  /// Usuario responsable; queda opcional hasta alinear roles/sesión.
  // TODO(field-auth): completar siempre este UUID desde la sesión autenticada
  // cuando se cierre el modelo definitivo de roles y auditoría.
  @Rest(name: 'responsable_id')
  final String? responsibleId;

  /// Auditoría offline-first.
  @Rest(name: 'created_at')
  final DateTime createdAt;

  /// Auditoría para resolución LWW futura.
  @Rest(name: 'updated_at')
  final DateTime updatedAt;

  /// Tombstone sincronizable.
  @Rest(name: 'deleted_at')
  final DateTime? deletedAt;
}

/// Convierte la representación SQLite a la lista esperada por REST.
Object brickMovementAnimalIdsToBackend(String encoded) => jsonDecode(encoded) as Object;

/// Convierte la lista REST a texto estable para SQLite.
String brickMovementAnimalIdsFromBackend(Object? value) => jsonEncode(value);

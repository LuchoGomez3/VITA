import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';

/// Contrato REST de notas independientes; el autor lo establece el backend.
class BrickAnimalObservationRequestTransformer extends RestRequestTransformer {
  /// Crea requests para una observación persistida en Brick.
  const BrickAnimalObservationRequestTransformer(super.query, super.instance);

  /// Ruta centralizada del historial de observaciones.
  static const observationsPath = '/api/v1/observaciones_animales';

  /// Lista solo las notas del animal dentro de su establecimiento.
  static RestRequest listForAnimal(String establishmentId, String animalId) => RestRequest(
    url:
        '$observationsPath?establecimiento_id=${Uri.encodeQueryComponent(establishmentId)}'
        '&animal_id=${Uri.encodeQueryComponent(animalId)}&include_deleted=true',
    topLevelKey: 'data',
  );

  @override
  RestRequest get get => const RestRequest(url: observationsPath, topLevelKey: 'data');

  @override
  RestRequest get upsert => const RestRequest(method: 'POST', url: observationsPath);
}

/// Nota offline-first separada de la columna legacy de observaciones del animal.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(requestTransformer: BrickAnimalObservationRequestTransformer.new),
)
class BrickAnimalObservationModel extends OfflineFirstWithRestModel {
  /// Crea una entrada identificada por UUID para reenvíos idempotentes.
  BrickAnimalObservationModel({
    required this.localId,
    required this.establishmentId,
    required this.animalId,
    required this.text,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.authorId,
    this.syncStatus = BrickAnimalSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID local y remoto de la nota.
  @Rest(name: 'id')
  final String localId;

  /// Establecimiento al que pertenece el animal.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Animal al que se adjunta la entrada.
  @Rest(name: 'animal_id')
  final String animalId;

  /// Texto íntegro de la nota, sin sustituir entradas anteriores.
  @Rest(name: 'texto')
  final String text;

  /// Fecha de la observación, diferente del timestamp de sincronización.
  @Rest(name: 'fecha')
  final DateTime date;

  /// Autor asignado por backend; no se envía desde mobile.
  @Rest(name: 'autor_id', ignoreTo: true)
  final String? authorId;

  /// Estado local de la cola de sincronización.
  @Rest(ignore: true)
  final BrickAnimalSyncStatus syncStatus;

  /// Rechazo funcional, si la sincronización no pudo aceptar la nota.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Timestamp cliente usado para el alta idempotente.
  final DateTime createdAt;

  /// Versión cliente usada por last-write-wins.
  final DateTime updatedAt;

  /// Borrado lógico recibido durante el pull.
  final DateTime? deletedAt;

  /// Cambia únicamente el resultado local de sincronización.
  BrickAnimalObservationModel withSync(BrickAnimalSyncStatus status, String? errorCode) => BrickAnimalObservationModel(
    localId: localId,
    establishmentId: establishmentId,
    animalId: animalId,
    text: text,
    date: date,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    authorId: authorId,
    syncStatus: status,
    syncErrorCode: errorCode,
  )..primaryKey = primaryKey;
}

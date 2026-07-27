import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

const _unchangedSyncErrorCode = Object();

/// Metodo de pesaje persistido localmente por Brick.
///
/// Espeja el enum `MetodoPesaje` del backend. La traduccion al contrato REST se
/// hace con los generators de mas abajo para mantener nombres Dart locales.
enum BrickPesajeMethod {
  /// Peso ingresado manualmente.
  manual,

  /// Peso capturado desde balanza Bluetooth.
  bluetoothScale,

  /// Peso estimado por inteligencia artificial en el dispositivo.
  artificialIntelligence,
}

/// Estado local de sincronizacion del pesaje.
///
/// No viaja al backend. Sirve para que mobile sepa si una pesada cargada offline
/// esta pendiente, confirmada o rechazada tras el intento de sync.
enum BrickPesajeSyncStatus {
  /// Guardado localmente y pendiente de sincronizar.
  pending,

  /// Confirmado por el backend.
  synchronized,

  /// Rechazado por el backend y pendiente de correccion/revision.
  rejected,
}

/// Define las rutas REST que Brick usa para sincronizar pesajes.
///
/// Una pesada se envia a `POST /api/v1/pesajes`; el listado devuelve los pesajes
/// del establecimiento (opcionalmente de un solo animal) envuelto en
/// `StandardResponse.data`.
class BrickPesajeRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer de requests para pesajes.
  const BrickPesajeRequestTransformer(super.query, super.instance);

  /// Ruta base del recurso de pesajes en el backend.
  ///
  /// Se centraliza aca para que stores, adapters generados y flujos de sync usen
  /// el mismo contrato HTTP. Si el endpoint cambia, se ajusta una sola vez.
  static const String weighingsPath = '/api/v1/pesajes';

  /// Request usado por Brick para listar pesajes desde backend.
  ///
  /// `topLevelKey` indica que la lista real esta dentro de `data`.
  static const RestRequest listRequest = RestRequest(
    url: weighingsPath,
    topLevelKey: 'data',
  );

  /// Request usado por Brick para enviar altas/updates de pesajes.
  static const RestRequest upsertRequest = RestRequest(
    method: 'POST',
    url: weighingsPath,
  );

  /// Crea el request de listado de pesajes del establecimiento.
  static RestRequest listByEstablishmentRequest(String establishmentId) {
    final encodedEstablishmentId = Uri.encodeQueryComponent(establishmentId);

    return RestRequest(
      url: '$weighingsPath?establecimiento_id=$encodedEstablishmentId',
      topLevelKey: 'data',
    );
  }

  /// Crea el request del historial de pesajes de un unico animal (evolucion/GPD).
  static RestRequest listByAnimalRequest(
    String establishmentId,
    String animalId,
  ) {
    final encodedEstablishmentId = Uri.encodeQueryComponent(establishmentId);
    final encodedAnimalId = Uri.encodeQueryComponent(animalId);

    return RestRequest(
      url:
          '$weighingsPath?establecimiento_id=$encodedEstablishmentId&animal_id=$encodedAnimalId',
      topLevelKey: 'data',
    );
  }

  /// Indica si un resultado de sync corresponde al recurso de pesajes.
  ///
  /// Se valida por sufijo contra la ruta centralizada porque algunos clientes
  /// reportan el path completo con base URL incluida.
  static bool matchesPesajeResource(String resourcePath) {
    return resourcePath.endsWith(weighingsPath);
  }

  /// Request usado por Brick para hidratar pesajes desde backend.
  @override
  RestRequest get get => listRequest;

  /// Request usado por Brick para enviar altas/updates al backend.
  @override
  RestRequest get upsert => upsertRequest;
}

/// Modelo Brick offline-first para pesajes.
///
/// Es transaccional, igual que el animal: el flujo pesado es el push con cola
/// offline (se cargan pesadas en el campo sin conexion y se sincronizan luego).
/// El pesaje inicial del animal viaja embebido en el alta del animal; este
/// modelo cubre las pesadas siguientes que alimentan la GPD.
///
/// Reglas de responsabilidad:
/// - Campos con `@Rest(name: ...)` forman parte del contrato con backend.
/// - Campos con `@Rest(ignore: true)` se guardan solo localmente para UX/sync.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickPesajeRequestTransformer.new,
  ),
)
class BrickPesajeModel extends OfflineFirstWithRestModel {
  /// Crea un pesaje persistible y sincronizable por Brick.
  BrickPesajeModel({
    required this.localId,
    required this.establishmentId,
    required this.animalId,
    required this.weightKg,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.method = BrickPesajeMethod.manual,
    this.isEstimated = false,
    this.bodyCondition,
    this.photoUrl,
    this.responsibleId,
    this.observations,
    this.deletedAt,
    this.syncStatus = BrickPesajeSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado por mobile. Viaja al backend como `id`.
  @Rest(name: 'id')
  final String localId;

  /// ID backend del establecimiento.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// ID backend del animal pesado.
  @Rest(name: 'animal_id')
  final String animalId;

  /// Peso en kilogramos.
  ///
  /// El backend lo persiste como Numeric y lo serializa como string ("185.500");
  /// el generator tolera tanto string como numero al leerlo.
  @Rest(
    name: 'peso_kg',
    fromGenerator: 'brickPesoFromBackend(%DATA_PROPERTY%)',
  )
  final double weightKg;

  /// Fecha/hora de la pesada.
  @Rest(
    name: 'fecha',
    fromGenerator: 'brickPesajeDateTimeFromBackend(%DATA_PROPERTY%)',
  )
  final DateTime date;

  /// Metodo usado para obtener el peso, traducido a/desde el enum del backend.
  @Rest(
    name: 'metodo',
    fromGenerator: 'brickPesajeMethodFromBackend(%DATA_PROPERTY% as String?)',
    toGenerator: 'brickPesajeMethodToBackend(%INSTANCE_PROPERTY%)',
  )
  final BrickPesajeMethod method;

  /// Indica si el peso fue estimado (por IA) en vez de medido.
  @Rest(name: 'es_estimado')
  final bool isEstimated;

  /// Condicion corporal opcional (escala 1-5).
  @Rest(
    name: 'condicion_corporal',
    fromGenerator: 'brickNullablePesoFromBackend(%DATA_PROPERTY%)',
  )
  final double? bodyCondition;

  /// URL opcional de la foto asociada a la pesada.
  @Rest(name: 'foto_url')
  final String? photoUrl;

  /// ID backend del usuario responsable de la pesada.
  ///
  /// Si es null, el backend usa el usuario autenticado como responsable.
  @Rest(name: 'responsable_id')
  final String? responsibleId;

  /// Observaciones libres de la pesada.
  @Rest(name: 'observaciones')
  final String? observations;

  /// Estado local de sincronizacion. No se envia al backend.
  @Rest(ignore: true)
  final BrickPesajeSyncStatus syncStatus;

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
  BrickPesajeModel copyWith({
    BrickPesajeSyncStatus? syncStatus,
    Object? syncErrorCode = _unchangedSyncErrorCode,
    DateTime? updatedAt,
  }) {
    final nextSyncErrorCode = identical(syncErrorCode, _unchangedSyncErrorCode)
        ? this.syncErrorCode
        : syncErrorCode as String?;

    return BrickPesajeModel(
      localId: localId,
      establishmentId: establishmentId,
      animalId: animalId,
      weightKg: weightKg,
      date: date,
      method: method,
      isEstimated: isEstimated,
      bodyCondition: bodyCondition,
      photoUrl: photoUrl,
      responsibleId: responsibleId,
      observations: observations,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncErrorCode: nextSyncErrorCode,
    )..primaryKey = primaryKey;
  }
}

/// Convierte el metodo de pesaje del backend al enum local persistido.
BrickPesajeMethod brickPesajeMethodFromBackend(String? value) {
  return switch (value) {
    'balanza_bluetooth' => BrickPesajeMethod.bluetoothScale,
    'estimacion_ia' => BrickPesajeMethod.artificialIntelligence,
    _ => BrickPesajeMethod.manual,
  };
}

/// Convierte el metodo local persistido al enum de pesaje del backend.
String brickPesajeMethodToBackend(BrickPesajeMethod value) {
  return switch (value) {
    BrickPesajeMethod.manual => 'manual',
    BrickPesajeMethod.bluetoothScale => 'balanza_bluetooth',
    BrickPesajeMethod.artificialIntelligence => 'estimacion_ia',
  };
}

/// Convierte el peso del backend a double.
///
/// El backend serializa Numeric como string ("185.500"), pero se toleran tambien
/// numeros por robustez. Un valor ausente cae a 0.
double brickPesoFromBackend(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }

  return 0;
}

/// Como [brickPesoFromBackend] pero preserva null para campos opcionales.
double? brickNullablePesoFromBackend(Object? value) {
  if (value == null) {
    return null;
  }

  return brickPesoFromBackend(value);
}

/// Convierte fechas del backend a DateTime, tolerando campos ausentes.
DateTime brickPesajeDateTimeFromBackend(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.parse(value);
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}

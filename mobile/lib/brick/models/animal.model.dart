import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

const _unchangedSyncErrorCode = Object();

/// Sexo persistido localmente por Brick.
///
/// No se guarda directamente como `macho` / `hembra` para mantener el modelo
/// local con nombres Dart. La traduccion al contrato backend se hace con los
/// generators REST definidos mas abajo.
enum BrickAnimalSex {
  /// Animal macho.
  male,

  /// Animal hembra.
  female,
}

/// Metodo de pesaje persistido localmente por Brick.
enum BrickAnimalWeighingMethod {
  /// Peso ingresado manualmente.
  manual,

  /// Peso capturado desde balanza Bluetooth.
  bluetoothScale,

  /// Peso estimado por inteligencia artificial en el dispositivo.
  artificialIntelligence,
}

/// Estado local de sincronizacion del registro.
///
/// Este estado no viaja al backend. Sirve para que mobile sepa si el registro
/// esta pendiente, confirmado o rechazado despues del intento de sync.
enum BrickAnimalSyncStatus {
  /// Guardado localmente y pendiente de sincronizar.
  pending,

  /// Confirmado por el backend.
  synchronized,

  /// Rechazado por el backend y pendiente de correccion/revision.
  rejected,
}

/// Define las rutas REST que Brick usa para sincronizar animales.
///
/// Brick genera adapters a partir de este modelo. Este transformer le dice al
/// adapter que el alta se envia a `POST /api/v1/animales` y que los listados del
/// backend vienen envueltos dentro de `StandardResponse.data`.
class BrickAnimalRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer de requests para animales.
  const BrickAnimalRequestTransformer(super.query, super.instance);

  /// Request usado por Brick para hidratar animales desde backend.
  @override
  RestRequest get get => const RestRequest(
    url: '/api/v1/animales',
    topLevelKey: 'data',
  );

  /// Request usado por Brick para enviar altas/updates al backend.
  @override
  RestRequest get upsert => const RestRequest(
    method: 'POST',
    url: '/api/v1/animales',
  );
}

/// Modelo Brick offline-first para animales.
///
/// Este no es el modelo de dominio ni una copia exacta del modelo del backend.
/// Es el modelo que Brick sabe guardar en SQLite y serializar hacia REST.
///
/// Reglas de responsabilidad:
/// - Campos con `@Rest(name: ...)` forman parte del contrato con backend.
/// - Campos con `@Rest(ignore: true)` se guardan solo localmente para UX/sync.
/// - Las validaciones de negocio deben ocurrir antes, en domain/use cases o
///   validadores. Este modelo se enfoca en persistencia local y sincronizacion.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickAnimalRequestTransformer.new,
  ),
)
class BrickAnimalModel extends OfflineFirstWithRestModel {
  /// Crea un animal persistible y sincronizable por Brick.
  BrickAnimalModel({
    required this.localId,
    required this.rfidTagNumber,
    required this.visualTag,
    required this.sex,
    required this.breed,
    required this.birthDate,
    required this.categoryId,
    required this.lotId,
    required this.establishmentId,
    required this.initialWeight,
    required this.weighingMethod,
    required this.weighingDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.categoryName = '',
    this.lotName = '',
    this.motherId,
    this.fatherId,
    this.coat,
    this.observations,
    this.syncStatus = BrickAnimalSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado por mobile. Viaja al backend como `id`.
  @Rest(name: 'id')
  final String localId;

  /// Numero de caravana RFID. Backend lo espera como `nro_caravana_rfid`.
  @Rest(name: 'nro_caravana_rfid')
  final String rfidTagNumber;

  /// Caravana visual opcional mostrada al usuario.
  @Rest(
    name: 'caravana_visual',
    fromGenerator: 'brickStringFromBackend(%DATA_PROPERTY%)',
  )
  final String visualTag;

  /// Sexo del animal, traducido a/desde el enum textual del backend.
  @Rest(
    name: 'sexo',
    fromGenerator: 'brickAnimalSexFromBackend(%DATA_PROPERTY% as String)',
    toGenerator: 'brickAnimalSexToBackend(%INSTANCE_PROPERTY%)',
  )
  final BrickAnimalSex sex;

  /// Raza declarada al registrar el animal.
  @Rest(
    name: 'raza',
    fromGenerator: 'brickStringFromBackend(%DATA_PROPERTY%)',
  )
  final String breed;

  /// Fecha de nacimiento. Para backend se serializa como fecha sin hora.
  @Rest(
    name: 'fecha_nacimiento',
    toGenerator: 'brickDateToBackend(%INSTANCE_PROPERTY%)',
  )
  final DateTime birthDate;

  /// ID backend de la categoria productiva.
  @Rest(name: 'categoria_id')
  final String categoryId;

  /// Nombre local de la categoria para mostrar en UI.
  ///
  /// No se envia al backend porque la fuente de verdad es `categoria_id` y la
  /// tabla/catalogo de categorias.
  @Rest(ignore: true)
  final String categoryName;

  /// ID backend del lote/potrero.
  @Rest(name: 'lote_id')
  final String lotId;

  /// Nombre local del lote para mostrar en UI.
  ///
  /// No se envia al backend porque la fuente de verdad es `lote_id` y la tabla
  /// de lotes.
  @Rest(ignore: true)
  final String lotName;

  /// ID backend del establecimiento.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Peso inicial del animal.
  @Rest(
    name: 'peso_inicial',
    fromGenerator: 'brickDoubleFromBackend(%DATA_PROPERTY%)',
  )
  final double initialWeight;

  /// Metodo usado para obtener el peso inicial.
  @Rest(
    name: 'metodo_pesaje',
    fromGenerator: 'brickAnimalWeighingMethodFromBackend(%DATA_PROPERTY% as String?)',
    toGenerator: 'brickAnimalWeighingMethodToBackend(%INSTANCE_PROPERTY%)',
  )
  final BrickAnimalWeighingMethod weighingMethod;

  /// Fecha/hora del pesaje inicial.
  @Rest(
    name: 'fecha_pesaje',
    fromGenerator: 'brickDateTimeFromBackend(%DATA_PROPERTY%)',
  )
  final DateTime weighingDate;

  /// ID backend de la madre, si se selecciono genealogia.
  @Rest(name: 'madre_id')
  final String? motherId;

  /// ID backend del padre, si se selecciono genealogia.
  @Rest(name: 'padre_id')
  final String? fatherId;

  /// Pelaje declarado del animal.
  @Rest(name: 'pelaje')
  final String? coat;

  /// Observaciones libres del registro.
  @Rest(name: 'observaciones')
  final String? observations;

  /// Estado local de sincronizacion.
  ///
  /// No se envia al backend: representa el estado de la cola/local sync en este
  /// dispositivo.
  @Rest(ignore: true)
  final BrickAnimalSyncStatus syncStatus;

  /// Codigo de error local asociado al ultimo rechazo de sync.
  ///
  /// No se envia al backend. Se guarda para que la UI pueda explicar por que el
  /// registro quedo `rejected`.
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
  /// Este metodo se usa cuando llega una respuesta del backend y necesitamos
  /// actualizar el estado local (`pending` -> `synchronized` / `rejected`) sin
  /// reencolar otro request REST.
  BrickAnimalModel copyWith({
    BrickAnimalSyncStatus? syncStatus,
    Object? syncErrorCode = _unchangedSyncErrorCode,
    DateTime? updatedAt,
  }) {
    final nextSyncErrorCode =
        identical(
          syncErrorCode,
          _unchangedSyncErrorCode,
        )
        ? this.syncErrorCode
        : syncErrorCode as String?;

    return BrickAnimalModel(
      localId: localId,
      rfidTagNumber: rfidTagNumber,
      visualTag: visualTag,
      sex: sex,
      breed: breed,
      birthDate: birthDate,
      categoryId: categoryId,
      categoryName: categoryName,
      lotId: lotId,
      lotName: lotName,
      establishmentId: establishmentId,
      initialWeight: initialWeight,
      weighingMethod: weighingMethod,
      weighingDate: weighingDate,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      motherId: motherId,
      fatherId: fatherId,
      coat: coat,
      observations: observations,
      syncErrorCode: nextSyncErrorCode,
    )..primaryKey = primaryKey;
  }
}

/// Convierte el enum de sexo del backend al enum local persistido.
BrickAnimalSex brickAnimalSexFromBackend(String value) {
  return switch (value) {
    'macho' => BrickAnimalSex.male,
    'hembra' => BrickAnimalSex.female,
    _ => throw ArgumentError.value(value, 'value', 'Unsupported animal sex'),
  };
}

/// Convierte el enum local persistido al enum de sexo del backend.
String brickAnimalSexToBackend(BrickAnimalSex value) {
  return switch (value) {
    BrickAnimalSex.male => 'macho',
    BrickAnimalSex.female => 'hembra',
  };
}

/// Convierte el metodo de pesaje del backend al enum local persistido.
BrickAnimalWeighingMethod brickAnimalWeighingMethodFromBackend(String? value) {
  return switch (value) {
    'balanza_bluetooth' => BrickAnimalWeighingMethod.bluetoothScale,
    'estimacion_ia' => BrickAnimalWeighingMethod.artificialIntelligence,
    _ => BrickAnimalWeighingMethod.manual,
  };
}

/// Convierte el metodo local persistido al enum de pesaje del backend.
String brickAnimalWeighingMethodToBackend(BrickAnimalWeighingMethod value) {
  return switch (value) {
    BrickAnimalWeighingMethod.manual => 'manual',
    BrickAnimalWeighingMethod.bluetoothScale => 'balanza_bluetooth',
    BrickAnimalWeighingMethod.artificialIntelligence => 'estimacion_ia',
  };
}

/// Formatea un [DateTime] como fecha simple para `fecha_nacimiento`.
String brickDateToBackend(DateTime value) {
  return value.toIso8601String().split('T').first;
}

/// Convierte numeros del backend a double, tolerando campos ausentes.
double brickDoubleFromBackend(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  return 0;
}

/// Convierte strings opcionales del backend a strings locales seguros.
String brickStringFromBackend(Object? value) {
  if (value is String) {
    return value;
  }

  return '';
}

/// Convierte fechas opcionales del backend a DateTime.
DateTime brickDateTimeFromBackend(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.parse(value);
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

/// Persisted sex values for offline animal registration.
enum BrickAnimalSex {
  male,
  female,
}

/// Persisted weighing methods for offline animal registration.
enum BrickAnimalWeighingMethod {
  manual,
  bluetoothScale,
  artificialIntelligence,
}

/// Persisted synchronization states for offline animal registration.
enum BrickAnimalSyncStatus {
  pending,
  synchronized,
  rejected,
}

/// REST routes used by Brick to synchronize animal registrations.
class BrickAnimalRequestTransformer extends RestRequestTransformer {
  /// Creates the request transformer for animals.
  const BrickAnimalRequestTransformer(super.query, super.instance);

  @override
  RestRequest get get => const RestRequest(
    url: '/api/v1/animales',
    topLevelKey: 'data',
  );

  @override
  RestRequest get upsert => const RestRequest(
    method: 'POST',
    url: '/api/v1/animales',
  );
}

/// Offline-first representation of an animal registration draft.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickAnimalRequestTransformer.new,
  ),
)
class BrickAnimalModel extends OfflineFirstWithRestModel {
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

  @Rest(name: 'id')
  final String localId;

  @Rest(name: 'nro_caravana_rfid')
  final String rfidTagNumber;

  @Rest(name: 'caravana_visual')
  final String visualTag;

  @Rest(
    name: 'sexo',
    fromGenerator: 'brickAnimalSexFromBackend(%DATA_PROPERTY% as String)',
    toGenerator: 'brickAnimalSexToBackend(%INSTANCE_PROPERTY%)',
  )
  final BrickAnimalSex sex;

  @Rest(name: 'raza')
  final String breed;

  @Rest(
    name: 'fecha_nacimiento',
    toGenerator: 'brickDateToBackend(%INSTANCE_PROPERTY%)',
  )
  final DateTime birthDate;

  @Rest(name: 'categoria_id')
  final String categoryId;

  @Rest(ignore: true)
  final String categoryName;

  @Rest(name: 'lote_id')
  final String lotId;

  @Rest(ignore: true)
  final String lotName;

  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  @Rest(name: 'peso_inicial')
  final double initialWeight;

  @Rest(
    name: 'metodo_pesaje',
    fromGenerator: 'brickAnimalWeighingMethodFromBackend(%DATA_PROPERTY% as String?)',
    toGenerator: 'brickAnimalWeighingMethodToBackend(%INSTANCE_PROPERTY%)',
  )
  final BrickAnimalWeighingMethod weighingMethod;

  @Rest(name: 'fecha_pesaje')
  final DateTime weighingDate;

  @Rest(name: 'madre_id')
  final String? motherId;

  @Rest(name: 'padre_id')
  final String? fatherId;

  @Rest(name: 'pelaje')
  final String? coat;

  @Rest(name: 'observaciones')
  final String? observations;

  @Rest(ignore: true)
  final BrickAnimalSyncStatus syncStatus;

  @Rest(ignore: true)
  final String? syncErrorCode;

  final DateTime createdAt;

  final DateTime updatedAt;

  final DateTime? deletedAt;

  /// Creates a copy with selected fields changed.
  BrickAnimalModel copyWith({
    BrickAnimalSyncStatus? syncStatus,
    String? syncErrorCode,
    DateTime? updatedAt,
  }) {
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
      syncErrorCode: syncErrorCode,
    )..primaryKey = primaryKey;
  }
}

/// Converts the backend sex enum to the local persisted enum.
BrickAnimalSex brickAnimalSexFromBackend(String value) {
  return switch (value) {
    'macho' => BrickAnimalSex.male,
    'hembra' => BrickAnimalSex.female,
    _ => throw ArgumentError.value(value, 'value', 'Unsupported animal sex'),
  };
}

/// Converts the local persisted sex enum to the backend enum.
String brickAnimalSexToBackend(BrickAnimalSex value) {
  return switch (value) {
    BrickAnimalSex.male => 'macho',
    BrickAnimalSex.female => 'hembra',
  };
}

/// Converts the backend weighing method enum to the local persisted enum.
BrickAnimalWeighingMethod brickAnimalWeighingMethodFromBackend(String? value) {
  return switch (value) {
    'balanza_bluetooth' => BrickAnimalWeighingMethod.bluetoothScale,
    'estimacion_ia' => BrickAnimalWeighingMethod.artificialIntelligence,
    _ => BrickAnimalWeighingMethod.manual,
  };
}

/// Converts the local persisted weighing method enum to the backend enum.
String brickAnimalWeighingMethodToBackend(BrickAnimalWeighingMethod value) {
  return switch (value) {
    BrickAnimalWeighingMethod.manual => 'manual',
    BrickAnimalWeighingMethod.bluetoothScale => 'balanza_bluetooth',
    BrickAnimalWeighingMethod.artificialIntelligence => 'estimacion_ia',
  };
}

/// Formats a DateTime as the backend date-only field.
String brickDateToBackend(DateTime value) {
  return value.toIso8601String().split('T').first;
}

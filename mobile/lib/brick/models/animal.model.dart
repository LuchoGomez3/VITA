import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

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

/// Offline-first representation of an animal registration draft.
@ConnectOfflineFirstWithRest()
class BrickAnimalModel extends OfflineFirstWithRestModel {
  BrickAnimalModel({
    required this.localId,
    required this.rfidTagNumber,
    required this.visualTag,
    required this.sex,
    required this.breed,
    required this.birthDate,
    required this.categoryId,
    required this.categoryName,
    required this.lotId,
    required this.lotName,
    required this.establishmentId,
    required this.initialWeight,
    required this.weighingMethod,
    required this.weighingDate,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.motherId,
    this.fatherId,
    this.coat,
    this.observations,
    this.syncErrorCode,
  });

  final String localId;
  final String rfidTagNumber;
  final String visualTag;
  final BrickAnimalSex sex;
  final String breed;
  final DateTime birthDate;
  final String categoryId;
  final String categoryName;
  final String lotId;
  final String lotName;
  final String establishmentId;
  final double initialWeight;
  final BrickAnimalWeighingMethod weighingMethod;
  final DateTime weighingDate;
  final String? motherId;
  final String? fatherId;
  final String? coat;
  final String? observations;
  final BrickAnimalSyncStatus syncStatus;
  final String? syncErrorCode;
  final DateTime createdAt;
  final DateTime updatedAt;
}

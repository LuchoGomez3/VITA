import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_registration.freezed.dart';

/// Sex values accepted by the animal registration domain.
enum AnimalSex {
  /// Male animal.
  male,

  /// Female animal.
  female,
}

/// Supported methods for the initial weighing.
enum AnimalWeighingMethod {
  /// Weight entered manually.
  manual,

  /// Weight received from a Bluetooth scale.
  bluetoothScale,

  /// Weight estimated by an on-device model.
  artificialIntelligence,
}

/// Synchronization state of an animal saved on the device.
enum AnimalSyncStatus {
  /// Saved locally and waiting to reach the backend.
  pending,

  /// Confirmed by the backend.
  synchronized,

  /// Rejected by the backend and requiring user review.
  rejected,
}

/// Data required to register an animal and its initial weighing.
@freezed
sealed class AnimalRegistration with _$AnimalRegistration {
  /// Creates an animal registration request.
  const factory AnimalRegistration({
    required String rfidTagNumber,
    required AnimalSex sex,
    required String breed,
    required DateTime birthDate,
    required String lotId,
    required String establishmentId,
    required double initialWeight,
    String? visualTag,
    String? motherId,
    String? fatherId,
    String? categoryId,
    String? coat,
    String? observations,
    @Default(AnimalWeighingMethod.manual) AnimalWeighingMethod weighingMethod,
    DateTime? weighingDate,
  }) = _AnimalRegistration;
}

/// Animal registration persisted by the offline-first repository.
@freezed
sealed class RegisteredAnimal with _$RegisteredAnimal {
  /// Creates the locally identifiable registration result.
  const factory RegisteredAnimal({
    required String id,
    required AnimalRegistration registration,
    required AnimalSyncStatus syncStatus,
    String? syncErrorCode,
  }) = _RegisteredAnimal;
}

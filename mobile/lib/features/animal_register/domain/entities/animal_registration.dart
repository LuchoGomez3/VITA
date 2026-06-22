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

extension AnimalSexBackendValue on AnimalSex {
  /// Backend-compatible value for the animal sex enum.
  String get backendValue => switch (this) {
    AnimalSex.male => 'macho',
    AnimalSex.female => 'hembra',
  };
}

extension AnimalWeighingMethodBackendValue on AnimalWeighingMethod {
  /// Backend-compatible value for the initial weighing method enum.
  String get backendValue => switch (this) {
    AnimalWeighingMethod.manual => 'manual',
    AnimalWeighingMethod.bluetoothScale => 'balanza_bluetooth',
    AnimalWeighingMethod.artificialIntelligence => 'estimacion_ia',
  };
}

/// Data required to register an animal and its initial weighing.
@freezed
sealed class AnimalRegistration with _$AnimalRegistration {
  /// Creates an animal registration request.
  const factory AnimalRegistration({
    required String rfidTagNumber,
    required String visualTag,
    required AnimalSex sex,
    required String breed,
    required DateTime birthDate,
    required String lotId,
    required String lotName,
    required String establishmentId,
    required String categoryId,
    required String categoryName,
    required double initialWeight,
    String? motherId,
    String? fatherId,
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
    required DateTime createdAt,
    required DateTime updatedAt,
    required String displayDestination,
    required String displayCategory,
    String? syncErrorCode,
  }) = _RegisteredAnimal;
}

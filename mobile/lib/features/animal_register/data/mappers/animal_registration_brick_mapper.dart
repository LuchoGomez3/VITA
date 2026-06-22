import 'dart:math';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Maps animal registration domain entities to Brick models and back.
class AnimalRegistrationBrickMapper {
  const AnimalRegistrationBrickMapper._();

  /// Creates a persistible Brick model from the domain registration request.
  static BrickAnimalModel toBrick(
    AnimalRegistration registration, {
    DateTime? now,
    String? localId,
  }) {
    final timestamp = now ?? DateTime.now().toUtc();

    return BrickAnimalModel(
      // TODO(agustin): Revisit the canonical mobile identity strategy before
      // enabling sync/update flows. `localId` is the exposed domain ID, while
      // Brick also keeps its own SQLite primary key internally.
      localId: localId ?? _generateUuid(),
      rfidTagNumber: registration.rfidTagNumber,
      visualTag: registration.visualTag,
      sex: registration.sex.toBrickModel(),
      breed: registration.breed,
      birthDate: registration.birthDate,
      categoryId: registration.categoryId,
      categoryName: registration.categoryName,
      lotId: registration.lotId,
      lotName: registration.lotName,
      establishmentId: registration.establishmentId,
      initialWeight: registration.initialWeight,
      weighingMethod: registration.weighingMethod.toBrickModel(),
      weighingDate: registration.weighingDate ?? timestamp,
      motherId: registration.motherId,
      fatherId: registration.fatherId,
      coat: registration.coat,
      observations: registration.observations,
      syncStatus: BrickAnimalSyncStatus.pending,
      syncErrorCode: null,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  /// Creates the domain result returned by the offline repository.
  static RegisteredAnimal toDomain(BrickAnimalModel model) {
    final registration = AnimalRegistration(
      rfidTagNumber: model.rfidTagNumber,
      visualTag: model.visualTag,
      sex: model.sex.toDomain(),
      breed: model.breed,
      birthDate: model.birthDate,
      lotId: model.lotId,
      lotName: model.lotName,
      establishmentId: model.establishmentId,
      categoryId: model.categoryId,
      categoryName: model.categoryName,
      initialWeight: model.initialWeight,
      motherId: model.motherId,
      fatherId: model.fatherId,
      coat: model.coat,
      observations: model.observations,
      weighingMethod: model.weighingMethod.toDomain(),
      weighingDate: model.weighingDate,
    );

    return RegisteredAnimal(
      id: model.localId,
      registration: registration,
      syncStatus: model.syncStatus.toDomain(),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      displayDestination: model.lotName,
      displayCategory: model.categoryName,
      syncErrorCode: model.syncErrorCode,
    );
  }

  /// Future backend payload contract for `POST /v1/animales`.
  ///
  /// This is intentionally unused in the first offline-local cut. It documents
  /// the mapping we will need once the sync flow is enabled against the FastAPI
  /// endpoint without leaking transport concerns into presentation.
  static Map<String, dynamic> toBackendPayload(BrickAnimalModel model) {
    return <String, dynamic>{
      'nro_caravana_rfid': model.rfidTagNumber,
      'sexo': model.sex.toDomain().backendValue,
      'raza': model.breed,
      'fecha_nacimiento': model.birthDate.toIso8601String().split('T').first,
      'lote_id': model.lotId,
      'establecimiento_id': model.establishmentId,
      'madre_id': model.motherId,
      'padre_id': model.fatherId,
      'categoria_id': model.categoryId,
      'caravana_visual': model.visualTag,
      'pelaje': model.coat,
      'observaciones': model.observations,
      'peso_inicial': model.initialWeight,
      'metodo_pesaje': model.weighingMethod.toDomain().backendValue,
      'fecha_pesaje': model.weighingDate.toIso8601String(),
      // Pending backend alignment:
      // the mobile app generates `localId` as a UUID now, but the current
      // `AnimalCreate` backend schema does not accept a client-defined `id`.
    };
  }

  static String _generateUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20, 32),
    ].join('-');
  }
}

extension on AnimalSex {
  BrickAnimalSex toBrickModel() => switch (this) {
    AnimalSex.male => BrickAnimalSex.male,
    AnimalSex.female => BrickAnimalSex.female,
  };
}

extension on BrickAnimalSex {
  AnimalSex toDomain() => switch (this) {
    BrickAnimalSex.male => AnimalSex.male,
    BrickAnimalSex.female => AnimalSex.female,
  };
}

extension on AnimalWeighingMethod {
  BrickAnimalWeighingMethod toBrickModel() => switch (this) {
    AnimalWeighingMethod.manual => BrickAnimalWeighingMethod.manual,
    AnimalWeighingMethod.bluetoothScale => BrickAnimalWeighingMethod.bluetoothScale,
    AnimalWeighingMethod.artificialIntelligence => BrickAnimalWeighingMethod.artificialIntelligence,
  };
}

extension on BrickAnimalWeighingMethod {
  AnimalWeighingMethod toDomain() => switch (this) {
    BrickAnimalWeighingMethod.manual => AnimalWeighingMethod.manual,
    BrickAnimalWeighingMethod.bluetoothScale => AnimalWeighingMethod.bluetoothScale,
    BrickAnimalWeighingMethod.artificialIntelligence => AnimalWeighingMethod.artificialIntelligence,
  };
}

extension on BrickAnimalSyncStatus {
  AnimalSyncStatus toDomain() => switch (this) {
    BrickAnimalSyncStatus.pending => AnimalSyncStatus.pending,
    BrickAnimalSyncStatus.synchronized => AnimalSyncStatus.synchronized,
    BrickAnimalSyncStatus.rejected => AnimalSyncStatus.rejected,
  };
}

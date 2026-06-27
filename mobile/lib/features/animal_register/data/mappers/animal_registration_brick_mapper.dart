import 'dart:math';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Mapper entre dominio, Brick y contrato backend.
///
/// Esta clase es una frontera de data: evita que las capas de dominio y
/// presentacion conozcan detalles de Brick, SQLite o nombres de campos REST.
class AnimalRegistrationBrickMapper {
  const AnimalRegistrationBrickMapper._();

  /// Convierte una solicitud de dominio en un modelo persistible por Brick.
  ///
  /// Aca nace la identidad offline-first del registro: si no se inyecta
  /// [localId], se genera un UUID en mobile. Ese UUID viaja luego al backend
  /// como `id`, permitiendo registrar sin conexion y sincronizar despues sin
  /// depender de IDs autogenerados por el servidor.
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
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  /// Convierte un modelo Brick guardado en un resultado de dominio.
  ///
  /// El repository usa este metodo para devolverle al use case/BLoC un
  /// [RegisteredAnimal], sin exponerles `BrickAnimalModel` ni detalles de la
  /// base local.
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

  /// Construye el payload que espera `POST /api/v1/animales`.
  ///
  /// Brick usa sus adapters generados para serializar el request real, pero
  /// mantener este metodo explicito ayuda a testear y auditar el contrato con
  /// backend. Tambien sirve como documentacion viva de la traduccion
  /// lowerCamelCase/mobile -> snake_case/backend.
  static Map<String, dynamic> toBackendPayload(BrickAnimalModel model) {
    return <String, dynamic>{
      'id': model.localId,
      'created_at': model.createdAt.toIso8601String(),
      'updated_at': model.updatedAt.toIso8601String(),
      'deleted_at': model.deletedAt?.toIso8601String(),
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
    };
  }

  /// Genera un UUID v4 para identificar el registro creado offline.
  ///
  /// Se implementa localmente para no introducir una dependencia nueva solo para
  /// esta operacion. Si el proyecto adopta una libreria UUID compartida, este
  /// helper se puede reemplazar.
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

/// Traduce el enum de sexo del dominio al enum persistido por Brick.
extension on AnimalSex {
  BrickAnimalSex toBrickModel() => switch (this) {
    AnimalSex.male => BrickAnimalSex.male,
    AnimalSex.female => BrickAnimalSex.female,
  };
}

/// Traduce el enum de sexo persistido por Brick al enum del dominio.
extension on BrickAnimalSex {
  AnimalSex toDomain() => switch (this) {
    BrickAnimalSex.male => AnimalSex.male,
    BrickAnimalSex.female => AnimalSex.female,
  };
}

/// Traduce el metodo de pesaje del dominio al enum persistido por Brick.
extension on AnimalWeighingMethod {
  BrickAnimalWeighingMethod toBrickModel() => switch (this) {
    AnimalWeighingMethod.manual => BrickAnimalWeighingMethod.manual,
    AnimalWeighingMethod.bluetoothScale => BrickAnimalWeighingMethod.bluetoothScale,
    AnimalWeighingMethod.artificialIntelligence => BrickAnimalWeighingMethod.artificialIntelligence,
  };
}

/// Traduce el metodo de pesaje persistido por Brick al enum del dominio.
extension on BrickAnimalWeighingMethod {
  AnimalWeighingMethod toDomain() => switch (this) {
    BrickAnimalWeighingMethod.manual => AnimalWeighingMethod.manual,
    BrickAnimalWeighingMethod.bluetoothScale => AnimalWeighingMethod.bluetoothScale,
    BrickAnimalWeighingMethod.artificialIntelligence => AnimalWeighingMethod.artificialIntelligence,
  };
}

/// Traduce el estado local de sincronizacion de Brick al dominio.
extension on BrickAnimalSyncStatus {
  AnimalSyncStatus toDomain() => switch (this) {
    BrickAnimalSyncStatus.pending => AnimalSyncStatus.pending,
    BrickAnimalSyncStatus.synchronized => AnimalSyncStatus.synchronized,
    BrickAnimalSyncStatus.rejected => AnimalSyncStatus.rejected,
  };
}

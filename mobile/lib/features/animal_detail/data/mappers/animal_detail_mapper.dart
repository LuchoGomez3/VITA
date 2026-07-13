import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Mapper entre Brick/backend y el modelo de dominio del detalle.
class AnimalDetailMapper {
  const AnimalDetailMapper._();

  /// Convierte el modelo Brick cacheado en dominio.
  static AnimalDetail fromBrick(BrickAnimalModel model) {
    return AnimalDetail(
      id: model.localId,
      rfidTagNumber: model.rfidTagNumber,
      visualTag: model.visualTag,
      sex: model.sex.toDomain(),
      breed: model.breed,
      birthDate: model.birthDate,
      categoryId: model.categoryId,
      categoryName: model.categoryName,
      lotId: model.lotId,
      lotName: model.lotName,
      establishmentId: model.establishmentId,
      // Los animales descargados pueden no incluir todavía un pesaje inicial.
      currentWeight: model.initialWeight ?? 0,
      weighingMethod: model.weighingMethod.toDomain(),
      weighingDate: model.weighingDate,
      syncStatus: model.syncStatus.toDomain(),
      syncErrorCode: model.syncErrorCode,
      updatedAt: model.updatedAt,
      motherId: model.motherId,
      fatherId: model.fatherId,
      coat: model.coat,
      observations: model.observations,
    );
  }

  /// Convierte el DTO remoto en dominio cuando no existe cache local.
  static AnimalDetail fromBackend(AnimalDetailBackendDto dto) {
    return fromBrick(toBrickCache(dto));
  }

  /// Convierte el DTO remoto en un modelo Brick cacheable sin re-sync.
  static BrickAnimalModel toBrickCache(AnimalDetailBackendDto dto) {
    return BrickAnimalModel(
      localId: dto.id,
      rfidTagNumber: dto.rfidTagNumber,
      visualTag: dto.visualTag,
      sex: dto.sex.toBrickSex(),
      breed: dto.breed,
      birthDate: dto.birthDate,
      categoryId: dto.categoryId,
      lotId: dto.lotId,
      establishmentId: dto.establishmentId,
      initialWeight: 0,
      weighingMethod: BrickAnimalWeighingMethod.manual,
      weighingDate: dto.updatedAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      motherId: dto.motherId,
      fatherId: dto.fatherId,
      coat: dto.coat,
      observations: dto.observations,
      syncStatus: BrickAnimalSyncStatus.synchronized,
    );
  }
}

extension on BrickAnimalSex {
  AnimalSex toDomain() => switch (this) {
    BrickAnimalSex.male => AnimalSex.male,
    BrickAnimalSex.female => AnimalSex.female,
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

extension on String {
  BrickAnimalSex toBrickSex() => switch (this) {
    'macho' => BrickAnimalSex.male,
    'hembra' => BrickAnimalSex.female,
    _ => BrickAnimalSex.male,
  };
}

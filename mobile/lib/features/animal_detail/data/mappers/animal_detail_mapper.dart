import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_observation.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';

/// Mapper entre Brick/backend y el modelo de dominio del detalle.
class AnimalDetailMapper {
  const AnimalDetailMapper._();

  /// Traduce códigos del backend a enums del dominio sin filtrar estados reales.
  static AnimalStatus statusFromBackend(String value) => switch (value) {
    'activo' => AnimalStatus.active,
    'vendido' => AnimalStatus.sold,
    'muerto' => AnimalStatus.dead,
    'baja' => AnimalStatus.inactive,
    _ => throw const FormatException('Estado de animal inválido'),
  };

  /// Traduce condiciones opcionales, incluyendo el valor explícito sin determinar.
  static AnimalReproductiveStatus? reproductionFromBackend(String? value) => switch (value) {
    null => null,
    'sin_determinar' => AnimalReproductiveStatus.undetermined,
    'vacia' => AnimalReproductiveStatus.empty,
    'prenada' => AnimalReproductiveStatus.pregnant,
    _ => throw const FormatException('Condición reproductiva inválida'),
  };

  /// Obtiene la regla del catálogo para filtrar categorías y opciones de preñez.
  static AnimalDetailCategory categoryFromBrick(BrickCategoriaModel category) => AnimalDetailCategory(
    id: category.localId,
    name: category.name,
    allowedSex: switch (category.allowedSex) {
      'macho' => AnimalSex.male,
      'hembra' => AnimalSex.female,
      'ambos' => null,
      _ => throw const FormatException('Sexo permitido inválido'),
    },
    allowsReproductiveStatus: category.allowsReproductiveStatus,
  );

  /// Mantiene cada nota separada y su resultado de sincronización visible.
  static AnimalDetailObservation observationFromBrick(BrickAnimalObservationModel note) => AnimalDetailObservation(
    id: note.localId,
    text: note.text,
    date: note.date,
    syncStatus: note.syncStatus.toDomain(),
    syncErrorCode: note.syncErrorCode,
  );

  /// Convierte el modelo Brick cacheado en dominio.
  static AnimalDetail fromBrick(BrickAnimalModel model) {
    return AnimalDetail(
      id: model.localId,
      status: statusFromBackend(model.status),
      reproductiveStatus: reproductionFromBackend(model.reproductiveStatus),
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
      syncStatus:
          model.syncStatus == BrickAnimalSyncStatus.rejected || model.lotSyncStatus == BrickAnimalSyncStatus.rejected
          ? AnimalSyncStatus.rejected
          : model.syncStatus == BrickAnimalSyncStatus.pending || model.lotSyncStatus == BrickAnimalSyncStatus.pending
          ? AnimalSyncStatus.pending
          : AnimalSyncStatus.synchronized,
      syncErrorCode: model.syncErrorCode ?? model.lotSyncErrorCode,
      updatedAt: model.updatedAt,
      weightHistory: const [],
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
  ///
  /// Este camino surge solo si la ficha no encontro el animal en SQLite y se
  /// uso el fallback remoto del repository. Se guarda como `synchronized` para
  /// que Brick lo trate como dato ya confirmado por backend.
  static BrickAnimalModel toBrickCache(AnimalDetailBackendDto dto) {
    return BrickAnimalModel(
      localId: dto.id,
      status: dto.status,
      reproductiveStatus: dto.reproductiveStatus,
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

  /// Convierte los pesajes Brick en registros de dominio para la grafica.
  static List<AnimalWeightRecord> weightHistoryFromBrick(
    List<BrickPesajeModel> models,
  ) {
    return models
        .map(
          (model) => AnimalWeightRecord(
            id: model.localId,
            weightKg: model.weightKg,
            date: model.date,
            method: model.method.toDomain(),
          ),
        )
        .toList(growable: false);
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

extension on BrickPesajeMethod {
  AnimalWeighingMethod toDomain() => switch (this) {
    BrickPesajeMethod.manual => AnimalWeighingMethod.manual,
    BrickPesajeMethod.bluetoothScale => AnimalWeighingMethod.bluetoothScale,
    BrickPesajeMethod.artificialIntelligence => AnimalWeighingMethod.artificialIntelligence,
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

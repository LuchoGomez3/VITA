import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/mappers/identified_animal_mapper.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_animal_lookup_repository.dart';

/// Implementa la busqueda RFID usando exclusivamente Brick/SQLite local.
class RfidAnimalLookupRepositoryImpl implements RfidAnimalLookupRepository {
  /// Crea el repositorio con el store local de animales.
  const RfidAnimalLookupRepositoryImpl({
    required AnimalBrickStore animalBrickStore,
  }) : _animalBrickStore = animalBrickStore;

  final AnimalBrickStore _animalBrickStore;

  @override
  Future<Result<IdentifiedAnimal?>> findByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async {
    try {
      final animal = await _animalBrickStore.getAnimalByRfidTagNumber(
        rfidTagNumber: rfidTagNumber,
        establishmentId: establishmentId,
      );

      return Result.success(
        animal == null ? null : IdentifiedAnimalMapper.fromBrick(animal),
      );
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudo buscar la caravana en el dispositivo.',
        ),
      );
    }
  }

  @override
  Future<Result<List<IdentifiedAnimal>>> findByRfidPrefix({
    required String rfidPrefix,
    required String establishmentId,
  }) async {
    try {
      final normalizedPrefix = rfidPrefix.trim();
      if (normalizedPrefix.isEmpty) {
        return const Result.success(<IdentifiedAnimal>[]);
      }

      final animals = await _animalBrickStore.getLocalAnimals();
      final matches =
          animals
              .where(
                (animal) =>
                    animal.establishmentId == establishmentId &&
                    animal.deletedAt == null &&
                    animal.rfidTagNumber.startsWith(normalizedPrefix),
              )
              .map(IdentifiedAnimalMapper.fromBrick)
              .toList()
            ..sort((left, right) => left.rfidTagNumber.compareTo(right.rfidTagNumber));

      return Result.success(matches.take(10).toList(growable: false));
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron buscar coincidencias en el dispositivo.',
        ),
      );
    }
  }
}

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
}

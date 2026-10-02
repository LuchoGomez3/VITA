import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/mappers/livestock_sale_animal_mapper.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_animal_repository.dart';

/// Consulta el inventario Brick/SQLite sin depender de conectividad.
class LivestockSaleAnimalRepositoryImpl implements LivestockSaleAnimalRepository {
  /// Crea el repositorio con el store compartido de animales.
  const LivestockSaleAnimalRepositoryImpl({
    required AnimalBrickStore animalBrickStore,
  }) : _animalBrickStore = animalBrickStore;

  final AnimalBrickStore _animalBrickStore;

  @override
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  ) async {
    try {
      final animals = await _animalBrickStore.getLocalAnimals();
      final animal = _selectLatestAnimal(
        animals: animals,
        rfidTagNumber: rfidTagNumber,
      );

      return Result.success(
        animal == null ? null : LivestockSaleAnimalMapper.fromBrick(animal),
      );
    } on Object {
      const reason = LivestockSaleSelectionError.localRead;
      return const Result.failure(
        DomainException(
          message: 'localRead',
          code: DomainErrorCode.offline,
          reason: reason,
        ),
      );
    }
  }

  BrickAnimalModel? _selectLatestAnimal({
    required Iterable<BrickAnimalModel> animals,
    required String rfidTagNumber,
  }) {
    BrickAnimalModel? latest;

    // La busqueda abarca todos los establecimientos para que dominio pueda
    // distinguir una caravana ajena de una que no existe en el dispositivo.
    for (final animal in animals) {
      if (animal.rfidTagNumber != rfidTagNumber || animal.deletedAt != null) {
        continue;
      }
      if (latest == null || animal.updatedAt.isAfter(latest.updatedAt)) {
        latest = animal;
      }
    }

    return latest;
  }
}

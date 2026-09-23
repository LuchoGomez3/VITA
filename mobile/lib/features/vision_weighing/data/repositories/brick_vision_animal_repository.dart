import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_animal_repository.dart';

/// Arma las opciones de asociación desde SQLite y el catálogo offline.
class BrickVisionAnimalRepository implements VisionAnimalRepository {
  /// Recibe las fuentes compartidas desde la composición de la feature.
  const BrickVisionAnimalRepository(this._animals, this._establishments);

  final AnimalBrickStore _animals;
  final EstablishmentCatalog _establishments;

  @override
  Future<VisionAnimalOptions> getOptions() async {
    try {
      final memberships = await _establishments.getMemberships();
      final establishmentIds = memberships.map((membership) => membership.id).toSet();
      final animals =
          (await _animals.getLocalAnimals())
              .where((animal) => animal.deletedAt == null && establishmentIds.contains(animal.establishmentId))
              .map(
                (animal) => VisionAnimal(
                  id: animal.localId,
                  establishmentId: animal.establishmentId,
                  rfidTagNumber: animal.rfidTagNumber,
                  visualTag: animal.visualTag,
                  updatedAt: animal.updatedAt,
                ),
              )
              .toList()
            ..sort((first, second) => second.updatedAt.compareTo(first.updatedAt));
      return VisionAnimalOptions(
        animals: animals,
        establishments: [
          for (final membership in memberships) VisionEstablishment(id: membership.id, name: membership.name),
        ],
      );
    } on Exception catch (error) {
      throw VisionDeviceException(cause: error);
    }
  }
}

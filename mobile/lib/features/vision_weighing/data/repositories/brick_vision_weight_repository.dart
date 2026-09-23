import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_weight_repository.dart';

/// Persiste pesajes IA offline sin asumir cómo se obtuvo la predicción.
class BrickVisionWeightRepository implements VisionWeightRepository {
  /// Recibe stores compartidos sin exponer modelos Brick al dominio.
  const BrickVisionWeightRepository(this._animals, this._weighings);

  final AnimalBrickStore _animals;
  final PesajeBrickStore _weighings;

  @override
  Future<void> saveEstimate({required String animalId, required double weightKg}) async {
    try {
      // El UUID distingue animales con el mismo RFID en establecimientos distintos.
      final animal = await _animals.getAnimalById(animalId);
      if (animal == null) throw const VisionAnimalNotFoundException();
      final now = DateTime.now().toUtc();
      await _weighings.upsertPesaje(
        BrickPesajeModel(
          localId: generateUuidV4(),
          establishmentId: animal.establishmentId,
          animalId: animal.localId,
          weightKg: weightKg,
          date: now,
          createdAt: now,
          updatedAt: now,
          method: BrickPesajeMethod.artificialIntelligence,
          isEstimated: true,
        ),
      );
    } on VisionWeighingException {
      rethrow;
    } on Exception catch (error) {
      throw VisionDeviceException(cause: error);
    }
  }
}

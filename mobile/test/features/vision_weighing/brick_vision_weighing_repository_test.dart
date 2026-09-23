import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/brick_vision_weight_repository.dart';

class _Animals extends Fake implements AnimalBrickStore {
  List<BrickAnimalModel> animals = [];

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async {
    for (final animal in animals) {
      if (animal.localId == animalId && animal.deletedAt == null) return animal;
    }
    return null;
  }
}

class _Weighings extends Fake implements PesajeBrickStore {
  BrickPesajeModel? saved;

  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) async => saved = pesaje;
}

BrickAnimalModel _animal(String id, String establishmentId) {
  final now = DateTime.utc(2026, 9, 16);
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: 'AR-1',
    visualTag: '1',
    sex: BrickAnimalSex.female,
    breed: 'Aberdeen Angus',
    birthDate: now,
    categoryId: 'category-id',
    lotId: 'lot-id',
    establishmentId: establishmentId,
    initialWeight: 200,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: now,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('guarda el peso en el animal local con método IA y estado estimado', () async {
    final animals = _Animals()..animals = [_animal('animal-id', 'farm-id')];
    final weighings = _Weighings();
    final repository = BrickVisionWeightRepository(animals, weighings);

    final beforeSave = DateTime.now().toUtc();
    await repository.saveEstimate(animalId: 'animal-id', weightKg: 390);
    final afterSave = DateTime.now().toUtc();

    expect(weighings.saved?.animalId, 'animal-id');
    expect(weighings.saved?.establishmentId, 'farm-id');
    expect(weighings.saved?.weightKg, 390);
    expect(weighings.saved?.method, BrickPesajeMethod.artificialIntelligence);
    expect(weighings.saved?.isEstimated, isTrue);
    expect(weighings.saved?.syncStatus, BrickPesajeSyncStatus.pending);
    expect(weighings.saved?.date.isBefore(beforeSave), isFalse);
    expect(weighings.saved?.date.isAfter(afterSave), isFalse);
    expect(weighings.saved?.createdAt, weighings.saved?.date);
    expect(weighings.saved?.updatedAt, weighings.saved?.date);
    expect(brickPesajeMethodToBackend(weighings.saved!.method), 'estimacion_ia');
  });

  test('no guarda un animal ausente y distingue IDs con igual RFID', () async {
    final animals = _Animals();
    final weighings = _Weighings();
    final repository = BrickVisionWeightRepository(animals, weighings);

    await expectLater(repository.saveEstimate(animalId: 'missing', weightKg: 390), throwsException);
    animals.animals = [_animal('one', 'farm-a'), _animal('two', 'farm-b')];
    await repository.saveEstimate(animalId: 'two', weightKg: 390);
    expect(weighings.saved?.animalId, 'two');
    expect(weighings.saved?.establishmentId, 'farm-b');
  });
}

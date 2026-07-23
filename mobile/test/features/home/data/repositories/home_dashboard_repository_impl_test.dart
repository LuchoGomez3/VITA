import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/data/repositories/home_dashboard_repository_impl.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';

void main() {
  test('calcula inventario, GPD y variabilidad por lote con datos locales', () async {
    // Arrange
    final animals = [
      _animal(
        id: 'animal-1',
        initialWeight: 100,
        weighingDate: DateTime(2026, 7),
        createdAt: DateTime(2026, 7, 2),
        categoryName: 'Terneros',
      ),
      _animal(
        id: 'animal-2',
        initialWeight: 200,
        weighingDate: DateTime(2026, 6),
        createdAt: DateTime(2026, 6),
        categoryName: 'Novillos',
      ),
      _animal(
        id: 'animal-3',
        initialWeight: 180,
        weighingDate: DateTime(2026, 5),
        createdAt: DateTime(2026, 5),
        categoryName: 'Novillos',
        deletedAt: DateTime(2026, 7, 10),
      ),
    ];
    final weighings = [
      _weighing(
        animalId: 'animal-1',
        weightKg: 121,
        date: DateTime(2026, 7, 15),
      ),
    ];
    final repository = HomeDashboardRepositoryImpl(
      animalStore: _FakeAnimalStore(animals),
      pesajeStore: _FakePesajeStore(weighings),
      now: () => DateTime(2026, 7, 22),
    );

    // Act
    final result = await repository.getDashboard();

    // Assert
    expect(result, isA<Success<HomeDashboard>>());
    final dashboard = (result as Success<HomeDashboard>).data;
    expect(dashboard.activeAnimals, 2);
    expect(dashboard.monthlyAdditions, 1);
    expect(dashboard.monthlyRemovals, 1);
    expect(dashboard.knownLiveWeightKg, 321);
    expect(dashboard.averageDailyGainKg, 1.5);
    expect(dashboard.animalsWithDailyGain, 1);
    expect(dashboard.categories.map((category) => category.name), ['Novillos', 'Terneros']);
    expect(dashboard.lots.single.averageWeightKg, 160.5);
    expect(dashboard.lots.single.weightStandardDeviationKg, 39.5);
  });
}

BrickAnimalModel _animal({
  required String id,
  required double initialWeight,
  required DateTime weighingDate,
  required DateTime createdAt,
  required String categoryName,
  DateTime? deletedAt,
}) {
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: 'rfid-$id',
    visualTag: id,
    sex: BrickAnimalSex.male,
    breed: 'Angus',
    birthDate: DateTime(2025),
    categoryId: 'category-$categoryName',
    categoryName: categoryName,
    lotId: 'lot-1',
    lotName: 'Norte',
    establishmentId: 'establishment-1',
    initialWeight: initialWeight,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: weighingDate,
    createdAt: createdAt,
    updatedAt: createdAt,
    deletedAt: deletedAt,
  );
}

BrickPesajeModel _weighing({
  required String animalId,
  required double weightKg,
  required DateTime date,
}) {
  return BrickPesajeModel(
    localId: 'weighing-$animalId',
    establishmentId: 'establishment-1',
    animalId: animalId,
    weightKg: weightKg,
    date: date,
    createdAt: date,
    updatedAt: date,
  );
}

class _FakeAnimalStore implements AnimalBrickStore {
  const _FakeAnimalStore(this.animals);

  final List<BrickAnimalModel> animals;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => animals;

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) => throw UnimplementedError();

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) => throw UnimplementedError();

  @override
  Future<void> pullRemoteAnimals(String establishmentId) => throw UnimplementedError();

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) => throw UnimplementedError();
}

class _FakePesajeStore implements PesajeBrickStore {
  const _FakePesajeStore(this.weighings);

  final List<BrickPesajeModel> weighings;

  @override
  Future<List<BrickPesajeModel>> getLocalPesajes() async => weighings;

  @override
  Future<List<BrickPesajeModel>> getLocalPesajesByAnimal(String animalId) => throw UnimplementedError();

  @override
  Future<List<BrickPesajeModel>> loadPesajesByAnimal(String establishmentId, String animalId) =>
      throw UnimplementedError();

  @override
  Future<void> pullRemotePesajes(String establishmentId, {String? animalId}) => throw UnimplementedError();

  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) => throw UnimplementedError();
}

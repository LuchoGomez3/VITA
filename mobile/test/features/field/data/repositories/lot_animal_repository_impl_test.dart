import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/data/repositories/lot_animal_repository_impl.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_summary.dart';

void main() {
  test('lists only productively active animals from the selected tenant', () async {
    final repository = LotAnimalRepositoryImpl(
      store: _FakeAnimalStore([
        _animal('active', 'activo'),
        _animal('sold', 'vendido'),
        _animal('dead', 'muerto'),
        _animal('removed', 'baja'),
        _animal('unknown', 'desconocido'),
        _animal(
          'other-tenant',
          'activo',
          establishmentId: 'other-establishment',
        ),
      ]),
    );

    final result = await repository.getAnimals(
      establishmentId: 'establishment-id',
    );

    expect(result, isA<Success<List<LotAnimalSummary>>>());
    final animals = (result as Success<List<LotAnimalSummary>>).data;
    expect(animals.map((animal) => animal.id), ['active']);
  });
}

BrickAnimalModel _animal(
  String id,
  String status, {
  String establishmentId = 'establishment-id',
}) {
  final timestamp = DateTime.utc(2026, 9, 29);
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: '982000000000001',
    visualTag: id,
    sex: BrickAnimalSex.female,
    breed: 'Angus',
    birthDate: DateTime.utc(2025),
    categoryId: 'category-id',
    categoryName: 'Vaca',
    lotId: 'lot-id',
    establishmentId: establishmentId,
    initialWeight: 300,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    status: status,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _FakeAnimalStore implements AnimalBrickStore {
  const _FakeAnimalStore(this.animals);

  final List<BrickAnimalModel> animals;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => animals;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

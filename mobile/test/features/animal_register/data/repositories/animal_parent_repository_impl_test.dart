import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_parent_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_parent.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

void main() {
  test('reads only active animals from the selected establishment', () async {
    final store = _AnimalStore([
      _animal('mother', 'farm-1', BrickAnimalSex.female),
      _animal('father', 'farm-1', BrickAnimalSex.male),
      _animal('other-farm', 'farm-2', BrickAnimalSex.female),
      _animal('deleted', 'farm-1', BrickAnimalSex.male, deletedAt: DateTime(2026)),
    ]);

    final result = await AnimalParentRepositoryImpl(store: store).getParents('farm-1');

    expect(result, isA<Success<List<AnimalParent>>>());
    final parents = (result as Success<List<AnimalParent>>).data;
    expect(parents.map((animal) => animal.id), ['mother', 'father']);
    expect(parents.first.sex, AnimalSex.female);
    expect(parents.last.sex, AnimalSex.male);
    expect(parents.first.rfid, '982000412991416');
  });
}

BrickAnimalModel _animal(
  String id,
  String establishmentId,
  BrickAnimalSex sex, {
  DateTime? deletedAt,
}) => BrickAnimalModel(
  localId: id,
  rfidTagNumber: '982000412991416',
  visualTag: '003 1295',
  sex: sex,
  breed: 'Aberdeen Angus',
  birthDate: DateTime(2024),
  categoryId: 'category-id',
  lotId: 'lot-id',
  establishmentId: establishmentId,
  initialWeight: 32,
  weighingMethod: BrickAnimalWeighingMethod.manual,
  weighingDate: DateTime(2024),
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  deletedAt: deletedAt,
);

class _AnimalStore extends Fake implements AnimalBrickStore {
  _AnimalStore(this.animals);

  final List<BrickAnimalModel> animals;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => animals;
}

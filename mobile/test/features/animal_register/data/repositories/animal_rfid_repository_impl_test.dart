import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_rfid_repository_impl.dart';

void main() {
  test('detects a duplicate from another establishment and ignores deleted animals', () async {
    final store = _AnimalStore([
      _animal('982000412991416', 'other-farm'),
      _animal('982000412991417', 'current-farm', deletedAt: DateTime(2026)),
    ]);
    final repository = AnimalRfidRepositoryImpl(store: store);

    expect(await repository.isRegistered('982000412991416'), const Result<bool>.success(true));
    expect(await repository.isRegistered('982000412991417'), const Result<bool>.success(false));
  });
}

BrickAnimalModel _animal(String rfid, String establishmentId, {DateTime? deletedAt}) => BrickAnimalModel(
  localId: rfid,
  rfidTagNumber: rfid,
  visualTag: '003 1295',
  sex: BrickAnimalSex.female,
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

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';

void main() {
  const rfid = '982000412991416';
  const establishmentId = 'establishment-id';

  group('BrickAnimalStore.selectAnimalForRfidLookup', () {
    test('returns only the active animal from the requested establishment', () {
      final result = BrickAnimalStore.selectAnimalForRfidLookup(
        animals: [
          _animal(id: 'other-establishment', establishmentId: 'other-id'),
          _animal(id: 'deleted', deletedAt: DateTime(2025, 4)),
          _animal(id: 'active'),
        ],
        rfidTagNumber: rfid,
        establishmentId: establishmentId,
      );

      expect(result?.localId, 'active');
    });

    test('returns the most recently updated matching animal', () {
      final result = BrickAnimalStore.selectAnimalForRfidLookup(
        animals: [
          _animal(id: 'old', updatedAt: DateTime(2025, 3)),
          _animal(id: 'new', updatedAt: DateTime(2025, 4)),
        ],
        rfidTagNumber: rfid,
        establishmentId: establishmentId,
      );

      expect(result?.localId, 'new');
    });

    test('returns null when no active local animal matches', () {
      final result = BrickAnimalStore.selectAnimalForRfidLookup(
        animals: [_animal(id: 'different-rfid', rfidTagNumber: '982000412991417')],
        rfidTagNumber: rfid,
        establishmentId: establishmentId,
      );

      expect(result, isNull);
    });
  });
}

BrickAnimalModel _animal({
  required String id,
  String rfidTagNumber = '982000412991416',
  String establishmentId = 'establishment-id',
  DateTime? deletedAt,
  DateTime? updatedAt,
}) {
  final timestamp = updatedAt ?? DateTime(2025, 3, 14);
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: rfidTagNumber,
    visualTag: '003 1295',
    sex: BrickAnimalSex.female,
    breed: 'Aberdeen Angus',
    birthDate: DateTime(2025, 3, 14),
    categoryId: 'category-id',
    lotId: 'lot-id',
    establishmentId: establishmentId,
    initialWeight: 32.5,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
    deletedAt: deletedAt,
  );
}

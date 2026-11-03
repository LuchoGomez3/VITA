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

  test('reconcile preserves a pending lot but adopts remote productive status', () {
    final statusChangedAt = DateTime.utc(2026, 10, 15);
    final local = _animal(
      id: 'animal-id',
      lotId: 'pending-destination',
    );
    final remote = _animal(
      id: 'animal-id',
      lotId: 'authoritative-origin',
      productiveStatus: BrickAnimalProductiveStatus.sold,
      productiveStatusChangedAt: statusChangedAt,
    );

    final reconciled = BrickAnimalStore.reconcileRemoteAnimal(
      local: local,
      remote: remote,
    );

    expect(reconciled.lotId, 'pending-destination');
    expect(reconciled.syncStatus, BrickAnimalSyncStatus.pending);
    expect(reconciled.productiveStatus, BrickAnimalProductiveStatus.sold);
    expect(reconciled.productiveStatusChangedAt, statusChangedAt);
  });
}

BrickAnimalModel _animal({
  required String id,
  String rfidTagNumber = '982000412991416',
  String establishmentId = 'establishment-id',
  DateTime? deletedAt,
  DateTime? updatedAt,
  String lotId = 'lot-id',
  BrickAnimalProductiveStatus productiveStatus = BrickAnimalProductiveStatus.active,
  DateTime? productiveStatusChangedAt,
  BrickAnimalSyncStatus syncStatus = BrickAnimalSyncStatus.pending,
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
    lotId: lotId,
    establishmentId: establishmentId,
    initialWeight: 32.5,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
    deletedAt: deletedAt,
    productiveStatus: productiveStatus,
    productiveStatusChangedAt: productiveStatusChangedAt,
    syncStatus: syncStatus,
  );
}

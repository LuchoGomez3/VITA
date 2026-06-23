import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/features/animal_register/data/mappers/animal_registration_brick_mapper.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

void main() {
  group('AnimalRegistrationBrickMapper', () {
    test('maps domain registrations to Brick models', () {
      final now = DateTime.utc(2025, 3, 14, 12);
      final registration = AnimalRegistration(
        rfidTagNumber: '982000412991416',
        visualTag: '003 1295',
        sex: AnimalSex.female,
        breed: 'Aberdeen Angus',
        birthDate: DateTime(2025, 3, 14),
        lotId: 'lot-id',
        lotName: 'La Cumbre',
        establishmentId: 'establishment-id',
        categoryId: 'category-id',
        categoryName: 'Ternera',
        initialWeight: 32.5,
        motherId: 'mother-id',
        fatherId: 'father-id',
        coat: 'Negro',
        observations: 'Sin novedades',
        weighingMethod: AnimalWeighingMethod.bluetoothScale,
        weighingDate: now,
      );

      final model = AnimalRegistrationBrickMapper.toBrick(
        registration,
        now: now,
        localId: 'local-id',
      );

      expect(model.localId, 'local-id');
      expect(model.sex, BrickAnimalSex.female);
      expect(model.weighingMethod, BrickAnimalWeighingMethod.bluetoothScale);
      expect(model.syncStatus, BrickAnimalSyncStatus.pending);
      expect(model.createdAt, now);
      expect(model.updatedAt, now);
    });

    test('maps Brick models back to domain results', () {
      final now = DateTime.utc(2025, 3, 14, 12);
      final model = BrickAnimalModel(
        localId: 'local-id',
        rfidTagNumber: '982000412991416',
        visualTag: '003 1295',
        sex: BrickAnimalSex.female,
        breed: 'Aberdeen Angus',
        birthDate: DateTime(2025, 3, 14),
        categoryId: 'category-id',
        categoryName: 'Ternera',
        lotId: 'lot-id',
        lotName: 'La Cumbre',
        establishmentId: 'establishment-id',
        initialWeight: 32.5,
        weighingMethod: BrickAnimalWeighingMethod.manual,
        weighingDate: now,
        fatherId: 'father-id',
        observations: 'Sin novedades',
        createdAt: now,
        updatedAt: now,
      );

      final registeredAnimal = AnimalRegistrationBrickMapper.toDomain(model);

      expect(registeredAnimal.id, 'local-id');
      expect(registeredAnimal.displayDestination, 'La Cumbre');
      expect(registeredAnimal.displayCategory, 'Ternera');
      expect(registeredAnimal.registration.sex, AnimalSex.female);
      expect(registeredAnimal.registration.fatherId, 'father-id');
    });

    test('maps Brick models to the backend animal creation payload', () {
      final now = DateTime.utc(2025, 3, 14, 12);
      final model = BrickAnimalModel(
        localId: '5b1f1111-1111-4111-8111-111111111111',
        rfidTagNumber: '982000412991416',
        visualTag: '003 1295',
        sex: BrickAnimalSex.female,
        breed: 'Aberdeen Angus',
        birthDate: DateTime(2025, 3, 14),
        categoryId: 'category-id',
        categoryName: 'Ternera',
        lotId: 'lot-id',
        lotName: 'La Cumbre',
        establishmentId: 'establishment-id',
        initialWeight: 32.5,
        weighingMethod: BrickAnimalWeighingMethod.bluetoothScale,
        weighingDate: now,
        motherId: 'mother-id',
        fatherId: 'father-id',
        coat: 'Negro',
        observations: 'Sin novedades',
        createdAt: now,
        updatedAt: now,
      );

      final payload = AnimalRegistrationBrickMapper.toBackendPayload(model);

      expect(payload['id'], model.localId);
      expect(payload['created_at'], now.toIso8601String());
      expect(payload['updated_at'], now.toIso8601String());
      expect(payload['deleted_at'], isNull);
      expect(payload['nro_caravana_rfid'], '982000412991416');
      expect(payload['sexo'], 'hembra');
      expect(payload['fecha_nacimiento'], '2025-03-14');
      expect(payload['lote_id'], 'lot-id');
      expect(payload['establecimiento_id'], 'establishment-id');
      expect(payload['metodo_pesaje'], 'balanza_bluetooth');
    });
  });
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/storage/animal_photo_store.dart';
import 'package:frontend_mayoral/core/storage/secure_storage_keys.dart';
import 'package:frontend_mayoral/core/storage/secure_storage_service.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/brick_vision_animal_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/data/repositories/brick_vision_weight_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/errors/vision_weighing_exception.dart';

class _Storage implements SecureStorageService {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

EstablishmentCatalog _catalog({String establishmentId = 'farm-id'}) => EstablishmentCatalog(
  secureStorage: _Storage()
    ..values[SecureStorageKeys.establishmentCatalog] = jsonEncode([
      {'id': establishmentId, 'name': 'Campo', 'role': 'employee'},
    ]),
);

class _Animals extends Fake implements AnimalBrickStore {
  List<BrickAnimalModel> animals = [];

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => animals;

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async {
    for (final animal in animals) {
      if (animal.localId == animalId && animal.deletedAt == null) return animal;
    }
    return null;
  }
}

class _Photos extends Fake implements AnimalPhotoStore {
  Uint8List? bytes;
  String? establishment;
  String? animal;
  bool fail = false;

  @override
  Future<void> savePhotoBytes({
    required String establishmentId,
    required String animalId,
    required Uint8List jpegBytes,
  }) async {
    if (fail) throw const FormatException('Storage unavailable');
    establishment = establishmentId;
    animal = animalId;
    bytes = jpegBytes;
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
  test('si falla el almacenamiento de la foto no confirma ni encola el pesaje', () async {
    final animals = _Animals()..animals = [_animal('animal-id', 'farm-id')];
    final weighings = _Weighings();
    final photos = _Photos()..fail = true;
    final repository = BrickVisionWeightRepository(animals, weighings, _catalog(), photoStore: photos);
    await expectLater(
      repository.saveEstimate(animalId: 'animal-id', weightKg: 390, jpegBytes: Uint8List(3)),
      throwsException,
    );
    expect(weighings.saved, isNull);
  });

  test('guarda el peso en el animal local con método IA y estado estimado', () async {
    final animals = _Animals()..animals = [_animal('animal-id', 'farm-id')];
    final weighings = _Weighings();
    final photos = _Photos();
    final repository = BrickVisionWeightRepository(animals, weighings, _catalog(), photoStore: photos);

    final beforeSave = DateTime.now().toUtc();
    await repository.saveEstimate(animalId: 'animal-id', weightKg: 390, jpegBytes: Uint8List.fromList([1, 2, 3]));
    final afterSave = DateTime.now().toUtc();

    expect(photos.animal, 'animal-id');
    expect(photos.establishment, 'farm-id');
    expect(photos.bytes, [1, 2, 3]);
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
    final photos = _Photos();
    final repository = BrickVisionWeightRepository(
      animals,
      weighings,
      _catalog(establishmentId: 'farm-b'),
      photoStore: photos,
    );

    await expectLater(
      repository.saveEstimate(animalId: 'missing', weightKg: 390, jpegBytes: Uint8List.fromList([1, 2, 3])),
      throwsException,
    );
    animals.animals = [_animal('one', 'farm-a'), _animal('two', 'farm-b')];
    await repository.saveEstimate(animalId: 'two', weightKg: 390, jpegBytes: Uint8List.fromList([1, 2, 3]));
    expect(weighings.saved?.animalId, 'two');
    expect(weighings.saved?.establishmentId, 'farm-b');
  });

  for (final role in ['admin', 'owner', 'employee', 'veterinarian', null, 'legacy-role', 'unknown']) {
    test('el catálogo y el guardado aplican el permiso offline para rol $role', () async {
      final storage = _Storage();
      await storage.write(
        key: SecureStorageKeys.establishmentCatalog,
        value: jsonEncode([
          {'id': 'farm-id', 'name': 'Campo', if (role != null) 'role': role},
        ]),
      );
      final catalog = EstablishmentCatalog(secureStorage: storage);
      final animals = _Animals()..animals = [_animal('animal-id', 'farm-id'), _animal('other', 'other-farm')];
      final photos = _Photos();
      final weighings = _Weighings();
      final options = await BrickVisionAnimalRepository(animals, catalog).getOptions();
      final repository = BrickVisionWeightRepository(animals, weighings, catalog, photoStore: photos);
      final allowed = ['admin', 'owner', 'employee', 'veterinarian'].contains(role);

      if (allowed) {
        expect(options.establishments.single.id, 'farm-id');
        expect(options.animals.single.id, 'animal-id');
        await repository.saveEstimate(animalId: 'animal-id', weightKg: 390, jpegBytes: Uint8List(3));
        expect(weighings.saved?.animalId, 'animal-id');
      } else {
        expect(options.establishments, isEmpty);
        expect(options.animals, isEmpty);
        await expectLater(
          repository.saveEstimate(animalId: 'animal-id', weightKg: 390, jpegBytes: Uint8List(3)),
          throwsA(isA<VisionWeighingAccessDeniedException>()),
        );
        expect(photos.bytes, isNull);
        expect(weighings.saved, isNull);
      }
    });
  }

  for (final replacement in [null, 'legacy-role']) {
    test('revalida la membresía al guardar si cambió después de seleccionar ($replacement)', () async {
      final storage = _Storage();
      final catalog = EstablishmentCatalog(secureStorage: storage);
      await storage.write(
        key: SecureStorageKeys.establishmentCatalog,
        value: jsonEncode([
          {'id': 'farm-id', 'name': 'Campo', 'role': 'employee'},
        ]),
      );
      final animals = _Animals()..animals = [_animal('animal-id', 'farm-id')];
      final options = await BrickVisionAnimalRepository(animals, catalog).getOptions();
      final selected = options.animals.single;
      await storage.write(
        key: SecureStorageKeys.establishmentCatalog,
        value: jsonEncode([
          if (replacement != null) {'id': 'farm-id', 'name': 'Campo', 'role': replacement},
        ]),
      );
      final photos = _Photos();
      final weighings = _Weighings();
      final repository = BrickVisionWeightRepository(animals, weighings, catalog, photoStore: photos);

      await expectLater(
        repository.saveEstimate(animalId: selected.id, weightKg: 390, jpegBytes: Uint8List(3)),
        throwsA(isA<VisionWeighingAccessDeniedException>()),
      );
      expect(photos.bytes, isNull);
      expect(weighings.saved, isNull);
    });
  }

  test('un catálogo corrupto impide efectos persistentes', () async {
    final storage = _Storage()..values[SecureStorageKeys.establishmentCatalog] = '{invalid';
    final animals = _Animals()..animals = [_animal('animal-id', 'farm-id')];
    final photos = _Photos();
    final weighings = _Weighings();
    final repository = BrickVisionWeightRepository(
      animals,
      weighings,
      EstablishmentCatalog(secureStorage: storage),
      photoStore: photos,
    );

    await expectLater(
      repository.saveEstimate(animalId: 'animal-id', weightKg: 390, jpegBytes: Uint8List(3)),
      throwsA(isA<VisionDeviceException>()),
    );
    expect(photos.bytes, isNull);
    expect(weighings.saved, isNull);
  });
}

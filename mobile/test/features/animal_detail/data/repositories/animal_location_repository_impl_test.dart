import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_location_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_location.dart';

void main() {
  late StreamController<Type> changes;
  late _AnimalStore animals;
  late _LotStore lots;
  late AnimalLocationRepositoryImpl repository;

  setUp(() {
    changes = StreamController<Type>.broadcast();
    animals = _AnimalStore();
    lots = _LotStore();
    repository = AnimalLocationRepositoryImpl(animalStore: animals, lotStore: lots, localChanges: changes.stream);
    addTearDown(changes.close);
  });

  test('lee sin red, observa el nombre del potrero y omite tipos ajenos', () async {
    final results = <Result<AnimalLocation?>>[];
    final subscription = repository.watchLocation('a1', establishmentId: 'e1').listen(results.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);
    expect((results.single as Success<AnimalLocation?>).data?.lotName, 'Origen');
    changes.add(String);
    await Future<void>.delayed(Duration.zero);
    expect(animals.calls, 1);
    lots.name = 'Renombrado';
    changes.add(BrickLotModel);
    await Future<void>.delayed(Duration.zero);
    expect((results.last as Success<AnimalLocation?>).data?.lotName, 'Renombrado');
    expect(results, hasLength(2));
  });

  test('no expone ubicaciones de otro establecimiento ni animales ausentes', () async {
    final otherTenant = await repository.watchLocation('a1', establishmentId: 'e2').first;
    expect((otherTenant as Success<AnimalLocation?>).data, isNull);
    expect(lots.calls, 0);
    animals.animal = null;
    final absent = await repository.watchLocation('a1', establishmentId: 'e1').first;
    expect((absent as Success<AnimalLocation?>).data, isNull);
  });

  test('una falla local se informa y la siguiente invalidación recupera la ubicación', () async {
    animals.fail = true;
    final results = <Result<AnimalLocation?>>[];
    final subscription = repository.watchLocation('a1', establishmentId: 'e1').listen(results.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);
    expect(results.single, isA<Failure<AnimalLocation?>>());
    animals.fail = false;
    changes.add(BrickAnimalModel);
    await Future<void>.delayed(Duration.zero);
    expect((results.last as Success<AnimalLocation?>).data?.animalId, 'a1');
  });

  test('500 cambios durante una consulta producen dos lecturas y solo el último resultado', () async {
    final pending = Completer<BrickAnimalModel?>();
    animals.pending = pending.future;
    final results = <Result<AnimalLocation?>>[];
    final subscription = repository.watchLocation('a1', establishmentId: 'e1').listen(results.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 500; i++) {
      changes.add(BrickAnimalModel);
    }
    await Future<void>.delayed(Duration.zero);
    expect(animals.calls, 1);
    animals
      ..pending = null
      ..animal = _animal.copyWith(lotId: 'final');
    pending.complete(_animal);
    await Future<void>.delayed(Duration.zero);
    expect(animals.calls, 2);
    expect((results.single as Success<AnimalLocation?>).data?.lotId, 'final');
  });

  test('cancelar libera la escucha y descarta la consulta pendiente', () async {
    final pending = Completer<BrickAnimalModel?>();
    animals.pending = pending.future;
    final results = <Result<AnimalLocation?>>[];
    final subscription = repository.watchLocation('a1', establishmentId: 'e1').listen(results.add);
    await Future<void>.delayed(Duration.zero);
    expect(changes.hasListener, isTrue);
    await subscription.cancel();
    expect(changes.hasListener, isFalse);
    pending.complete(_animal);
    changes.add(BrickAnimalModel);
    await Future<void>.delayed(Duration.zero);
    expect(results, isEmpty);
    expect(animals.calls, 1);
  });
}

class _AnimalStore extends Fake implements AnimalBrickStore {
  BrickAnimalModel? animal = _animal;
  Future<BrickAnimalModel?>? pending;
  bool fail = false;
  int calls = 0;

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async {
    calls++;
    if (fail) throw StateError('SQLite unavailable');
    return pending ?? animal;
  }
}

class _LotStore extends Fake implements LotBrickStore {
  String name = 'Origen';
  int calls = 0;

  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId, {bool includeDeleted = false}) async {
    calls++;
    return [
      BrickLotModel(
        localId: 'origin',
        establishmentId: 'e1',
        name: name,
        boundaryJson: '{}',
        surfaceTenths: 10,
        hasWater: true,
        statusCode: 'activo',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ];
  }
}

final _animal = BrickAnimalModel(
  localId: 'a1',
  establishmentId: 'e1',
  rfidTagNumber: '982000412884005',
  visualTag: '001',
  sex: BrickAnimalSex.female,
  breed: 'Angus',
  birthDate: DateTime.utc(2025),
  categoryId: 'category',
  lotId: 'origin',
  initialWeight: 300,
  weighingMethod: BrickAnimalWeighingMethod.manual,
  weighingDate: DateTime.utc(2026),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

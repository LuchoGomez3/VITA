import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/data/repositories/animal_movement_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';

void main() {
  AnimalMovementRepositoryImpl repository({
    List<BrickAnimalModel>? animals,
    List<BrickAnimalLotMovementModel> movements = const [],
  }) => AnimalMovementRepositoryImpl(
    animalStore: _FakeAnimalStore(animals ?? _animals),
    lotStore: _FakeLotStore(),
    categoryStore: _FakeCategoryStore(),
    movementStore: _FakeMovementStore(movements),
  );

  T data<T>(Result<T> result) => (result as Success<T>).data;

  group('findAnimalByTag', () {
    test('encuentra por RFID aunque venga con espacios', () async {
      final found = data(await repository().findAnimalByTag('982 000412 884 005'));

      expect(found?.id, 'a1');
      expect(found?.categoryName, 'Novillo');
      expect(found?.lotName, 'El Bajo');
    });

    test('encuentra por caravana visual sin importar los espacios', () async {
      expect(data(await repository().findAnimalByTag('0040028'))?.id, 'a1');
      expect(data(await repository().findAnimalByTag('004 0028'))?.id, 'a1');
    });

    test('no devuelve animales borrados, vendidos o sin potrero', () async {
      final subject = repository(
        animals: [
          _animal('borrado', visualTag: '1', deletedAt: DateTime.utc(2026)),
          _animal('vendido', visualTag: '2', status: BrickAnimalProductiveStatus.sold),
          _animal('sin-lote', visualTag: '3', lotId: ''),
        ],
      );

      for (final tag in ['1', '2', '3']) {
        expect(data(await subject.findAnimalByTag(tag)), isNull, reason: tag);
      }
    });
  });

  test('los destinos son los potreros activos con su cantidad de animales', () async {
    final destinations = data(await repository().getDestinations('campo-1'));

    expect(destinations.map((lot) => lot.name), ['El Bajo', 'La Cumbre']);
    expect(destinations.first.animalCount, 2);
    expect(destinations.last.animalCount, 0);
  });

  test('el historial trae solo los movimientos del animal, del más nuevo al más viejo', () async {
    final history = data(
      await repository(
        movements: [
          _movement('m1', ['a1', 'a2'], from: null, to: 'lote-bajo', on: DateTime.utc(2026, 3)),
          _movement('m2', ['a2'], from: 'lote-bajo', to: 'lote-cumbre', on: DateTime.utc(2026, 4)),
          _movement(
            'm3',
            ['a1'],
            from: 'lote-bajo',
            to: 'lote-cumbre',
            on: DateTime.utc(2026, 5),
            status: BrickAnimalLotMovementSyncStatus.synchronized,
          ),
        ],
      ).getHistory('a1'),
    );

    expect(history.map((entry) => entry.movementId), ['m3', 'm1']);
    expect(history.first.fromLotName, 'El Bajo');
    expect(history.first.toLotName, 'La Cumbre');
    expect(history.first.isPending, isFalse);
    expect(history.last.fromLotName, isNull);
    expect(history.last.isPending, isTrue);
  });

  test('un error de SQLite se informa con un mensaje entendible', () async {
    final subject = AnimalMovementRepositoryImpl(
      animalStore: _FakeAnimalStore(const [], fail: true),
      lotStore: _FakeLotStore(),
      categoryStore: _FakeCategoryStore(),
      movementStore: _FakeMovementStore(const []),
    );

    final result = await subject.findAnimalByTag('004 0028');

    expect(result, isA<Failure<MovementAnimal?>>());
  });
}

final _animals = [_animal('a1'), _animal('a2', visualTag: '004 0023', rfid: '982000412884920')];

BrickAnimalModel _animal(
  String id, {
  String visualTag = '004 0028',
  String rfid = '982000412884005',
  String lotId = 'lote-bajo',
  BrickAnimalProductiveStatus status = BrickAnimalProductiveStatus.active,
  DateTime? deletedAt,
}) => BrickAnimalModel(
  localId: id,
  rfidTagNumber: rfid,
  visualTag: visualTag,
  sex: BrickAnimalSex.male,
  breed: 'Hereford',
  birthDate: DateTime.utc(2024, 6, 12),
  categoryId: 'cat-novillo',
  lotId: lotId,
  establishmentId: 'campo-1',
  initialWeight: 300,
  weighingMethod: BrickAnimalWeighingMethod.manual,
  weighingDate: DateTime.utc(2026, 5),
  createdAt: DateTime.utc(2026, 5),
  updatedAt: DateTime.utc(2026, 5),
  deletedAt: deletedAt,
  productiveStatus: status,
);

BrickAnimalLotMovementModel _movement(
  String id,
  List<String> animalIds, {
  required String? from,
  required String to,
  required DateTime on,
  BrickAnimalLotMovementSyncStatus status = BrickAnimalLotMovementSyncStatus.pending,
}) => BrickAnimalLotMovementModel(
  localId: id,
  establishmentId: 'campo-1',
  sourceLotId: from,
  destinationLotId: to,
  animalIdsJson: jsonEncode(animalIds),
  occurredAt: on,
  reason: 'Rotación',
  createdAt: on,
  updatedAt: on,
  syncStatus: status,
);

class _FakeAnimalStore implements AnimalBrickStore {
  _FakeAnimalStore(this.animals, {this.fail = false});

  final List<BrickAnimalModel> animals;
  final bool fail;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async {
    if (fail) throw StateError('SQLite no disponible');
    return animals;
  }

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) async =>
      animals.where((animal) => animal.localId == animalId).firstOrNull;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeLotStore implements LotBrickStore {
  final _lots = [
    _lot('lote-cumbre', 'La Cumbre'),
    _lot('lote-bajo', 'El Bajo'),
    _lot('lote-cerrado', 'Clausurado', statusCode: 'inactivo'),
  ];

  static BrickLotModel _lot(String id, String name, {String statusCode = 'activo'}) => BrickLotModel(
    localId: id,
    establishmentId: 'campo-1',
    name: name,
    boundaryJson: '{}',
    surfaceTenths: 950,
    hasWater: false,
    statusCode: statusCode,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId) async => _lots;

  @override
  Future<BrickLotModel?> getLocalLot(String lotId) async => _lots.where((lot) => lot.localId == lotId).firstOrNull;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeCategoryStore implements CategoriaBrickStore {
  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias() async => [
    BrickCategoriaModel(
      localId: 'cat-novillo',
      name: 'Novillo',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeMovementStore implements AnimalLotMovementBrickStore {
  _FakeMovementStore(this.movements);

  final List<BrickAnimalLotMovementModel> movements;

  @override
  Future<List<BrickAnimalLotMovementModel>> getLocalMovements(String establishmentId) async => movements;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

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
import 'package:frontend_mayoral/features/animal_movement/domain/errors/movement_failure.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';

void main() {
  AnimalMovementRepositoryImpl repository({
    List<BrickAnimalModel>? animals,
    List<BrickLotModel>? lots,
    List<BrickAnimalLotMovementModel> movements = const [],
  }) => AnimalMovementRepositoryImpl(
    localChanges: const Stream.empty(),
    animalStore: _FakeAnimalStore(animals ?? _animals),
    lotStore: _FakeLotStore(lots: lots),
    categoryStore: _FakeCategoryStore(),
    movementStore: _FakeMovementStore(movements),
  );

  T data<T>(Result<T> result) => (result as Success<T>).data;

  group('findAnimalByTag', () {
    for (final unavailable in [
      _animal('unavailable', status: BrickAnimalProductiveStatus.sold),
      _animal('unavailable', lotId: ''),
      _animal('unavailable', deletedAt: DateTime.utc(2026)),
    ]) {
      for (final reverseOrder in [false, true]) {
        test(
          'un RFID no trasladable no se reinterpreta como visual: ${unavailable.productiveStatus}/${unavailable.lotId}/${unavailable.deletedAt}, invertido=$reverseOrder',
          () async {
            final animals = [
              unavailable,
              _animal('visual', visualTag: unavailable.rfidTagNumber, rfid: '982000000000002'),
            ];
            final subject = repository(animals: reverseOrder ? animals.reversed.toList() : animals);

            final result = await ResolveMovementTagUseCase(subject)(
              tag: unavailable.rfidTagNumber,
              establishmentId: 'campo-1',
              selectedIds: {},
            );

            expect(result, isA<Failure<MovementAnimal>>());
            expect((result as Failure<MovementAnimal>).error.reason, const MovementFailure.animalUnavailable());
          },
        );
      }
    }

    for (final reverseOrder in [false, true]) {
      test('prioriza RFID sobre visual coincidente, orden invertido=$reverseOrder', () async {
        final animals = [
          _animal('visual', visualTag: '982000412884005', rfid: '982000000000001'),
          _animal('electronic', visualTag: '002'),
        ];
        final subject = repository(animals: reverseOrder ? animals.reversed.toList() : animals);
        final found = data(await subject.findAnimalByTag('982 000412 884005', establishmentId: 'campo-1'));
        expect(found?.id, 'electronic');
      });
    }

    test('una visual de quince dígitos sigue siendo válida si no hay RFID coincidente', () async {
      final subject = repository(
        animals: [_animal('visual', visualTag: '982000412884005', rfid: '982000000000001')],
      );
      expect(data(await subject.findAnimalByTag('982000412884005', establishmentId: 'campo-1'))?.id, 'visual');
    });

    for (final rfid in [false, true]) {
      for (final reverseOrder in [false, true]) {
        test('no elige entre duplicados RFID=$rfid, orden invertido=$reverseOrder', () async {
          final animals = [
            _animal('a1'),
            _animal('a2', rfid: rfid ? '982000412884005' : '982000000000002'),
          ];
          final subject = repository(animals: reverseOrder ? animals.reversed.toList() : animals);
          final tag = rfid ? '982000412884005' : '0040028';
          final result = await ResolveMovementTagUseCase(subject)(
            tag: tag,
            establishmentId: 'campo-1',
            selectedIds: {},
          );
          expect(result, isA<Failure<MovementAnimal>>());
          expect((result as Failure<MovementAnimal>).error.reason, MovementFailure.ambiguousTag(tag));
        });
      }
    }

    test('los duplicados inactivos o ajenos no generan ambigüedad', () async {
      final subject = repository(
        animals: [
          _animal('ajeno', establishmentId: 'campo-2'),
          _animal('vendido', status: BrickAnimalProductiveStatus.sold),
          _animal('borrado', deletedAt: DateTime.utc(2026)),
          _animal('propio'),
        ],
      );
      for (final tag in ['982000412884005', '0040028']) {
        expect(data(await subject.findAnimalByTag(tag, establishmentId: 'campo-1'))?.id, 'propio');
      }
    });

    test('una caravana visual repetida en otro campo no oculta al animal propio', () async {
      final subject = repository(
        animals: [
          _animal('ajeno', establishmentId: 'campo-2'),
          _animal('propio'),
        ],
      );

      final found = data(await subject.findAnimalByTag('004 0028', establishmentId: 'campo-1'));

      expect(found?.id, 'propio');
      expect(data(await subject.findAnimalByTag('0040028', establishmentId: 'campo-3')), isNull);
    });

    test('un RFID de otro campo no se devuelve a la selección', () async {
      final subject = repository(animals: [_animal('ajeno', establishmentId: 'campo-2')]);

      expect(data(await subject.findAnimalByTag('982000412884005', establishmentId: 'campo-1')), isNull);
    });

    test('encuentra por RFID aunque venga con espacios', () async {
      final found = data(await repository().findAnimalByTag('982 000412 884 005', establishmentId: 'campo-1'));

      expect(found?.id, 'a1');
      expect(found?.categoryName, 'Novillo');
      expect(found?.lotName, 'El Bajo');
    });

    test('encuentra por caravana visual sin importar los espacios', () async {
      expect(data(await repository().findAnimalByTag('0040028', establishmentId: 'campo-1'))?.id, 'a1');
      expect(data(await repository().findAnimalByTag('004 0028', establishmentId: 'campo-1'))?.id, 'a1');
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
        expect(data(await subject.findAnimalByTag(tag, establishmentId: 'campo-1')), isNull, reason: tag);
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
    expect(history.first.syncStatus, MovementSyncStatus.synchronized);
    expect(history.last.fromLotName, isNull);
    expect(history.last.syncStatus, MovementSyncStatus.pending);
  });

  test('un error de SQLite se informa con un mensaje entendible', () async {
    final subject = AnimalMovementRepositoryImpl(
      localChanges: const Stream.empty(),
      animalStore: _FakeAnimalStore(const [], fail: true),
      lotStore: _FakeLotStore(),
      categoryStore: _FakeCategoryStore(),
      movementStore: _FakeMovementStore(const []),
    );

    final result = await subject.findAnimalByTag('004 0028', establishmentId: 'campo-1');

    expect(result, isA<Failure<MovementAnimal?>>());
  });

  test('un movimiento rechazado conserva su estado y no se convierte en pendiente', () async {
    final history = data(
      await repository(
        movements: [
          _movement(
            'rechazado',
            ['a1'],
            from: 'lote-bajo',
            to: 'lote-cumbre',
            on: DateTime.utc(2026, 6),
            status: BrickAnimalLotMovementSyncStatus.rejected,
          ),
        ],
      ).getHistory('a1'),
    );

    expect(history.single.syncStatus, MovementSyncStatus.rejected);
  });

  test('borrar un potrero vacío conserva su nombre en el historial y lo quita de destinos', () async {
    final subject = repository(
      animals: [_animal('a1', lotId: 'lote-cumbre')],
      lots: [
        _FakeLotStore._lot('lote-bajo', 'Origen eliminado', deletedAt: DateTime.utc(2026, 7)),
        _FakeLotStore._lot('lote-cumbre', 'Destino'),
      ],
      movements: [
        _movement('m1', ['a1'], from: 'lote-bajo', to: 'lote-cumbre', on: DateTime.utc(2026, 6)),
      ],
    );

    final history = data(await subject.getHistory('a1'));
    final destinations = data(await subject.getDestinations('campo-1'));

    expect(history.single.fromLotName, 'Origen eliminado');
    expect(history.single.toLotName, 'Destino');
    expect(destinations.map((lot) => lot.id), ['lote-cumbre']);
  });

  test('una fecha retroactiva no hace que el potrero actual sea el primero del historial', () async {
    final history = data(
      await repository(
        animals: [_animal('a1', lotId: 'lote-cumbre')],
        movements: [
          _movement('previo', ['a1'], from: 'lote-cumbre', to: 'lote-bajo', on: DateTime.utc(2026, 5)),
          _movement(
            'retroactivo',
            ['a1'],
            from: 'lote-bajo',
            to: 'lote-cumbre',
            on: DateTime.utc(2026, 4),
            createdAt: DateTime.utc(2026, 6),
          ),
          _movement(
            'rechazado',
            ['a1'],
            from: 'lote-cumbre',
            to: 'lote-bajo',
            on: DateTime.utc(2026, 7),
            status: BrickAnimalLotMovementSyncStatus.rejected,
          ),
        ],
      ).getHistory('a1'),
    );

    expect(history.map((entry) => entry.movementId), ['rechazado', 'previo', 'retroactivo']);
    expect(history.where((entry) => entry.isCurrent).single.movementId, 'retroactivo');
    expect(history.last.toLotName, 'La Cumbre');
  });

  test('múltiples visitas al mismo potrero marcan solo la última llegada registrada', () async {
    final history = data(
      await repository(
        movements: [
          _movement('viejo', ['a1'], from: null, to: 'lote-bajo', on: DateTime.utc(2026, 5)),
          _movement(
            'actual',
            ['a1'],
            from: 'lote-cumbre',
            to: 'lote-bajo',
            on: DateTime.utc(2026, 4),
            createdAt: DateTime.utc(2026, 6),
          ),
        ],
      ).getHistory('a1'),
    );

    expect(history.where((entry) => entry.isCurrent).single.movementId, 'actual');
  });
}

final List<BrickAnimalModel> _animals = [_animal('a1'), _animal('a2', visualTag: '004 0023', rfid: '982000412884920')];

BrickAnimalModel _animal(
  String id, {
  String visualTag = '004 0028',
  String rfid = '982000412884005',
  String lotId = 'lote-bajo',
  String establishmentId = 'campo-1',
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
  establishmentId: establishmentId,
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
  DateTime? createdAt,
  BrickAnimalLotMovementSyncStatus status = BrickAnimalLotMovementSyncStatus.pending,
}) => BrickAnimalLotMovementModel(
  localId: id,
  establishmentId: 'campo-1',
  sourceLotId: from,
  destinationLotId: to,
  animalIdsJson: jsonEncode(animalIds),
  occurredAt: on,
  reason: 'Rotación',
  createdAt: createdAt ?? on,
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
  _FakeLotStore({List<BrickLotModel>? lots})
    : _lots =
          lots ??
          [
            _lot('lote-cumbre', 'La Cumbre'),
            _lot('lote-bajo', 'El Bajo'),
            _lot('lote-cerrado', 'Clausurado', statusCode: 'inactivo'),
          ];
  final List<BrickLotModel> _lots;

  static BrickLotModel _lot(String id, String name, {String statusCode = 'activo', DateTime? deletedAt}) =>
      BrickLotModel(
        localId: id,
        establishmentId: 'campo-1',
        name: name,
        boundaryJson: '{}',
        surfaceTenths: 950,
        hasWater: false,
        statusCode: statusCode,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        deletedAt: deletedAt,
      );

  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId, {bool includeDeleted = false}) async => _lots
      .where((lot) => lot.establishmentId == establishmentId && (includeDeleted || lot.deletedAt == null))
      .toList();

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

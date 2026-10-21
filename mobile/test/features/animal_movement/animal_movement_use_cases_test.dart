import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_animal_movement.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/move_lot_animals_use_case.dart';

void main() {
  group('RegisterGroupMovementUseCase', () {
    test('arma un movimiento por potrero de origen y saltea los que ya están en el destino', () async {
      final move = _FakeMove();

      final result = await RegisterGroupMovementUseCase(move)(
        establishmentId: 'campo-1',
        animals: [
          _animal('a1', lotId: 'bajo'),
          _animal('a2', lotId: 'sauces'),
          _animal('a3', lotId: 'bajo'),
          _animal('a4', lotId: 'cumbre'),
        ],
        destinationLotId: 'cumbre',
        occurredAt: DateTime.utc(2026, 10, 20),
        reason: 'Rotación',
      );

      final summary = (result as Success<GroupMovementSummary>).data;
      expect(summary.movedCount, 3);
      expect(summary.alreadyThereCount, 1);
      expect(move.calls, {
        'bajo': ['a1', 'a3'],
        'sauces': ['a2'],
      });
    });

    test('si todos ya están en el destino no registra nada', () async {
      final move = _FakeMove();

      final result = await RegisterGroupMovementUseCase(move)(
        establishmentId: 'campo-1',
        animals: [_animal('a1', lotId: 'cumbre')],
        destinationLotId: 'cumbre',
        occurredAt: DateTime.utc(2026, 10, 20),
        reason: 'Rotación',
      );

      expect(result, isA<Failure<GroupMovementSummary>>());
      expect(move.calls, isEmpty);
    });

    test('exige el motivo', () async {
      final result = await RegisterGroupMovementUseCase(_FakeMove())(
        establishmentId: 'campo-1',
        animals: [_animal('a1', lotId: 'bajo')],
        destinationLotId: 'cumbre',
        occurredAt: DateTime.utc(2026, 10, 20),
        reason: '  ',
      );

      expect((result as Failure<GroupMovementSummary>).error.code, DomainErrorCode.validation);
    });

    test('si falla un grupo después de otro avisa cuántos se movieron', () async {
      final move = _FakeMove(failOn: 'sauces');

      final result = await RegisterGroupMovementUseCase(move)(
        establishmentId: 'campo-1',
        animals: [
          _animal('a1', lotId: 'bajo'),
          _animal('a2', lotId: 'sauces'),
        ],
        destinationLotId: 'cumbre',
        occurredAt: DateTime.utc(2026, 10, 20),
        reason: 'Rotación',
      );

      expect((result as Failure<GroupMovementSummary>).error.message, startsWith('Se movieron 1 animales'));
    });
  });

  group('ResolveMovementTagUseCase', () {
    Future<Result<MovementAnimal>> resolve(String tag, {Set<String> selected = const {}}) =>
        ResolveMovementTagUseCase(_FakeRepository())(tag: tag, establishmentId: 'campo-1', selectedIds: selected);

    test('agrega un animal activo del mismo campo', () async {
      expect(((await resolve('004 0028')) as Success<MovementAnimal>).data.id, 'a1');
    });

    test('rechaza caravanas desconocidas, de otro campo o repetidas', () async {
      expect(((await resolve('999')) as Failure).error.code, DomainErrorCode.notFound);
      expect(((await resolve('otro')) as Failure).error.code, DomainErrorCode.validation);
      expect(((await resolve('004 0028', selected: {'a1'})) as Failure).error.code, DomainErrorCode.conflict);
      expect(((await resolve('   ')) as Failure).error.code, DomainErrorCode.validation);
    });
  });
}

MovementAnimal _animal(String id, {required String lotId, String establishmentId = 'campo-1'}) => MovementAnimal(
  id: id,
  establishmentId: establishmentId,
  visualTag: '004 0028',
  rfidTagNumber: '982000412884005',
  breed: 'Hereford',
  categoryName: 'Novillo',
  lotId: lotId,
  lotName: lotId,
);

class _FakeRepository implements AnimalMovementRepository {
  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(String tag) async => Result.success(switch (tag) {
    '004 0028' => _animal('a1', lotId: 'bajo'),
    'otro' => _animal('b1', lotId: 'x', establishmentId: 'campo-2'),
    _ => null,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeMove implements MoveLotAnimalsUseCase {
  _FakeMove({this.failOn});

  final String? failOn;
  final calls = <String, List<String>>{};

  @override
  Future<Result<LotAnimalMovement>> call({
    required String establishmentId,
    required String sourceLotId,
    required String destinationLotId,
    required List<String> animalIds,
    required DateTime occurredAt,
    required String reason,
    String? responsibleId,
  }) async {
    if (sourceLotId == failOn) {
      return const Result.failure(DomainException(message: 'Uno de los animales ya no pertenece al lote de origen.'));
    }
    calls[sourceLotId] = animalIds;
    return Result.success(
      LotAnimalMovement(
        id: 'm-$sourceLotId',
        establishmentId: establishmentId,
        sourceLotId: sourceLotId,
        destinationLotId: destinationLotId,
        animalIds: animalIds,
        occurredAt: occurredAt,
        reason: reason,
        createdAt: occurredAt,
        updatedAt: occurredAt,
      ),
    );
  }
}

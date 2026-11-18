import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_tag_kind.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/errors/movement_failure.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/quick_read/data/repositories/quick_read_repository_impl.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';
import 'package:frontend_mayoral/features/quick_read/domain/use_cases/quick_read_use_cases.dart';

void main() {
  const rfid = '982000412884005';

  QuickReadRepositoryImpl build(_MovementRepository movements) => QuickReadRepositoryImpl(
    movementRepository: movements,
    animalStore: _AnimalStore(),
    pesajeStore: _PesajeStore(),
    establishmentCatalog: _Catalog(),
  );

  test('un RFID registrado que no se puede mover no corta la búsqueda en los demás campos', () async {
    final movements = _MovementRepository(
      failIn: 'e1',
      failure: movementException(const MovementFailure.animalUnavailable()),
    );

    final result = await build(movements).findByTag(rfid);

    expect(movements.establishments, ['e1', 'e2']);
    expect((result as Success<List<QuickReadAnimal>>).data, isEmpty);
  });

  test('la lectura rápida explica que el RFID ya está registrado pero no está activo', () async {
    final movements = _MovementRepository(
      failIn: 'e1',
      failure: movementException(const MovementFailure.animalUnavailable()),
    );

    final result = await ResolveQuickReadTagUseCase(build(movements))(
      tag: rfid,
      establishmentId: null,
      items: const [],
    );

    final error = (result as Failure<QuickReadItem>).error;
    expect(error.message, 'La caravana $rfid ya está registrada, pero el animal no está activo o no tiene potrero.');
  });

  test('otros errores de búsqueda se siguen informando', () async {
    final movements = _MovementRepository(
      failIn: 'e1',
      failure: movementException(const MovementFailure.localRead(MovementReadTarget.tag)),
    );

    final result = await build(movements).findByTag(rfid);

    expect(result, isA<Failure<List<QuickReadAnimal>>>());
    expect(movements.establishments, ['e1']);
  });
}

class _MovementRepository extends Fake implements AnimalMovementRepository {
  _MovementRepository({required this.failIn, required this.failure});

  final String failIn;
  final DomainException failure;
  final establishments = <String>[];

  @override
  Future<Result<MovementAnimal?>> findAnimalByTag(
    String tag, {
    required String establishmentId,
    required MovementTagKind kind,
  }) async {
    establishments.add(establishmentId);
    return establishmentId == failIn ? Result.failure(failure) : const Result.success(null);
  }
}

class _Catalog extends Fake implements EstablishmentCatalog {
  @override
  Future<List<EstablishmentMembership>> getMemberships() async => const [
    EstablishmentMembership(id: 'e1', name: 'La Esperanza', role: UserRole.owner),
    EstablishmentMembership(id: 'e2', name: 'El Bajo', role: UserRole.owner),
  ];
}

class _AnimalStore extends Fake implements AnimalBrickStore {
  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async => [
    BrickAnimalModel(
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
    ),
  ];
}

class _PesajeStore extends Fake implements PesajeBrickStore {}

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/animal_list_repository.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_animal_list_use_case.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/animal_list_cubit.dart';

void main() {
  AnimalListCubit cubit(List<EstablishmentMembership> establishments) {
    final repository = _FakeRepository(establishments);
    return AnimalListCubit(
      getAnimalListUseCase: GetAnimalListUseCase(repository),
      getEstablishmentsUseCase: GetAnimalListEstablishmentsUseCase(repository),
    );
  }

  test('with a single establishment, it is selected and only its animals are listed', () async {
    final subject = cubit([_sirena]);
    addTearDown(subject.close);

    await subject.load();

    expect(subject.state.establishmentId, 'sirena');
    expect(subject.state.allAnimals.map((animal) => animal.visualTag), ['003 1284', '004 0028']);
  });

  test('with several establishments it starts on "all" and can filter by one', () async {
    final subject = cubit([_sirena, _ombu]);
    addTearDown(subject.close);
    await subject.load();

    expect(subject.state.establishmentId, isNull);
    expect(subject.state.allAnimals, hasLength(3));

    subject.selectEstablishment('ombu');

    expect(subject.state.visibleAnimals.map((animal) => animal.visualTag), ['005 0772']);
    expect(subject.state.categories, ['Ternero']);
  });

  test('changing establishment clears a category that may not exist there', () async {
    final subject = cubit([_sirena, _ombu]);
    addTearDown(subject.close);
    await subject.load();
    subject.selectCategory('Vaca');

    subject.selectEstablishment('ombu');

    expect(subject.state.category, isNull);
    expect(subject.state.visibleAnimals, hasLength(1));
  });

  test('filters by category and by tag, RFID or breed, ignoring spaces and case', () async {
    final subject = cubit([_sirena]);
    addTearDown(subject.close);
    await subject.load();

    subject.selectCategory('Vaca');
    expect(subject.state.visibleAnimals.map((animal) => animal.visualTag), ['003 1284']);

    subject
      ..selectCategory(null)
      ..search('0040028');
    expect(subject.state.visibleAnimals.map((animal) => animal.visualTag), ['004 0028']);

    subject.search('HEREFORD');
    expect(subject.state.visibleAnimals.map((animal) => animal.visualTag), ['004 0028']);

    subject.search('982000412884712');
    expect(subject.state.visibleAnimals.map((animal) => animal.visualTag), ['003 1284']);
  });
}

const _sirena = EstablishmentMembership(id: 'sirena', name: 'La Sirena', role: UserRole.owner);
const _ombu = EstablishmentMembership(id: 'ombu', name: 'El Ombú', role: UserRole.owner);

const _animals = [
  AnimalListEntry(
    id: 'a1',
    establishmentId: 'sirena',
    visualTag: '003 1284',
    rfidTagNumber: '982000412884712',
    breed: 'Aberdeen Angus',
    categoryName: 'Vaca',
    lotName: 'La Cumbre',
  ),
  AnimalListEntry(
    id: 'a2',
    establishmentId: 'sirena',
    visualTag: '004 0028',
    rfidTagNumber: '982000412884005',
    breed: 'Hereford',
    categoryName: 'Novillo',
    lotName: 'El Bajo',
  ),
  AnimalListEntry(
    id: 'a3',
    establishmentId: 'ombu',
    visualTag: '005 0772',
    rfidTagNumber: '982000412922110',
    breed: 'Brangus',
    categoryName: 'Ternero',
    lotName: 'Los Sauces',
  ),
];

class _FakeRepository implements AnimalListRepository {
  _FakeRepository(this.establishments);

  final List<EstablishmentMembership> establishments;

  @override
  Future<Result<List<AnimalListEntry>>> getAnimals() async => const Result.success(_animals);

  @override
  Future<Result<List<EstablishmentMembership>>> getEstablishments() async => Result.success(establishments);
}

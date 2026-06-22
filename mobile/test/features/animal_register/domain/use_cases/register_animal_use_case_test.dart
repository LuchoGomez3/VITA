import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_repository.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/register_animal_use_case.dart';

void main() {
  test('delegates the registration to the repository', () async {
    final repository = _FakeAnimalRegistrationRepository();
    final useCase = RegisterAnimalUseCase(repository);
    final registration = AnimalRegistration(
      rfidTagNumber: '982000412991416',
      sex: AnimalSex.female,
      breed: 'Aberdeen Angus',
      birthDate: DateTime(2025, 3, 14),
      lotId: 'lot-id',
      establishmentId: 'establishment-id',
      initialWeight: 32.5,
    );

    final result = await useCase(registration);

    expect(repository.receivedRegistration, registration);
    expect(
      result,
      Result<RegisteredAnimal>.success(
        RegisteredAnimal(
          id: 'local-animal-id',
          registration: registration,
          syncStatus: AnimalSyncStatus.pending,
        ),
      ),
    );
  });
}

class _FakeAnimalRegistrationRepository implements AnimalRegistrationRepository {
  AnimalRegistration? receivedRegistration;

  @override
  Future<Result<RegisteredAnimal>> register(
    AnimalRegistration registration,
  ) async {
    receivedRegistration = registration;
    return Result.success(
      RegisteredAnimal(
        id: 'local-animal-id',
        registration: registration,
        syncStatus: AnimalSyncStatus.pending,
      ),
    );
  }
}

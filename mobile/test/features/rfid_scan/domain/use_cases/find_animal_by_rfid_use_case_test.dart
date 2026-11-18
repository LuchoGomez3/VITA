import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/validators/rfid_validator.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_animal_lookup_repository.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/find_animal_by_rfid_use_case.dart';

void main() {
  for (final invalid in ['98200041299141', '9820004129914160', 'A982000412991416', '982 000412991416']) {
    test('no consulta el repositorio con un RFID inválido: $invalid', () async {
      final repository = _FakeRfidAnimalLookupRepository();
      final result = await FindAnimalByRfidUseCase(repository)(rfidTagNumber: invalid, establishmentId: 'e1');
      expect((result as Failure<IdentifiedAnimal?>).error.reason, RfidValidationFailure.invalidFormat);
      expect(repository.rfidTagNumber, isNull);
    });
  }
  test('delegates the RFID and establishment to the repository', () async {
    final repository = _FakeRfidAnimalLookupRepository();
    final useCase = FindAnimalByRfidUseCase(repository);

    await useCase(
      rfidTagNumber: '982000412991416',
      establishmentId: 'establishment-id',
    );

    expect(repository.rfidTagNumber, '982000412991416');
    expect(repository.establishmentId, 'establishment-id');
  });
}

class _FakeRfidAnimalLookupRepository implements RfidAnimalLookupRepository {
  String? rfidTagNumber;
  String? establishmentId;

  @override
  Future<Result<IdentifiedAnimal?>> findByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async {
    this.rfidTagNumber = rfidTagNumber;
    this.establishmentId = establishmentId;
    return const Result.success(null);
  }
}

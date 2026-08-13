import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_animal_lookup_repository.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/find_animal_by_rfid_use_case.dart';

void main() {
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

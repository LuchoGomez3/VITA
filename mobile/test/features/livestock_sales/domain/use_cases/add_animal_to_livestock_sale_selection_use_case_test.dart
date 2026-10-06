import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_animal_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/add_animal_to_livestock_sale_selection_use_case.dart';

void main() {
  const rfid = '982000412991416';
  const establishmentId = 'establishment-id';
  late _FakeLivestockSaleAnimalRepository repository;
  late AddAnimalToLivestockSaleSelectionUseCase useCase;

  setUp(() {
    repository = _FakeLivestockSaleAnimalRepository();
    useCase = AddAnimalToLivestockSaleSelectionUseCase(
      repository: repository,
    );
  });

  test('adds an active local animal preserving selection order', () async {
    repository.result = const Result.success(_activeAnimal);
    const previousAnimal = LivestockSaleAnimal(
      id: 'previous-id',
      establishmentId: establishmentId,
      rfidTagNumber: '982000412991415',
      visualTag: '001',
      categoryName: 'Novillo',
      lotName: 'Norte',
      status: LivestockSaleAnimalStatus.active,
    );

    final result = await useCase(
      rfidTagNumber: rfid,
      establishmentId: establishmentId,
      selection: const LivestockSaleSelection(animals: [previousAnimal]),
    );

    expect(result, isA<Success<LivestockSaleSelection>>());
    final selection = (result as Success<LivestockSaleSelection>).data;
    expect(selection.animals.map((animal) => animal.id), [
      'previous-id',
      'animal-id',
    ]);
  });

  test('rejects an invalid RFID without reading the local store', () async {
    final result = await useCase(
      rfidTagNumber: 'invalid',
      establishmentId: establishmentId,
      selection: const LivestockSaleSelection(),
    );

    _expectReason(result, LivestockSaleSelectionError.invalidRfid);
    expect(repository.calls, 0);
  });

  test('rejects a missing animal', () async {
    repository.result = const Result.success(null);

    final result = await useCase(
      rfidTagNumber: rfid,
      establishmentId: establishmentId,
      selection: const LivestockSaleSelection(),
    );

    _expectReason(result, LivestockSaleSelectionError.animalNotFound);
  });

  test('rejects an animal from another establishment', () async {
    repository.result = const Result.success(
      LivestockSaleAnimal(
        id: 'animal-id',
        establishmentId: 'other-establishment',
        rfidTagNumber: rfid,
        visualTag: '002',
        categoryName: 'Novillo',
        lotName: 'Sur',
        status: LivestockSaleAnimalStatus.active,
      ),
    );

    final result = await useCase(
      rfidTagNumber: rfid,
      establishmentId: establishmentId,
      selection: const LivestockSaleSelection(),
    );

    _expectReason(result, LivestockSaleSelectionError.differentEstablishment);
  });

  for (final entry in {
    LivestockSaleAnimalStatus.sold: LivestockSaleSelectionError.animalSold,
    LivestockSaleAnimalStatus.dead: LivestockSaleSelectionError.animalDead,
    LivestockSaleAnimalStatus.removed: LivestockSaleSelectionError.animalRemoved,
    LivestockSaleAnimalStatus.unknown: LivestockSaleSelectionError.animalStatusUnknown,
  }.entries) {
    test('rejects an animal with ${entry.key.name} status', () async {
      repository.result = Result.success(_activeAnimal.copyWith(status: entry.key));

      final result = await useCase(
        rfidTagNumber: rfid,
        establishmentId: establishmentId,
        selection: const LivestockSaleSelection(),
      );

      _expectReason(result, entry.value);
    });
  }

  test('rejects an animal already present in the selection', () async {
    repository.result = const Result.success(_activeAnimal);

    final result = await useCase(
      rfidTagNumber: rfid,
      establishmentId: establishmentId,
      selection: const LivestockSaleSelection(animals: [_activeAnimal]),
    );

    _expectReason(result, LivestockSaleSelectionError.duplicateAnimal);
  });

  test('preserves a local repository failure', () async {
    const reason = LivestockSaleSelectionError.localRead;
    repository.result = const Result.failure(
      DomainException(
        message: 'localRead',
        code: DomainErrorCode.offline,
        reason: reason,
      ),
    );

    final result = await useCase(
      rfidTagNumber: rfid,
      establishmentId: establishmentId,
      selection: const LivestockSaleSelection(),
    );

    _expectReason(result, reason);
  });
}

const _activeAnimal = LivestockSaleAnimal(
  id: 'animal-id',
  establishmentId: 'establishment-id',
  rfidTagNumber: '982000412991416',
  visualTag: '002',
  categoryName: 'Novillo',
  lotName: 'Sur',
  status: LivestockSaleAnimalStatus.active,
);

void _expectReason(
  Result<LivestockSaleSelection> result,
  LivestockSaleSelectionError reason,
) {
  expect(result, isA<Failure<LivestockSaleSelection>>());
  final error = (result as Failure<LivestockSaleSelection>).error;
  expect(error.reason, reason);
}

class _FakeLivestockSaleAnimalRepository implements LivestockSaleAnimalRepository {
  Result<LivestockSaleAnimal?> result = const Result.success(null);
  int calls = 0;

  @override
  Future<Result<List<LivestockSaleAnimal>>> findLocalByRfidPrefix(
    String prefix,
  ) async => const Result.success([]);

  @override
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  ) async {
    calls++;
    return result;
  }
}

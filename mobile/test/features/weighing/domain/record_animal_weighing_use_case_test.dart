import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/weighing/domain/entities/animal_weighing.dart';
import 'package:frontend_mayoral/features/weighing/domain/repositories/weighing_repository.dart';
import 'package:frontend_mayoral/features/weighing/domain/use_cases/record_animal_weighing_use_case.dart';

void main() {
  late _FakeWeighingRepository repository;
  late RecordAnimalWeighingUseCase useCase;

  setUp(() {
    repository = _FakeWeighingRepository();
    useCase = RecordAnimalWeighingUseCase(
      repository: repository,
      createId: () => 'pesaje-1',
      now: () => DateTime.utc(2026, 10, 14, 13),
    );
  });

  Future<Result<AnimalWeighing>> record(double weightKg) => useCase(
    establishmentId: 'campo-1',
    animalId: 'animal-1',
    weightKg: weightKg,
    source: AnimalWeighingSource.manual,
  );

  test('saves the weighing with a client id and the current time', () async {
    final result = await record(371.5);

    expect(result, isA<Success<AnimalWeighing>>());
    final saved = repository.saved.single;
    expect(saved.id, 'pesaje-1');
    expect(saved.establishmentId, 'campo-1');
    expect(saved.animalId, 'animal-1');
    expect(saved.weightKg, 371.5);
    expect(saved.date, DateTime.utc(2026, 10, 14, 13));
    expect(saved.source, AnimalWeighingSource.manual);
  });

  test('accepts a weight lower than the previous one (a loss is valid data)', () async {
    expect(await record(120), isA<Success<AnimalWeighing>>());
  });

  for (final weight in [0.0, -5.0, 2000.5]) {
    test('rejects $weight kg without saving', () async {
      final result = await record(weight);

      expect(
        result,
        isA<Failure<AnimalWeighing>>().having((f) => f.error.code, 'code', DomainErrorCode.validation),
      );
      expect(repository.saved, isEmpty);
    });
  }
}

class _FakeWeighingRepository implements WeighingRepository {
  final saved = <AnimalWeighing>[];

  @override
  Future<Result<AnimalWeighing>> save(AnimalWeighing weighing) async {
    saved.add(weighing);
    return Result.success(weighing);
  }
}

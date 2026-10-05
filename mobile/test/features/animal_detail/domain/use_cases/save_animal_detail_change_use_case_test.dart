import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/save_animal_detail_change_use_case.dart';
import '../../animal_detail_fixture.dart';

void main() {
  final detail = animalDetailFixture();
  final date = DateTime.utc(2026);
  test('rejects non-positive and non-finite weights before persistence', () async {
    final repository = MemoryAnimalDetailRepository();
    for (final weight in [0.0, -1.0, double.nan, double.infinity]) {
      final result = await SaveAnimalDetailChangeUseCase(repository)(
        detail.id,
        AnimalDetailChange.weight(weightKg: weight, date: date),
      );
      expect(result, isA<Failure<Object>>());
    }
    expect(repository.changes, isEmpty);
  });
  test('enforces sex and preserves known pregnancy on category changes', () {
    expect(
      SaveAnimalDetailChangeUseCase.validate(detail, const AnimalDetailChange.category(categoryId: 'bull')),
      AnimalDetailEditFailure.incompatibleCategory,
    );
    expect(
      SaveAnimalDetailChangeUseCase.validate(
        detail.copyWith(reproductiveStatus: AnimalReproductiveStatus.pregnant),
        const AnimalDetailChange.category(categoryId: 'calf'),
      ),
      AnimalDetailEditFailure.reproductionNotAllowed,
    );
    expect(
      SaveAnimalDetailChangeUseCase.validate(
        detail.copyWith(sex: AnimalSex.male),
        const AnimalDetailChange.reproduction(status: AnimalReproductiveStatus.pregnant),
      ),
      AnimalDetailEditFailure.reproductionNotAllowed,
    );
    expect(
      SaveAnimalDetailChangeUseCase.validate(
        detail.copyWith(categoryId: 'calf'),
        const AnimalDetailChange.reproduction(status: AnimalReproductiveStatus.undetermined),
      ),
      isNull,
    );
  });
  test('rejects blank notes and accepts observations on a dead animal', () {
    expect(
      SaveAnimalDetailChangeUseCase.validate(detail, AnimalDetailChange.observation(text: '  ', date: date)),
      AnimalDetailEditFailure.emptyObservation,
    );
    expect(
      SaveAnimalDetailChangeUseCase.validate(
        detail.copyWith(status: AnimalStatus.dead),
        AnimalDetailChange.observation(text: 'Revisión', date: date),
      ),
      isNull,
    );
  });
  test('undo requires the exact death version', () {
    final change = AnimalDetailChange.undoDeath(previousStatus: AnimalStatus.active, deathUpdatedAt: date);
    expect(SaveAnimalDetailChangeUseCase.validate(detail.copyWith(status: AnimalStatus.dead), change), isNull);
    expect(
      SaveAnimalDetailChangeUseCase.validate(
        detail.copyWith(status: AnimalStatus.dead, updatedAt: date.add(const Duration(seconds: 1))),
        change,
      ),
      AnimalDetailEditFailure.staleUndo,
    );
  });
}

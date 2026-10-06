import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_change.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_detail_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/save_animal_detail_change_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import '../../animal_detail_fixture.dart';

void main() {
  test('serializes duplicate taps and undo restores the previous status', () async {
    final repository = MemoryAnimalDetailRepository();
    final cubit = AnimalDetailCubit(
      getAnimalDetailUseCase: GetAnimalDetailUseCase(repository),
      saveChangeUseCase: SaveAnimalDetailChangeUseCase(repository),
    );
    addTearDown(cubit.close);
    await cubit.loadAnimalData(repository.detail.id);
    await Future.wait([cubit.save(const AnimalDetailChange.death()), cubit.save(const AnimalDetailChange.death())]);
    expect(repository.changes, hasLength(1));
    expect(repository.detail.status, AnimalStatus.dead);
    final deathVersion = repository.detail.updatedAt;
    await cubit.undoDeath();
    expect(repository.detail.status, AnimalStatus.active);
    expect(repository.detail.updatedAt.isAfter(deathVersion), isTrue);
    expect(cubit.state.undoStatus, isNull);
  });
  test('invalid edit preserves the displayed data', () async {
    final repository = MemoryAnimalDetailRepository();
    final cubit = AnimalDetailCubit(
      getAnimalDetailUseCase: GetAnimalDetailUseCase(repository),
      saveChangeUseCase: SaveAnimalDetailChangeUseCase(repository),
    );
    addTearDown(cubit.close);
    await cubit.loadAnimalData(repository.detail.id);
    await cubit.save(AnimalDetailChange.weight(weightKg: -1, date: DateTime.utc(2026)));
    expect(cubit.state.detail, isA<Data<AnimalDetail>>());
    expect(cubit.state.saving, isA<ResultError<AnimalDetail>>());
    expect(repository.changes, isEmpty);
  });
}

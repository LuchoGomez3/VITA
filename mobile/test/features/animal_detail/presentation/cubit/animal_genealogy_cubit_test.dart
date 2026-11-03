import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_genealogy_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_genealogy_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_genealogy_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';

void main() {
  late _PendingRepository repository;
  late AnimalGenealogyCubit cubit;

  setUp(() {
    repository = _PendingRepository();
    cubit = AnimalGenealogyCubit(GetAnimalGenealogyUseCase(repository));
    addTearDown(cubit.close);
  });

  test('emite initial, loading y data para la lectura local', () async {
    expect(cubit.state, const ResultState<AnimalGenealogy>.initial());
    final states = <ResultState<AnimalGenealogy>>[];
    final subscription = cubit.stream.listen(states.add);
    addTearDown(subscription.cancel);

    final load = cubit.load('sujeto');
    expect(cubit.state, const ResultState<AnimalGenealogy>.loading());
    repository.requests['sujeto']!.complete(const Result.success([]));
    await load;
    await Future<void>.delayed(Duration.zero);

    expect(states, [
      const ResultState<AnimalGenealogy>.loading(),
      const ResultState<AnimalGenealogy>.data(AnimalGenealogy()),
    ]);
  });

  test('convierte el error técnico a strings de producto y conserva su código', () async {
    final load = cubit.load('sujeto');
    repository.requests['sujeto']!.complete(
      const Result.failure(
        DomainException(message: 'animal_genealogy_read_failed', code: DomainErrorCode.notFound),
      ),
    );
    await load;

    expect(
      cubit.state,
      const ResultState<AnimalGenealogy>.error(
        DomainException(
          message: AnimalDetailStrings.genealogyLoadError,
          code: DomainErrorCode.notFound,
        ),
      ),
    );
  });

  test('una respuesta vieja no reemplaza la genealogía del nuevo animal', () async {
    final oldLoad = cubit.load('viejo');
    final newLoad = cubit.load('nuevo');
    repository.requests['nuevo']!.complete(
      Result.success([
        _record('nuevo', mother: 'madre-nueva'),
        _record('madre-nueva'),
      ]),
    );
    await newLoad;
    final current = cubit.state;
    expect((current as Data<AnimalGenealogy>).data.mother?.id, 'madre-nueva');

    repository.requests['viejo']!.complete(const Result.failure(DomainException(message: 'late_failure')));
    await oldLoad;
    expect(cubit.state, current);
  });

  test('no emite cuando se cierra durante una lectura pendiente', () async {
    final load = cubit.load('sujeto');
    await cubit.close();
    repository.requests['sujeto']!.complete(const Result.success([]));
    await expectLater(load, completes);
    expect(cubit.state, const ResultState<AnimalGenealogy>.loading());
  });

  test('no inicia lecturas después del cierre', () async {
    await cubit.close();
    await cubit.load('sujeto');
    expect(repository.requests, isEmpty);
  });
}

GenealogyAnimalRecord _record(String id, {String? mother}) => GenealogyAnimalRecord(
  animal: GenealogyAnimal(id: id, visualTag: id, breed: '', categoryName: ''),
  birthDate: DateTime.utc(2022),
  motherId: mother,
);

class _PendingRepository implements AnimalGenealogyRepository {
  final requests = <String, Completer<Result<List<GenealogyAnimalRecord>>>>{};

  @override
  Future<Result<List<GenealogyAnimalRecord>>> getLocalFamily(String animalId) {
    final request = Completer<Result<List<GenealogyAnimalRecord>>>();
    requests[animalId] = request;
    return request.future;
  }
}

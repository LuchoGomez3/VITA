import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_genealogy_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_genealogy_use_case.dart';

void main() {
  Future<AnimalGenealogy> genealogyOf(String id, List<GenealogyAnimalRecord> records) async {
    final result = await GetAnimalGenealogyUseCase(_FamilyRepository(Result.success(records)))(id);
    return (result as Success<AnimalGenealogy>).data;
  }

  test('construye ambas líneas hasta los abuelos sin infraestructura', () async {
    final genealogy = await genealogyOf('ternero', [
      _record('ternero', mother: 'vaca', father: 'toro'),
      _record('vaca', mother: 'abuela-m', father: 'abuelo-m'),
      _record('toro', mother: 'abuela-p', father: 'abuelo-p'),
      _record('abuela-m'),
      _record('abuelo-m'),
      _record('abuela-p'),
      _record('abuelo-p'),
    ]);

    expect(genealogy.mother?.id, 'vaca');
    expect(genealogy.father?.id, 'toro');
    expect(genealogy.maternalGrandmother?.id, 'abuela-m');
    expect(genealogy.maternalGrandfather?.id, 'abuelo-m');
    expect(genealogy.paternalGrandmother?.id, 'abuela-p');
    expect(genealogy.paternalGrandfather?.id, 'abuelo-p');
  });

  test('deja nulos los padres ausentes o que no estén disponibles localmente', () async {
    final genealogy = await genealogyOf('ternero', [_record('ternero', mother: 'sin-cache')]);
    expect(genealogy, const AnimalGenealogy());
  });

  test('un sujeto ausente devuelve un árbol vacío', () async {
    expect(await genealogyOf('ausente', [_record('otro')]), const AnimalGenealogy());
  });

  test('corta ciclos hacia el sujeto y hacia el progenitor de cada línea', () async {
    final genealogy = await genealogyOf('sujeto', [
      _record('sujeto', mother: 'madre', father: 'padre'),
      _record('madre', mother: 'sujeto', father: 'madre'),
      _record('padre', mother: 'padre', father: 'sujeto'),
    ]);
    expect(genealogy.mother?.id, 'madre');
    expect(genealogy.father?.id, 'padre');
    expect(genealogy.maternalGrandmother, isNull);
    expect(genealogy.maternalGrandfather, isNull);
    expect(genealogy.paternalGrandmother, isNull);
    expect(genealogy.paternalGrandfather, isNull);
  });

  test('el sujeto no puede ser su propio padre ni madre ni cría', () async {
    final genealogy = await genealogyOf('sujeto', [_record('sujeto', mother: 'sujeto', father: 'sujeto')]);
    expect(genealogy, const AnimalGenealogy());
  });

  test('permite abuelos compartidos entre líneas', () async {
    final genealogy = await genealogyOf('sujeto', [
      _record('sujeto', mother: 'madre', father: 'padre'),
      _record('madre', father: 'abuelo'),
      _record('padre', father: 'abuelo'),
      _record('abuelo'),
    ]);
    expect(genealogy.maternalGrandfather?.id, 'abuelo');
    expect(genealogy.paternalGrandfather?.id, 'abuelo');
  });

  test('ordena crías de ambos vínculos de la más nueva a la más vieja sin duplicar', () async {
    final genealogy = await genealogyOf('sujeto', [
      _record('sujeto'),
      _record('vieja', mother: 'sujeto', birthYear: 2024),
      _record('nueva', father: 'sujeto', birthYear: 2026),
      _record('intermedia', mother: 'sujeto', father: 'sujeto', birthYear: 2025),
      _record('sin-vinculo'),
    ]);
    expect(genealogy.offspring.map((animal) => animal.id), ['nueva', 'intermedia', 'vieja']);
    expect(() => genealogy.offspring.clear(), throwsUnsupportedError);
    expect(genealogy, genealogy.copyWith(offspring: [...genealogy.offspring]));
  });

  test('propaga el error del contrato local', () async {
    const error = DomainException(message: 'local_read_failed');
    const useCase = GetAnimalGenealogyUseCase(_FamilyRepository(Result.failure(error)));
    final result = await useCase('sujeto');
    expect(result, const Result<AnimalGenealogy>.failure(error));
  });
}

GenealogyAnimalRecord _record(String id, {String? mother, String? father, int birthYear = 2022}) =>
    GenealogyAnimalRecord(
      animal: GenealogyAnimal(id: id, visualTag: id, breed: 'Angus', categoryName: 'Vaca'),
      birthDate: DateTime.utc(birthYear),
      motherId: mother,
      fatherId: father,
    );

class _FamilyRepository implements AnimalGenealogyRepository {
  const _FamilyRepository(this.result);
  final Result<List<GenealogyAnimalRecord>> result;

  @override
  Future<Result<List<GenealogyAnimalRecord>>> getLocalFamily(String animalId) async => result;
}

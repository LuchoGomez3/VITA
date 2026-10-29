import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_genealogy_repository.dart';

/// Construye tres generaciones y ordena las crías con los datos locales.
class GetAnimalGenealogyUseCase {
  /// Crea el caso de uso con el contrato de lectura local.
  const GetAnimalGenealogyUseCase(this._repository);

  final AnimalGenealogyRepository _repository;

  /// Lee la familia de [animalId] y evita repetir ancestros en una misma línea.
  Future<Result<AnimalGenealogy>> call(String animalId) async {
    final result = await _repository.getLocalFamily(animalId);
    return result.when(
      success: (records) => Result.success(_buildTree(animalId, records)),
      failure: Result.failure,
    );
  }

  AnimalGenealogy _buildTree(String animalId, List<GenealogyAnimalRecord> records) {
    final byId = {for (final record in records) record.animal.id: record};
    final subject = byId[animalId];
    if (subject == null) return const AnimalGenealogy();

    // El corte se hace por línea, para permitir ancestros compartidos sin ciclos.
    GenealogyAnimalRecord? relative(String? id, Set<String> excluded) =>
        id == null || excluded.contains(id) ? null : byId[id];

    final father = relative(subject.fatherId, {animalId});
    final mother = relative(subject.motherId, {animalId});
    final paternalLine = {animalId, ?father?.animal.id};
    final maternalLine = {animalId, ?mother?.animal.id};
    final offspring =
        records
            .where(
              (record) => record.animal.id != animalId && (record.motherId == animalId || record.fatherId == animalId),
            )
            .toList()
          ..sort((a, b) => b.birthDate.compareTo(a.birthDate));

    return AnimalGenealogy(
      father: father?.animal,
      mother: mother?.animal,
      paternalGrandfather: relative(father?.fatherId, paternalLine)?.animal,
      paternalGrandmother: relative(father?.motherId, paternalLine)?.animal,
      maternalGrandfather: relative(mother?.fatherId, maternalLine)?.animal,
      maternalGrandmother: relative(mother?.motherId, maternalLine)?.animal,
      offspring: [for (final child in offspring) child.animal],
    );
  }
}

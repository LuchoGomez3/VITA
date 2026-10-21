import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';

/// Lee la genealogía de un animal desde los datos guardados en el celular.
abstract interface class AnimalGenealogyRepository {
  /// Padres, abuelos y crías del animal [animalId].
  Future<Result<AnimalGenealogy>> getGenealogy(String animalId);
}

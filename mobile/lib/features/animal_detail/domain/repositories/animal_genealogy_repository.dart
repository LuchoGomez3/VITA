import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';

/// Acceso local a los datos de parentesco, independiente de la persistencia.
abstract interface class AnimalGenealogyRepository {
  /// Lee animales sin baja lógica del mismo establecimiento que [animalId].
  ///
  /// Incluye al sujeto y devuelve una lista vacía si no está disponible.
  Future<Result<List<GenealogyAnimalRecord>>> getLocalFamily(String animalId);
}

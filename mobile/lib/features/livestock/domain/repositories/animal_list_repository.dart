import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';

/// Lectura de los animales vigentes para la lista de Hacienda.
abstract class AnimalListRepository {
  /// Devuelve los animales sin baja, del más reciente al más antiguo.
  Future<Result<List<AnimalListEntry>>> getAnimals();

  /// Establecimientos del usuario, para el selector de la cabecera.
  Future<Result<List<EstablishmentMembership>>> getEstablishments();
}

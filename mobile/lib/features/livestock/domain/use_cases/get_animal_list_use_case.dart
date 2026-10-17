import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/animal_list_repository.dart';

/// Obtiene los animales que se listan en Hacienda.
class GetAnimalListUseCase {
  /// Crea el caso de uso sobre el repositorio de la lista.
  const GetAnimalListUseCase(this._repository);

  final AnimalListRepository _repository;

  /// Lee los animales vigentes.
  Future<Result<List<AnimalListEntry>>> call() => _repository.getAnimals();
}

/// Obtiene los establecimientos del usuario para el selector de Hacienda.
class GetAnimalListEstablishmentsUseCase {
  /// Crea el caso de uso sobre el repositorio de la lista.
  const GetAnimalListEstablishmentsUseCase(this._repository);

  final AnimalListRepository _repository;

  /// Lee los establecimientos guardados en el celular.
  Future<Result<List<EstablishmentMembership>>> call() => _repository.getEstablishments();
}

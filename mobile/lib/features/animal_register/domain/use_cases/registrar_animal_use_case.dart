import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_repository.dart';

class RegistrarAnimalUseCase {
  const RegistrarAnimalUseCase(this._repository);

  final AnimalRepository _repository;

  Future<Result<Animal>> call(Animal animal) {
    return _repository.registrarAnimal(animal);
  }
}

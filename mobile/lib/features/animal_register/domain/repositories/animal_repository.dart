import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal.dart';

abstract class AnimalRepository {
  Future<Result<Animal>> registrarAnimal(Animal animal);
}

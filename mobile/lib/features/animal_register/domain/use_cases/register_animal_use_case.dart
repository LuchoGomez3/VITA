import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_repository.dart';

/// Registers an animal through the offline-first repository contract.
class RegisterAnimalUseCase {
  /// Creates the use case with its repository dependency.
  const RegisterAnimalUseCase(this._repository);

  final AnimalRegistrationRepository _repository;

  /// Saves [registration] locally and returns its synchronization state.
  Future<Result<RegisteredAnimal>> call(AnimalRegistration registration) {
    return _repository.register(registration);
  }
}

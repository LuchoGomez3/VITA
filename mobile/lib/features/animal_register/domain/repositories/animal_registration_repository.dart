import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Contract for locally persisting and synchronizing animal registrations.
abstract class AnimalRegistrationRepository {
  /// Saves [registration] locally and schedules its remote synchronization.
  Future<Result<RegisteredAnimal>> register(
    AnimalRegistration registration,
  );
}

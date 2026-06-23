import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_repository.dart';

/// Caso de uso para registrar un animal desde el flujo mobile.
///
/// El BLoC llama a esta clase cuando el usuario confirma el formulario. El use
/// case expresa la accion de negocio ("registrar animal") y evita que
/// presentation conozca detalles de persistencia, Brick, SQLite o backend.
class RegisterAnimalUseCase {
  /// Crea el use case con el contrato de repositorio que ejecuta el registro.
  ///
  /// Se inyecta el contrato, no la implementacion concreta, para mantener domain
  /// independiente de data.
  const RegisterAnimalUseCase(this._repository);

  final AnimalRegistrationRepository _repository;

  /// Registra [registration] usando la estrategia offline-first.
  ///
  /// La implementacion actual guarda primero en el dispositivo y deja el sync
  /// con backend en manos del repositorio/Brick. Por eso el resultado devuelve
  /// el animal registrado junto con su estado de sincronizacion local.
  Future<Result<RegisteredAnimal>> call(AnimalRegistration registration) {
    return _repository.register(registration);
  }
}

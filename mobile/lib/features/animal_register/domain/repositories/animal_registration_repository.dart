import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Contrato de dominio para registrar animales.
///
/// Domain define que operacion necesita ("registrar un animal"), pero no conoce
/// la tecnologia usada para resolverla. La implementacion concreta puede usar
/// Brick, SQLite, REST, mocks de test u otra estrategia sin afectar al use case.
abstract class AnimalRegistrationRepository {
  /// Guarda [registration] con estrategia offline-first.
  ///
  /// En la implementacion actual, esto significa persistir primero en el
  /// dispositivo y dejar programada la sincronizacion remota. El resultado
  /// incluye el animal registrado y su estado local de sync.
  Future<Result<RegisteredAnimal>> register(
    AnimalRegistration registration,
  );
}

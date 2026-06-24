import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/data/mappers/animal_registration_brick_mapper.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_repository.dart';

/// Implementacion concreta del contrato de registro usando Brick.
///
/// Este archivo ya pertenece a data: aca si podemos conocer Brick, mappers y
/// detalles de persistencia. Domain solo ve [AnimalRegistrationRepository].
class AnimalRegistrationRepositoryImpl implements AnimalRegistrationRepository {
  /// Crea el repository con el store offline-first que persiste animales.
  ///
  /// Se inyecta [AnimalBrickStore] para poder testear esta clase sin depender de
  /// la instancia real de Brick.
  const AnimalRegistrationRepositoryImpl({
    required AnimalBrickStore brickStore,
  }) : _brickStore = brickStore;

  final AnimalBrickStore _brickStore;

  @override
  Future<Result<RegisteredAnimal>> register(
    AnimalRegistration registration,
  ) async {
    try {
      // El use case entrega una entidad de dominio. Antes de persistirla hay
      // que convertirla al modelo que Brick sabe guardar y sincronizar.
      final model = AnimalRegistrationBrickMapper.toBrick(registration);

      // Brick guarda primero en SQLite y deja el sync remoto programado. Por
      // eso esta llamada puede devolver exito aunque el backend todavia no haya
      // aceptado el animal.
      final savedModel = await _brickStore.upsertAnimal(model);

      // La capa superior no debe recibir modelos Brick. Convertimos de nuevo a
      // dominio para devolver un resultado estable a BLoC/use case.
      return Result.success(
        AnimalRegistrationBrickMapper.toDomain(savedModel),
      );
    } on DomainException catch (error) {
      // Los errores de dominio ya traen mensaje/codigo aptos para la UI.
      return Result.failure(error);
    } on Object {
      // Cualquier error inesperado de persistencia local se presenta como una
      // falla offline-friendly: el productor no deberia ver detalles tecnicos.
      return const Result.failure(
        DomainException(
          message: 'No se pudo guardar el animal en este dispositivo.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }
}

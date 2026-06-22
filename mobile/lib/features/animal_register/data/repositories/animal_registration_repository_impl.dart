import 'package:frontend_mayoral/brick/repository.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/data/mappers/animal_registration_brick_mapper.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_registration_repository.dart';

/// Brick-backed implementation for offline animal registrations.
class AnimalRegistrationRepositoryImpl implements AnimalRegistrationRepository {
  const AnimalRegistrationRepositoryImpl({
    required AnimalBrickStore brickStore,
  }) : _brickStore = brickStore;

  final AnimalBrickStore _brickStore;

  @override
  Future<Result<RegisteredAnimal>> register(
    AnimalRegistration registration,
  ) async {
    try {
      final model = AnimalRegistrationBrickMapper.toBrick(registration);
      final savedModel = await _brickStore.upsertAnimal(model);

      return Result.success(
        AnimalRegistrationBrickMapper.toDomain(savedModel),
      );
    } on DomainException catch (error) {
      return Result.failure(error);
    } catch (_) {
      return const Result.failure(
        DomainException(
          message: 'No se pudo guardar el animal en este dispositivo.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }
}

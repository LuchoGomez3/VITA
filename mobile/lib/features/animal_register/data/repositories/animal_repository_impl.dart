import 'package:frontend_mayoral/brick/repository.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/data/mappers/animal_brick_mapper.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal.dart';
import 'package:frontend_mayoral/features/animal_register/domain/repositories/animal_repository.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  AnimalRepositoryImpl({
    required AppBrickRepository brickRepository,
  }) : _brickRepository = brickRepository;

  final AppBrickRepository _brickRepository;

  @override
  Future<Result<Animal>> registrarAnimal(Animal animal) async {
    try {
      final brickModel = AnimalBrickMapper.toBrick(animal);
      final saved = await _brickRepository.upsertAnimal(brickModel);

      return Success(AnimalBrickMapper.toDomain(saved));
    } catch (_) {
      return const Failure(
        DomainException(
          message: 'No se pudo registrar el animal.',
          code: DomainErrorCode.syncFailed,
        ),
      );
    }
  }
}

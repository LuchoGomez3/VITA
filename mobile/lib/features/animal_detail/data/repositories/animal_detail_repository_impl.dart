import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/data/datasources/animal_detail_remote_data_source.dart';
import 'package:frontend_mayoral/features/animal_detail/data/mappers/animal_detail_mapper.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/repositories/animal_detail_repository.dart';

/// Implementacion offline-first del repository de detalle de animal.
class AnimalDetailRepositoryImpl implements AnimalDetailRepository {
  /// Crea el repository con cache Brick y fuente remota.
  const AnimalDetailRepositoryImpl({
    required AnimalBrickStore brickStore,
    required AnimalDetailRemoteDataSource remoteDataSource,
  }) : _brickStore = brickStore,
       _remoteDataSource = remoteDataSource;

  final AnimalBrickStore _brickStore;
  final AnimalDetailRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AnimalDetail>> getById(String animalId) async {
    try {
      final localAnimal = await _brickStore.getAnimalById(animalId);
      if (localAnimal != null) {
        return Result.success(AnimalDetailMapper.fromBrick(localAnimal));
      }

      final remoteAnimal = await _remoteDataSource.getAnimalById(animalId);
      await _brickStore.cacheAnimal(
        AnimalDetailMapper.toBrickCache(remoteAnimal),
      );
      return Result.success(AnimalDetailMapper.fromBackend(remoteAnimal));
    } on DomainException catch (error) {
      return Result.failure(error);
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudo cargar la información del animal.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }
}

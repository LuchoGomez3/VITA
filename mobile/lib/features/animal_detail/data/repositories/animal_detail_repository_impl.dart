import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
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
    required CategoriaBrickStore categoriaBrickStore,
    required PesajeBrickStore pesajeBrickStore,
    required AnimalDetailRemoteDataSource remoteDataSource,
  }) : _brickStore = brickStore,
       _categoriaBrickStore = categoriaBrickStore,
       _pesajeBrickStore = pesajeBrickStore,
       _remoteDataSource = remoteDataSource;

  final AnimalBrickStore _brickStore;
  final CategoriaBrickStore _categoriaBrickStore;
  final PesajeBrickStore _pesajeBrickStore;
  final AnimalDetailRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AnimalDetail>> getById(String animalId) async {
    try {
      final localAnimal = await _brickStore.getAnimalById(animalId);
      if (localAnimal != null) {
        return Result.success(await _enrichDetail(AnimalDetailMapper.fromBrick(localAnimal)));
      }

      // TODO(equipo): Analizar si este fallback remoto debe quedar en la feature.
      // El flujo objetivo es offline-first; esta consulta solo cubre animales
      // que todavia no fueron hidratados en SQLite.
      final remoteAnimal = await _remoteDataSource.getAnimalById(animalId);
      await _brickStore.cacheAnimal(
        AnimalDetailMapper.toBrickCache(remoteAnimal),
      );
      return Result.success(
        await _enrichDetail(AnimalDetailMapper.fromBackend(remoteAnimal)),
      );
    } on DomainException catch (error) {
      return Result.failure(error);
    } on FormatException {
      return const Result.failure(
        DomainException(
          message: 'El detalle del animal tiene datos invalidos.',
        ),
      );
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudo cargar la información del animal.',
        ),
      );
    }
  }

  /// Refresca datos relacionados y siempre termina leyendo la cache local.
  ///
  /// Los errores del pull no invalidan la ficha: en campo puede no haber red y
  /// tanto los pesajes como las categorias deben seguir disponibles en SQLite.
  Future<AnimalDetail> _enrichDetail(AnimalDetail detail) async {
    List<BrickPesajeModel> localPesajes;
    try {
      localPesajes = await _pesajeBrickStore.loadPesajesByAnimal(
        detail.establishmentId,
        detail.id,
      );
    } on Object {
      // El fallback local es parte esperada del flujo offline-first.
      localPesajes = await _pesajeBrickStore.getLocalPesajesByAnimal(
        detail.id,
      );
    }

    try {
      await _categoriaBrickStore.pullRemoteCategorias(detail.establishmentId);
    } on Object {
      // Las categorias ya descargadas siguen resolviendo el nombre sin red.
    }

    final localCategorias = await _categoriaBrickStore.getLocalCategorias(
      detail.establishmentId,
    );
    final weightHistory = AnimalDetailMapper.weightHistoryFromBrick(
      localPesajes,
    );
    final latestWeight = weightHistory.lastOrNull;
    final categoryName = localCategorias.where((category) => category.localId == detail.categoryId).firstOrNull?.name;

    return detail.copyWith(
      categoryName: categoryName ?? detail.categoryName,
      weightHistory: weightHistory,
      currentWeight: latestWeight?.weightKg ?? detail.currentWeight,
      weighingMethod: latestWeight?.method ?? detail.weighingMethod,
      weighingDate: latestWeight?.date ?? detail.weighingDate,
    );
  }
}

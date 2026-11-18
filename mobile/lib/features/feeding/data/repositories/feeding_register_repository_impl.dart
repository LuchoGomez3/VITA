import 'package:frontend_mayoral/brick/mappers/animal_productive_status_mapper.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/feeding_record_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/food_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/feeding/data/mappers/feeding_brick_mapper.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';
import 'package:frontend_mayoral/features/feeding/domain/repositories/feeding_repositories.dart';
import 'package:logging/logging.dart';

/// Lee y escribe el formulario de alimentación en SQLite.
class FeedingRegisterRepositoryImpl implements FeedingRegisterRepository {
  /// Crea el repositorio sobre los stores de Brick.
  const FeedingRegisterRepositoryImpl({
    required AnimalBrickStore animalStore,
    required CategoriaBrickStore categoryStore,
    required LotBrickStore lotStore,
    required FoodBrickStore foodStore,
    required FeedingRecordBrickStore recordStore,
  }) : _animalStore = animalStore,
       _categoryStore = categoryStore,
       _lotStore = lotStore,
       _foodStore = foodStore,
       _recordStore = recordStore;

  final AnimalBrickStore _animalStore;
  final CategoriaBrickStore _categoryStore;
  final LotBrickStore _lotStore;
  final FoodBrickStore _foodStore;
  final FeedingRecordBrickStore _recordStore;
  static final _logger = Logger('FeedingRegisterRepository');

  @override
  Future<Result<FeedingAnimal?>> getAnimal(String animalId) => _guard(() async {
    final animal = await _animalStore.getAnimalById(animalId);
    return animal == null || !_inStock(animal) ? null : _toFeedingAnimal(animal);
  });

  @override
  Future<Result<FeedingAnimal?>> findAnimalByTag(String tag, {required String establishmentId}) => _guard(() async {
    final digits = tag.replaceAll(RegExp(r'\D'), '');
    final visual = _normalizeVisualTag(tag);
    final animals = (await _animalStore.getLocalAnimals())
        .where((animal) => _inStock(animal) && animal.establishmentId == establishmentId)
        .toList();
    // El RFID tiene prioridad sobre la caravana visual, igual que al mover.
    final byRfid = digits.length == 15
        ? animals.where((a) => a.rfidTagNumber.replaceAll(RegExp(r'\D'), '') == digits).toList()
        : <BrickAnimalModel>[];
    final matches = byRfid.isNotEmpty
        ? byRfid
        : animals.where((a) => _normalizeVisualTag(a.visualTag) == visual).toList();
    if (matches.length > 1) {
      throw DomainException(
        message: 'Hay más de un animal con la caravana $tag. Leé el RFID.',
        code: DomainErrorCode.conflict,
      );
    }
    return matches.isEmpty ? null : _toFeedingAnimal(matches.single);
  });

  @override
  Future<Result<List<FeedingLot>>> getLots(String establishmentId) => _guard(() async {
    final lots = await _lotStore.getLocalLots(establishmentId);
    return [for (final lot in lots) FeedingLot(id: lot.localId, name: lot.name)];
  });

  @override
  Future<Result<List<Food>>> getFoods(String establishmentId) => _guard(() async {
    final foods = await _foodStore.getLocalFoods(establishmentId);
    return foods.map(FeedingBrickMapper.foodFromBrick).toList();
  });

  @override
  Future<Result<void>> saveRecord(FeedingRecord record, {Food? newFood}) => _guard(() async {
    await _recordStore.save(
      FeedingBrickMapper.recordToBrick(record),
      newFood: newFood == null
          ? null
          : FeedingBrickMapper.foodToBrick(
              newFood,
              establishmentId: record.establishmentId,
              timestamp: record.createdAt,
            ),
    );
  });

  bool _inStock(BrickAnimalModel animal) =>
      animal.deletedAt == null && animal.productiveStatus.toDomain().isInProductiveStock;

  Future<FeedingAnimal> _toFeedingAnimal(BrickAnimalModel animal) async {
    var categoryName = animal.categoryName;
    if (categoryName.isEmpty) {
      for (final category in await _categoryStore.getLocalCategorias()) {
        if (category.localId == animal.categoryId) categoryName = category.name;
      }
    }
    final lotName = animal.lotName.isNotEmpty || animal.lotId.isEmpty
        ? animal.lotName
        : (await _lotStore.getLocalLot(animal.lotId))?.name ?? '';
    return FeedingAnimal(
      id: animal.localId,
      establishmentId: animal.establishmentId,
      visualTag: animal.visualTag,
      rfidTagNumber: animal.rfidTagNumber,
      breed: animal.breed,
      categoryName: categoryName,
      lotId: animal.lotId,
      lotName: lotName,
    );
  }

  static String _normalizeVisualTag(String tag) => tag.replaceAll(RegExp(r'\s'), '').toLowerCase();

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on DomainException catch (error) {
      return Result.failure(error);
    } on Object catch (error, stackTrace) {
      _logger.severe('Falló una operación local de alimentación.', error, stackTrace);
      return const Result.failure(
        DomainException(
          message: 'No se pudo usar la información guardada en el celular.',
          code: DomainErrorCode.offline,
        ),
      );
    }
  }
}

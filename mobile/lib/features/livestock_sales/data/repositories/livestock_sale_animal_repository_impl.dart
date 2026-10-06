import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/mappers/livestock_sale_animal_mapper.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_selection_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_animal_repository.dart';

/// Consulta el inventario Brick/SQLite sin depender de conectividad.
class LivestockSaleAnimalRepositoryImpl implements LivestockSaleAnimalRepository {
  /// Crea el repositorio con el inventario y sus catalogos locales.
  LivestockSaleAnimalRepositoryImpl({
    required AnimalBrickStore animalBrickStore,
    required CategoriaBrickStore categoryBrickStore,
    required LotBrickStore lotBrickStore,
    required String establishmentId,
  }) : _animalBrickStore = animalBrickStore,
       _categoryBrickStore = categoryBrickStore,
       _lotBrickStore = lotBrickStore,
       _establishmentId = establishmentId;

  final AnimalBrickStore _animalBrickStore;
  final CategoriaBrickStore _categoryBrickStore;
  final LotBrickStore _lotBrickStore;
  final String _establishmentId;
  bool _refreshAttempted = false;

  @override
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  ) async {
    try {
      await _refreshInventoryOnce();

      // La consulta usa solo SQLite. Incluso sin conectividad puede identificar
      // si la caravana esta disponible, vendida o pertenece a otro tenant.
      final animals = await _animalBrickStore.getLocalAnimals();
      final animal = _selectLatestAnimal(
        animals: animals,
        rfidTagNumber: rfidTagNumber,
      );

      if (animal == null) return const Result.success(null);

      final categories = await _categoryBrickStore.getLocalCategorias(
        animal.establishmentId,
      );
      final lots = await _lotBrickStore.getLocalLots(animal.establishmentId);
      final categoryName = _categoryName(categories, animal.categoryId);
      final lotName = _lotName(lots, animal.lotId);
      final mappedAnimal = LivestockSaleAnimalMapper.fromBrick(animal);

      return Result.success(
        mappedAnimal.copyWith(
          categoryName: categoryName ?? mappedAnimal.categoryName,
          lotName: lotName ?? mappedAnimal.lotName,
        ),
      );
    } on Object {
      // El contrato Result evita que una falla local termine cerrando el flujo
      // de campo y permite mostrar un mensaje recuperable al productor.
      const reason = LivestockSaleSelectionError.localRead;
      return const Result.failure(
        DomainException(
          message: 'localRead',
          code: DomainErrorCode.offline,
          reason: reason,
        ),
      );
    }
  }

  @override
  Future<Result<List<LivestockSaleAnimal>>> findLocalByRfidPrefix(
    String prefix,
  ) async {
    try {
      final normalizedPrefix = prefix.trim();
      if (normalizedPrefix.isEmpty) {
        return const Result.success(<LivestockSaleAnimal>[]);
      }
      final animals = await _animalBrickStore.getLocalAnimals();
      final latestByRfid = <String, BrickAnimalModel>{};

      // Las sugerencias solo muestran stock vendible del establecimiento actual.
      // La validación completa sigue ocurriendo al agregar el animal elegido.
      for (final animal in animals) {
        if (animal.establishmentId != _establishmentId ||
            animal.status != 'activo' ||
            animal.deletedAt != null ||
            !animal.rfidTagNumber.startsWith(normalizedPrefix)) {
          continue;
        }
        final previous = latestByRfid[animal.rfidTagNumber];
        if (previous == null || animal.updatedAt.isAfter(previous.updatedAt)) {
          latestByRfid[animal.rfidTagNumber] = animal;
        }
      }

      final categories = await _categoryBrickStore.getLocalCategorias(
        _establishmentId,
      );
      final lots = await _lotBrickStore.getLocalLots(_establishmentId);
      final matches = latestByRfid.values.map((animal) {
        final mapped = LivestockSaleAnimalMapper.fromBrick(animal);
        return mapped.copyWith(
          categoryName: _categoryName(categories, animal.categoryId) ?? mapped.categoryName,
          lotName: _lotName(lots, animal.lotId) ?? mapped.lotName,
        );
      }).toList()..sort((first, second) => first.rfidTagNumber.compareTo(second.rfidTagNumber));

      return Result.success(matches.take(10).toList(growable: false));
    } on Object {
      const reason = LivestockSaleSelectionError.localRead;
      return const Result.failure(
        DomainException(
          message: 'localRead',
          code: DomainErrorCode.offline,
          reason: reason,
        ),
      );
    }
  }

  Future<void> _refreshInventoryOnce() async {
    if (_refreshAttempted) return;
    _refreshAttempted = true;

    // El primer escaneo intenta actualizar estado y catalogos. Cada descarga
    // falla de forma independiente: sin red la seleccion continua leyendo la
    // ultima copia consistente disponible en SQLite.
    await Future.wait([
      _ignoreRemoteFailure(
        _animalBrickStore.pullRemoteAnimals(_establishmentId),
      ),
      _ignoreRemoteFailure(
        _categoryBrickStore.pullRemoteCategorias(_establishmentId),
      ),
      _ignoreRemoteFailure(
        _lotBrickStore.pullRemoteLots(_establishmentId),
      ),
    ]);
  }

  Future<void> _ignoreRemoteFailure(Future<void> operation) async {
    try {
      await operation;
    } on Object {
      // El flujo de campo conserva la copia local cuando no hay conectividad.
    }
  }

  String? _categoryName(
    Iterable<BrickCategoriaModel> categories,
    String categoryId,
  ) {
    for (final category in categories) {
      if (category.localId == categoryId) return category.name;
    }
    return null;
  }

  String? _lotName(Iterable<BrickLotModel> lots, String lotId) {
    for (final lot in lots) {
      if (lot.localId == lotId) return lot.name;
    }
    return null;
  }

  BrickAnimalModel? _selectLatestAnimal({
    required Iterable<BrickAnimalModel> animals,
    required String rfidTagNumber,
  }) {
    BrickAnimalModel? latest;

    // La busqueda abarca todos los establecimientos para que dominio pueda
    // distinguir una caravana ajena de una que no existe en el dispositivo.
    for (final animal in animals) {
      if (animal.rfidTagNumber != rfidTagNumber || animal.deletedAt != null) {
        continue;
      }
      if (latest == null || animal.updatedAt.isAfter(latest.updatedAt)) {
        latest = animal;
      }
    }

    return latest;
  }
}

import 'dart:async';

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
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_detail_animal_repository.dart';
import 'package:logging/logging.dart';

/// Consulta el inventario Brick/SQLite sin depender de conectividad.
class LivestockSaleAnimalRepositoryImpl implements LivestockSaleAnimalRepository, LivestockSaleDetailAnimalRepository {
  /// Crea el repositorio con el inventario y sus catalogos locales.
  LivestockSaleAnimalRepositoryImpl({
    required AnimalBrickStore animalBrickStore,
    required AnimalSelectionStore animalSelectionStore,
    required CategoriaBrickStore categoryBrickStore,
    required LotBrickStore lotBrickStore,
    required String establishmentId,
  }) : _animalBrickStore = animalBrickStore,
       _animalSelectionStore = animalSelectionStore,
       _categoryBrickStore = categoryBrickStore,
       _lotBrickStore = lotBrickStore,
       _establishmentId = establishmentId;

  final AnimalBrickStore _animalBrickStore;
  final AnimalSelectionStore _animalSelectionStore;
  final CategoriaBrickStore _categoryBrickStore;
  final LotBrickStore _lotBrickStore;
  final String _establishmentId;
  Future<void>? _inventoryRefresh;
  static final _logger = Logger('LivestockSaleAnimalRepository');

  @override
  Future<Result<List<LivestockSaleAnimal>>> findLocalByIds(
    List<String> animalIds,
  ) async {
    try {
      if (animalIds.isEmpty) {
        return const Result.success(<LivestockSaleAnimal>[]);
      }
      // La consulta queda acotada por tenant en el store y se resuelve en una
      // sola lectura por lotes para no hacer una consulta SQLite por animal.
      final stored = await _animalSelectionStore.getLocalAnimalsByIds(
        _establishmentId,
        animalIds.toSet(),
      );
      final categories = await _categoryBrickStore.getLocalCategorias();
      final lots = await _lotBrickStore.getLocalLots(_establishmentId);
      final animalsById = {
        for (final animal in stored) animal.localId: _mapAnimal(animal, categories, lots),
      };
      return Result.success([
        for (final animalId in animalIds)
          if (animalsById[animalId] case final animal?) animal,
      ]);
    } on Object catch (error, stackTrace) {
      _logger.severe(
        'No se pudieron leer los animales asociados a la venta.',
        error.runtimeType,
        stackTrace,
      );
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
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  ) async {
    try {
      // La primera seleccion no debe esperar animales, categorias y lotes del
      // backend. Se inicia una unica actualizacion compartida, pero la caravana
      // se resuelve inmediatamente con el inventario durable de SQLite.
      unawaited(_refreshInventoryOnce());

      // La consulta usa solo SQLite. Incluso sin conectividad puede identificar
      // si la caravana esta disponible, vendida o pertenece a otro tenant.
      final animals = await _animalBrickStore.getLocalAnimals();
      final animal = _selectLatestAnimal(
        animals: animals,
        rfidTagNumber: rfidTagNumber,
      );

      if (animal == null) return const Result.success(null);

      final categories = await _categoryBrickStore.getLocalCategorias();
      final lots = await _lotBrickStore.getLocalLots(animal.establishmentId);
      return Result.success(_mapAnimal(animal, categories, lots));
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudo identificar el animal local.', error.runtimeType, stackTrace);
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

      // El autocompletado prioriza la copia local para responder en cada tecla.
      // La sincronizacion mejora búsquedas posteriores sin bloquear el campo
      // cuando la red está lenta o directamente no está disponible.
      unawaited(_refreshInventoryOnce());
      final animals = await _animalBrickStore.getLocalAnimals();
      final latestByRfid = <String, BrickAnimalModel>{};

      // Las sugerencias solo muestran stock vendible del establecimiento actual.
      // La validación completa sigue ocurriendo al agregar el animal elegido.
      for (final animal in animals) {
        if (animal.establishmentId != _establishmentId ||
            animal.productiveStatus != BrickAnimalProductiveStatus.active ||
            animal.syncStatus == BrickAnimalSyncStatus.rejected ||
            animal.deletedAt != null ||
            !animal.rfidTagNumber.startsWith(normalizedPrefix)) {
          continue;
        }
        final previous = latestByRfid[animal.rfidTagNumber];
        if (previous == null || animal.updatedAt.isAfter(previous.updatedAt)) {
          latestByRfid[animal.rfidTagNumber] = animal;
        }
      }

      final categories = await _categoryBrickStore.getLocalCategorias();
      final lots = await _lotBrickStore.getLocalLots(_establishmentId);
      final matches = latestByRfid.values.map((animal) {
        return _mapAnimal(animal, categories, lots);
      }).toList()..sort((first, second) => first.rfidTagNumber.compareTo(second.rfidTagNumber));

      // El límite visual se aplica después de excluir los animales que ya
      // integran la venta, para que esas bajas no dejen huecos en la lista.
      return Result.success(matches);
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudieron leer las sugerencias locales.', error.runtimeType, stackTrace);
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

  Future<void> _refreshInventoryOnce() {
    return _inventoryRefresh ??= _refreshInventory();
  }

  Future<void> _refreshInventory() async {
    // El primer escaneo intenta actualizar estado y catalogos. Cada descarga
    // o búsqueda comparte este Future. Así, varias teclas consecutivas no leen
    // SQLite antes de que termine la misma actualización inicial.
    await Future.wait([
      _ignoreRemoteFailure(
        _animalBrickStore.pullRemoteAnimals(_establishmentId),
      ),
      _ignoreRemoteFailure(
        _categoryBrickStore.pullRemoteCategorias(),
      ),
      _ignoreRemoteFailure(
        _lotBrickStore.pullRemoteLots(_establishmentId),
      ),
    ]);
  }

  Future<void> _ignoreRemoteFailure(Future<void> operation) async {
    try {
      await operation;
    } on Object catch (error, stackTrace) {
      // El tipo y stack permiten diagnosticar sin volcar mensajes que pueden
      // contener SQL, identificadores o payloads. La copia local sigue disponible.
      _logger.warning('No se pudo actualizar el inventario remoto.', error.runtimeType, stackTrace);
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

  LivestockSaleAnimal _mapAnimal(
    BrickAnimalModel animal,
    Iterable<BrickCategoriaModel> categories,
    Iterable<BrickLotModel> lots,
  ) {
    final mapped = LivestockSaleAnimalMapper.fromBrick(animal);
    return mapped.copyWith(
      categoryName: _categoryName(categories, animal.categoryId) ?? mapped.categoryName,
      lotName: _lotName(lots, animal.lotId) ?? mapped.lotName,
    );
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

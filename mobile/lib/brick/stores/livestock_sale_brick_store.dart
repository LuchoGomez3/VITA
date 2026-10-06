import 'dart:async';
import 'dart:convert';

import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';

/// Motivo estable por el que una venta no puede confirmarse localmente.
enum LivestockSaleLocalErrorCode {
  /// La lista JSON esta vacia, repetida o mal formada.
  invalidAnimalIds,

  /// Uno de los UUID no existe en SQLite.
  animalNotFound,

  /// Un animal pertenece a otro establecimiento.
  differentEstablishment,

  /// Un animal ya no integra el stock activo.
  animalNotActive,
}

/// Error de integridad detectado antes de persistir una venta local.
class LivestockSaleLocalException implements Exception {
  /// Crea un error identificable por las capas superiores.
  const LivestockSaleLocalException(this.code, {this.animalId});

  /// Codigo que domain puede traducir a un mensaje para el usuario.
  final LivestockSaleLocalErrorCode code;

  /// Animal relacionado, cuando el error corresponde a uno particular.
  final String? animalId;
}

/// Acceso offline-first a las ventas de hacienda.
abstract class LivestockSaleBrickStore {
  /// Guarda la venta y da de baja sus animales en una sola transaccion local.
  Future<BrickLivestockSaleModel> saveSale(BrickLivestockSaleModel sale);
}

/// Lectura y cobro local del historial, sin repetir la baja de animales.
abstract class LivestockSaleHistoryBrickStore {
  /// Consulta ventas vigentes; `null` incluye todos los establecimientos.
  Future<List<BrickLivestockSaleModel>> getSales(String? establishmentId);

  /// Completa el primer cobro de una venta que todavía no recibió dinero.
  Future<BrickLivestockSaleModel> collectUnpaidSale(BrickLivestockSaleModel sale);
}

/// Conflicto funcional al intentar cobrar una venta ausente o ya cobrada.
class LivestockSaleCollectionException implements Exception {
  /// Indica que el historial debe recargarse antes de volver a cobrar.
  const LivestockSaleCollectionException();
}

/// Store que coordina venta, stock local y resultado de sincronizacion.
class BrickLivestockSaleStore implements LivestockSaleBrickStore, LivestockSaleHistoryBrickStore {
  BrickLivestockSaleStore._(
    this._repository, {
    required bool enableRemoteSync,
  }) : _enableRemoteSync = enableRemoteSync {
    _syncSubscription = _repository.syncResults.listen(applySyncResult);
  }

  static BrickLivestockSaleStore? _instance;

  final AppBrickRepository _repository;
  final bool _enableRemoteSync;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;

  /// Instancia configurada durante el bootstrap de Brick.
  static BrickLivestockSaleStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError('BrickLivestockSaleStore no fue inicializado.');
    }
    return store;
  }

  /// Registra el store una unica vez.
  static void configure(
    AppBrickRepository repository, {
    bool enableRemoteSync = true,
  }) {
    _instance ??= BrickLivestockSaleStore._(
      repository,
      enableRemoteSync: enableRemoteSync,
    );
  }

  @override
  Future<List<BrickLivestockSaleModel>> getSales(String? establishmentId) async {
    final stored = await _repository.getLocal<BrickLivestockSaleModel>();
    final latest = <String, BrickLivestockSaleModel>{};
    for (final sale in stored.where((sale) => establishmentId == null || sale.establishmentId == establishmentId)) {
      final current = latest[sale.localId];
      if (current == null || sale.updatedAt.isAfter(current.updatedAt)) latest[sale.localId] = sale;
    }
    return latest.values.where((sale) => sale.deletedAt == null).toList()
      ..sort((a, b) => b.operationDate.compareTo(a.operationDate));
  }

  @override
  Future<BrickLivestockSaleModel> collectUnpaidSale(BrickLivestockSaleModel sale) {
    return _repository.runLocalTransaction((transaction) async {
      final stored = await transaction.getLocal<BrickLivestockSaleModel>();
      final current = _latestSaleById(stored, sale.localId);
      // Se vuelve a comprobar dentro de la transacción: dos pulsaciones o una
      // pantalla desactualizada no pueden reemplazar un cobro ya registrado.
      if (current == null || current.deletedAt != null || current.establishmentId != sale.establishmentId) {
        throw const LivestockSaleCollectionException();
      }
      if (current.paymentCondition != 'pendiente' || current.initialPaymentJson != null) {
        throw const LivestockSaleCollectionException();
      }
      sale.primaryKey = current.primaryKey;
      // TODO(team): Integrar un comando de cobro independiente cuando exista
      // el endpoint. El POST de alta no sirve para cobrar una venta existente.
      return transaction.upsert(sale);
    });
  }

  @override
  Future<BrickLivestockSaleModel> saveSale(
    BrickLivestockSaleModel sale,
  ) async {
    // La lista se valida antes de abrir la transaccion para no iniciar una
    // escritura con un agregado incompleto o con animales repetidos.
    final animalIds = _decodeAnimalIds(sale.animalIdsJson);
    final saved = await _repository.runLocalTransaction((transaction) async {
      // Se toma la version mas reciente de cada animal porque Brick puede
      // conservar revisiones locales durante la reconciliacion.
      final storedAnimals = await transaction.getLocal<BrickAnimalModel>();
      final animalsById = _latestAnimalsById(storedAnimals);
      final selectedAnimals = <BrickAnimalModel>[];

      // La comprobacion ocurre dentro de la misma transaccion que las bajas.
      // Esto evita confirmar dos ventas locales sobre el mismo animal.
      for (final animalId in animalIds) {
        final animal = animalsById[animalId];
        if (animal == null || animal.deletedAt != null) {
          throw LivestockSaleLocalException(
            LivestockSaleLocalErrorCode.animalNotFound,
            animalId: animalId,
          );
        }
        if (animal.establishmentId != sale.establishmentId) {
          throw LivestockSaleLocalException(
            LivestockSaleLocalErrorCode.differentEstablishment,
            animalId: animalId,
          );
        }
        if (animal.status != 'activo') {
          throw LivestockSaleLocalException(
            LivestockSaleLocalErrorCode.animalNotActive,
            animalId: animalId,
          );
        }
        selectedAnimals.add(animal);
      }

      final storedSales = await transaction.getLocal<BrickLivestockSaleModel>();
      final existingSale = _latestSaleById(storedSales, sale.localId);

      // La venta nace pendiente y reutiliza primaryKey si es un reintento local
      // del mismo UUID, evitando filas duplicadas en SQLite.
      final pendingSale = sale.copyWith(
        syncStatus: BrickLivestockSaleSyncStatus.pending,
        syncErrorCode: null,
      )..primaryKey = existingSale?.primaryKey ?? sale.primaryKey;
      final savedSale = await transaction.upsert(pendingSale);

      for (final animal in selectedAnimals) {
        // Venta y baja de stock comparten la transaccion: nunca puede quedar la
        // venta guardada con los animales todavia activos, ni al reves.
        await transaction.upsert(
          animal.copyWith(
            status: 'vendido',
            syncStatus: BrickAnimalSyncStatus.pending,
            syncErrorCode: null,
            updatedAt: sale.updatedAt,
          ),
        );
      }
      return savedSale;
    });

    // El alta remota empieza solamente despues del commit local. La UX recibe
    // el resultado local sin esperar conectividad ni respuesta del backend.
    if (_enableRemoteSync) {
      unawaited(_repository.enqueueRemoteUpsert(saved));
    }
    return saved;
  }

  /// Aplica la aceptacion o rechazo remoto sobre venta y animales atomicos.
  Future<void> applySyncResult(BackendSyncResult result) async {
    // El stream es compartido por stores; se ignoran respuestas de cualquier
    // recurso que no corresponda al endpoint de ventas.
    if (!result.resourcePath.endsWith(
      BrickLivestockSaleRequestTransformer.salesPath,
    )) {
      return;
    }

    await _repository.runLocalTransaction((transaction) async {
      final storedSales = await transaction.getLocal<BrickLivestockSaleModel>();
      final sale = _latestSaleById(storedSales, result.localId);
      if (sale == null) return;

      final nextSaleStatus = result.synchronized
          ? BrickLivestockSaleSyncStatus.synchronized
          : BrickLivestockSaleSyncStatus.rejected;
      await transaction.upsert(
        sale.copyWith(
          syncStatus: nextSaleStatus,
          syncErrorCode: result.errorCode,
        ),
      );

      final animalIds = _decodeAnimalIds(sale.animalIdsJson).toSet();
      final storedAnimals = await transaction.getLocal<BrickAnimalModel>();
      final animalsById = _latestAnimalsById(storedAnimals);
      for (final animalId in animalIds) {
        final animal = animalsById[animalId];
        if (animal == null) continue;
        await transaction.upsert(
          // Un rechazo no reactiva automaticamente el animal: la operacion y
          // su stock quedan marcados para conciliacion, sin perder el progreso.
          animal.copyWith(
            status: 'vendido',
            syncStatus: result.synchronized ? BrickAnimalSyncStatus.synchronized : BrickAnimalSyncStatus.rejected,
            syncErrorCode: result.errorCode,
          ),
        );
      }
    });
  }

  static List<String> _decodeAnimalIds(String encoded) {
    // Ademas de validar JSON, se exigen IDs no vacios y unicos porque la venta
    // representa una relacion uno-a-uno con cada baja de stock.
    Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException {
      throw const LivestockSaleLocalException(
        LivestockSaleLocalErrorCode.invalidAnimalIds,
      );
    }
    if (decoded is! List || decoded.isEmpty || decoded.any((id) => id is! String || id.isEmpty)) {
      throw const LivestockSaleLocalException(
        LivestockSaleLocalErrorCode.invalidAnimalIds,
      );
    }
    final ids = decoded.cast<String>();
    if (ids.toSet().length != ids.length) {
      throw const LivestockSaleLocalException(
        LivestockSaleLocalErrorCode.invalidAnimalIds,
      );
    }
    return ids;
  }

  static Map<String, BrickAnimalModel> _latestAnimalsById(
    Iterable<BrickAnimalModel> animals,
  ) {
    final byId = <String, BrickAnimalModel>{};
    for (final animal in animals) {
      final current = byId[animal.localId];
      if (current == null || animal.updatedAt.isAfter(current.updatedAt)) {
        byId[animal.localId] = animal;
      }
    }
    return byId;
  }

  static BrickLivestockSaleModel? _latestSaleById(
    Iterable<BrickLivestockSaleModel> sales,
    String saleId,
  ) {
    BrickLivestockSaleModel? latest;
    for (final sale in sales.where((item) => item.localId == saleId)) {
      if (latest == null || sale.updatedAt.isAfter(latest.updatedAt)) {
        latest = sale;
      }
    }
    return latest;
  }

  /// Libera la escucha del canal compartido de sincronizacion.
  Future<void> dispose() => _syncSubscription.cancel();
}

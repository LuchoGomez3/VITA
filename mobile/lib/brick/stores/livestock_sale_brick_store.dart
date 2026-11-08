import 'dart:async';
import 'dart:convert';

import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/mappers/livestock_sale_productive_status_mapper.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:logging/logging.dart';

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

/// Store que coordina venta, stock local y resultado de sincronizacion.
class BrickLivestockSaleStore implements LivestockSaleBrickStore {
  BrickLivestockSaleStore._(
    this._repository, {
    required bool enableRemoteSync,
  }) : _enableRemoteSync = enableRemoteSync {
    _syncSubscription = _repository.syncResults.listen(applySyncResult);
    _localSubscription = _repository.localChanges.listen((type) {
      if (type == BrickLivestockSaleModel) unawaited(_resumePendingSales());
    });
  }

  static BrickLivestockSaleStore? _instance;

  final AppBrickRepository _repository;
  final bool _enableRemoteSync;
  late final StreamSubscription<BackendSyncResult> _syncSubscription;
  late final StreamSubscription<Type> _localSubscription;
  final _enqueuedSaleIds = <String>{};
  static final _logger = Logger('LivestockSaleStore');
  static const _registrationRejected = 'animal_registration_rejected';

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
        if (animal.productiveStatus != BrickAnimalProductiveStatus.active) {
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
        pendingAnimalIdsJson: jsonEncode([
          for (final animal in selectedAnimals)
            if (animal.syncStatus != BrickAnimalSyncStatus.synchronized) animal.localId,
        ]),
      )..primaryKey = existingSale?.primaryKey ?? sale.primaryKey;
      final savedSale = await transaction.upsert(pendingSale);

      for (final animal in selectedAnimals) {
        // Venta y baja de stock comparten la transaccion: nunca puede quedar la
        // venta guardada con los animales todavia activos, ni al reves.
        await transaction.upsert(
          animal.copyWith(
            productiveStatus: BrickAnimalProductiveStatus.sold,
            productiveStatusChangedAt: saleProductiveStatusChangedAt(sale.operationDate),
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
    unawaited(_resumePendingSales());
    return saved;
  }

  /// Reanuda pendientes persistidos despues de restaurar la sesion y el tenant.
  Future<void> pushPendingSales(String establishmentId) => _resumePendingSales(establishmentId: establishmentId);

  Future<void> _resumePendingSales({String? establishmentId}) async {
    if (!_enableRemoteSync) return;
    try {
      final sales = await _repository.getLocal<BrickLivestockSaleModel>();
      for (final sale in sales) {
        if (sale.deletedAt != null ||
            (establishmentId != null && sale.establishmentId != establishmentId) ||
            sale.syncStatus != BrickLivestockSaleSyncStatus.pending ||
            (jsonDecode(sale.pendingAnimalIdsJson) as List<Object?>).isNotEmpty ||
            !_enqueuedSaleIds.add(sale.localId)) {
          continue;
        }
        // Brick persiste el request antes de enviarlo. En esta instancia se
        // encola una sola vez; los 5xx quedan a cargo de su cola durable.
        unawaited(_repository.enqueueRemoteUpsert(sale));
      }
    } on Object catch (error, stackTrace) {
      _logger.severe('No se pudieron reanudar las ventas pendientes.', error.runtimeType, stackTrace);
    }
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
            productiveStatus: BrickAnimalProductiveStatus.sold,
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
  Future<void> dispose() async {
    await _syncSubscription.cancel();
    await _localSubscription.cancel();
    if (identical(_instance, this)) _instance = null;
  }
}

/// Concilia un alta dependiente en la misma transaccion que su animal.
/// Devuelve true si el estado visible del animal pertenece a una venta local.
Future<bool> reconcileLivestockSaleRegistrationResult(
  AppBrickTransaction transaction,
  BackendSyncResult result,
) async {
  final sales = await transaction.getLocal<BrickLivestockSaleModel>();
  final animals = BrickLivestockSaleStore._latestAnimalsById(await transaction.getLocal<BrickAnimalModel>());
  var owned = false;
  for (final sale in sales) {
    if (sale.deletedAt != null) continue;
    final ids = BrickLivestockSaleStore._decodeAnimalIds(sale.animalIdsJson);
    if (!ids.contains(result.localId)) continue;
    owned = true;
    final dependencies = (jsonDecode(sale.pendingAnimalIdsJson) as List<Object?>).cast<String>().toSet();
    if (!dependencies.contains(result.localId)) continue;
    if (result.synchronized) dependencies.remove(result.localId);
    final updatedSale = sale.copyWith(
      pendingAnimalIdsJson: jsonEncode(dependencies.toList()),
      syncStatus: result.synchronized ? sale.syncStatus : BrickLivestockSaleSyncStatus.rejected,
      syncErrorCode: result.synchronized ? sale.syncErrorCode : BrickLivestockSaleStore._registrationRejected,
    );
    await transaction.upsert(updatedSale);
    for (final id in ids) {
      final animal = animals[id];
      if (animal == null) continue;
      await transaction.upsert(
        animal.copyWith(
          productiveStatus: BrickAnimalProductiveStatus.sold,
          syncStatus: updatedSale.syncStatus == BrickLivestockSaleSyncStatus.rejected
              ? BrickAnimalSyncStatus.rejected
              : BrickAnimalSyncStatus.pending,
          syncErrorCode: updatedSale.syncErrorCode,
        ),
      );
    }
  }
  return owned;
}

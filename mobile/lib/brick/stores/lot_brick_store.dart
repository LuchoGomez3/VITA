import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';

/// Acceso local a lotes sin encolar requests remotos en la Fase 2.
abstract class LotBrickStore {
  /// Inserta o actualiza el lote solamente en SQLite.
  Future<BrickLotModel> upsertLocalLot(BrickLotModel lot);

  /// Lista los lotes locales vigentes del establecimiento.
  Future<List<BrickLotModel>> getLocalLots(String establishmentId);

  /// Busca un lote local vigente por UUID.
  Future<BrickLotModel?> getLocalLot(String lotId);
}

/// Implementación Brick de persistencia durable local.
class BrickLotStore implements LotBrickStore {
  BrickLotStore._(this._repository);

  static BrickLotStore? _instance;
  final AppBrickRepository _repository;

  /// Instancia configurada durante el bootstrap.
  static BrickLotStore get instance => _instance ?? (throw StateError('BrickLotStore has not been initialized yet.'));

  /// Registra el repositorio Brick compartido.
  static void configure(AppBrickRepository repository) {
    _instance ??= BrickLotStore._(repository);
  }

  @override
  Future<BrickLotModel> upsertLocalLot(BrickLotModel lot) => _repository.upsertLocal(lot);

  @override
  Future<List<BrickLotModel>> getLocalLots(String establishmentId) async {
    final stored = await _repository.getLocal<BrickLotModel>();
    return selectLocalLots(stored, establishmentId: establishmentId);
  }

  @override
  Future<BrickLotModel?> getLocalLot(String lotId) async {
    final stored = await _repository.getLocal<BrickLotModel>();
    final matches = stored.where((lot) => lot.localId == lotId).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return matches.first.deletedAt == null ? matches.first : null;
  }

  /// Deduplica por UUID, filtra tombstones y conserva aislamiento tenant.
  static List<BrickLotModel> selectLocalLots(
    Iterable<BrickLotModel> stored, {
    required String establishmentId,
  }) {
    final byId = <String, BrickLotModel>{};
    for (final lot in stored.where((item) => item.establishmentId == establishmentId)) {
      final current = byId[lot.localId];
      if (current == null || lot.updatedAt.isAfter(current.updatedAt)) {
        byId[lot.localId] = lot;
      }
    }
    return byId.values.where((lot) => lot.deletedAt == null).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}

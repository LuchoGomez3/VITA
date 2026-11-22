import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/feeding_record.model.dart';
import 'package:frontend_mayoral/brick/models/food.model.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/models/lot_forage_period.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_activity.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

/// Lee de SQLite los registros que el backend rechazó.
///
/// Brick borra de la cola una request rechazada (4xx) y cada store marca el
/// modelo como `rejected`, así que ese estado es la única huella del rechazo
/// y sobrevive a reiniciar la app.
class BrickRejectedRecordsReader {
  /// Crea el lector sobre el repositorio Brick compartido.
  const BrickRejectedRecordsReader(this._repository);

  final AppBrickRepository _repository;

  /// Devuelve los rechazados de todos los modelos sync-ables, el más reciente
  /// primero.
  Future<List<SyncRejectedRecord>> read() async {
    final results = await Future.wait([
      _rejected<BrickAnimalModel>(
        isRejected: (model) => model.syncStatus == BrickAnimalSyncStatus.rejected,
        toRecord: (model) => _record(model.localId, SyncOperationKind.animal, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickPesajeModel>(
        isRejected: (model) => model.syncStatus == BrickPesajeSyncStatus.rejected,
        toRecord: (model) => _record(model.localId, SyncOperationKind.weighing, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickAnimalLotMovementModel>(
        isRejected: (model) => model.syncStatus == BrickAnimalLotMovementSyncStatus.rejected,
        toRecord: (model) =>
            _record(model.localId, SyncOperationKind.lotMovement, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickLotModel>(
        isRejected: (model) => model.syncStatus == BrickLotSyncStatus.rejected,
        toRecord: (model) => _record(model.localId, SyncOperationKind.lot, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickOperatingExpenseModel>(
        isRejected: (model) => model.syncStatus == BrickOperatingExpenseSyncStatus.rejected,
        toRecord: (model) =>
            _record(model.localId, SyncOperationKind.operatingExpense, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickOperatingExpenseCategoryModel>(
        isRejected: (model) => model.syncStatus == BrickOperatingExpenseCategorySyncStatus.rejected,
        toRecord: (model) =>
            _record(model.localId, SyncOperationKind.operatingExpenseCategory, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickFoodModel>(
        isRejected: (model) => model.syncStatus == BrickFoodSyncStatus.rejected,
        toRecord: (model) => _record(model.localId, SyncOperationKind.food, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickFeedingRecordModel>(
        isRejected: (model) => model.syncStatus == BrickFeedingRecordSyncStatus.rejected,
        toRecord: (model) =>
            _record(model.localId, SyncOperationKind.feedingRecord, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickLotForagePeriodModel>(
        isRejected: (model) => model.syncStatus == BrickLotForagePeriodSyncStatus.rejected,
        toRecord: (model) =>
            _record(model.localId, SyncOperationKind.foragePeriod, model.updatedAt, model.syncErrorCode),
      ),
      _rejected<BrickLivestockSaleModel>(
        isRejected: (model) => model.syncStatus == BrickLivestockSaleSyncStatus.rejected,
        toRecord: (model) =>
            _record(model.localId, SyncOperationKind.livestockSale, model.updatedAt, model.syncErrorCode),
      ),
    ]);
    return results.expand((records) => records).toList()..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Future<List<SyncRejectedRecord>> _rejected<TModel extends OfflineFirstWithRestModel>({
    required bool Function(TModel model) isRejected,
    required SyncRejectedRecord Function(TModel model) toRecord,
  }) async {
    final models = await _repository.getLocal<TModel>();
    return models.where(isRejected).map(toRecord).toList(growable: false);
  }

  static SyncRejectedRecord _record(String localId, SyncOperationKind kind, DateTime recordedAt, String? errorCode) =>
      SyncRejectedRecord(localId: localId, kind: kind, recordedAt: recordedAt, errorCode: errorCode);
}

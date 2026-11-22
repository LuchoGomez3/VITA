import 'package:frontend_mayoral/brick/models/lot_forage_period.model.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_forage_period.dart';

/// Traduce entre el período de dominio y su modelo Brick.
class LotForagePeriodBrickMapper {
  const LotForagePeriodBrickMapper._();

  /// Convierte el período de dominio para persistirlo.
  static BrickLotForagePeriodModel toBrick(LotForagePeriod period) => BrickLotForagePeriodModel(
    localId: period.id,
    establishmentId: period.establishmentId,
    lotId: period.lotId,
    forageResourceCode: period.resourceCode,
    description: period.description,
    startDate: formatDate(period.startDate),
    endDate: period.endDate == null ? null : formatDate(period.endDate!),
    createdAt: period.createdAt,
    updatedAt: period.updatedAt,
    deletedAt: period.deletedAt,
  );

  /// Recupera el período de dominio desde SQLite.
  static LotForagePeriod fromBrick(BrickLotForagePeriodModel model) => LotForagePeriod(
    id: model.localId,
    establishmentId: model.establishmentId,
    lotId: model.lotId,
    resourceCode: model.forageResourceCode,
    description: model.description,
    startDate: parseDate(model.startDate),
    endDate: model.endDate == null ? null : parseDate(model.endDate!),
    syncStatus: switch (model.syncStatus) {
      BrickLotForagePeriodSyncStatus.pending => LotSyncStatus.pending,
      BrickLotForagePeriodSyncStatus.synchronized => LotSyncStatus.synchronized,
      BrickLotForagePeriodSyncStatus.rejected => LotSyncStatus.rejected,
    },
    syncErrorCode: model.syncErrorCode,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
    deletedAt: model.deletedAt,
  );

  /// Día calendario como `yyyy-MM-dd`, sin pasar por UTC.
  static String formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Interpreta `yyyy-MM-dd` como un día local.
  static DateTime parseDate(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }
}

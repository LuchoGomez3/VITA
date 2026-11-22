import 'dart:convert';

import 'package:frontend_mayoral/brick/models/feeding_record.model.dart';
import 'package:frontend_mayoral/brick/models/food.model.dart';
import 'package:frontend_mayoral/features/feeding/domain/entities/feeding_entities.dart';

/// Traduce entre el dominio de alimentación y los modelos Brick.
abstract final class FeedingBrickMapper {
  /// Alimento del catálogo.
  static Food foodFromBrick(BrickFoodModel model) => Food(
    id: model.localId,
    name: model.name,
    categoryCode: model.category,
    unitCode: model.unit,
    isGlobal: model.establishmentId == null,
  );

  /// Alimento nuevo dado de alta en el formulario.
  static BrickFoodModel foodToBrick(Food food, {required String establishmentId, required DateTime timestamp}) =>
      BrickFoodModel(
        localId: food.id,
        establishmentId: establishmentId,
        name: food.name,
        category: food.categoryCode,
        unit: food.unitCode,
        createdAt: timestamp,
        updatedAt: timestamp,
      );

  /// Registro listo para guardar y sincronizar.
  static BrickFeedingRecordModel recordToBrick(FeedingRecord record) => BrickFeedingRecordModel(
    localId: record.id,
    establishmentId: record.establishmentId,
    type: record.type.code,
    foodId: record.foodId,
    lotId: record.lotId,
    startDate: formatDate(record.startDate),
    endDate: record.endDate == null ? null : formatDate(record.endDate!),
    quantity: record.quantity,
    unit: record.unitCode,
    quantityBasis: record.basis.code,
    reason: record.reason,
    animalIdsJson: jsonEncode(record.animalIds),
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  );

  /// Entrada del historial a partir de un registro guardado.
  static SupplementEntry toSupplementEntry(BrickFeedingRecordModel model, {String? foodName, String? lotName}) =>
      SupplementEntry(
        recordId: model.localId,
        type: FeedingType.fromCode(model.type),
        foodName: foodName ?? 'Alimento',
        quantity: model.quantity,
        unitCode: model.unit,
        basis: FeedingQuantityBasis.fromCode(model.quantityBasis),
        from: parseDate(model.startDate),
        to: model.endDate == null ? null : parseDate(model.endDate!),
        lotName: lotName,
        reason: model.reason,
        syncStatus: switch (model.syncStatus) {
          BrickFeedingRecordSyncStatus.pending => FeedingSyncStatus.pending,
          BrickFeedingRecordSyncStatus.synchronized => FeedingSyncStatus.synchronized,
          BrickFeedingRecordSyncStatus.rejected => FeedingSyncStatus.rejected,
        },
        syncErrorCode: model.syncErrorCode,
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

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_lot_movement.model.dart';
import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

/// Traduce el path de una request sync-able al tipo de operación que ve el
/// productor.
///
/// Usa las constantes `*RequestTransformer.*Path` de los modelos Brick, así
/// un cambio de endpoint no deja la pantalla desactualizada. Sin [method] (por
/// ejemplo, en una respuesta del backend) un animal se informa como
/// [SyncOperationKind.animal], porque no se sabe si fue un alta o un cambio.
SyncOperationKind syncOperationKindFor(String path, {String? method}) {
  bool under(String resource) => path == resource || path.startsWith('$resource/');

  // El orden importa: las categorías cuelgan del path de egresos.
  if (under(BrickOperatingExpenseCategoryRequestTransformer.categoriesPath)) {
    return SyncOperationKind.operatingExpenseCategory;
  }
  if (under(BrickOperatingExpenseRequestTransformer.expensesPath)) return SyncOperationKind.operatingExpense;
  if (under(BrickAnimalLotMovementRequestTransformer.movementsPath)) return SyncOperationKind.lotMovement;
  if (under(BrickLotRequestTransformer.lotsPath)) return SyncOperationKind.lot;
  if (under(BrickPesajeRequestTransformer.weighingsPath)) return SyncOperationKind.weighing;
  if (under(BrickAnimalRequestTransformer.animalsPath)) {
    return switch (method) {
      'POST' => SyncOperationKind.animalRegistration,
      null => SyncOperationKind.animal,
      _ => SyncOperationKind.animalUpdate,
    };
  }
  return SyncOperationKind.other;
}

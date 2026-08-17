import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';

/// Traduce egresos entre dominio y persistencia Brick.
class OperatingExpenseBrickMapper {
  const OperatingExpenseBrickMapper._();

  /// Convierte centavos enteros a decimal canonico de dos posiciones.
  static String amountToDecimal(int cents) {
    final absolute = cents.abs();
    final sign = cents < 0 ? '-' : '';
    return '$sign${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
  }

  /// Convierte un decimal backend sin pasar por punto flotante.
  static int decimalToCents(String amount) {
    final normalized = amount.trim().replaceAll(',', '.');
    final parts = normalized.split('.');
    final whole = int.parse(parts.first);
    final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0').substring(0, 2);
    return whole * 100 + (whole < 0 ? -int.parse(fraction) : int.parse(fraction));
  }

  /// Convierte la entidad en modelo tecnico.
  static BrickOperatingExpenseModel toBrick(OperatingExpense expense) => BrickOperatingExpenseModel(
    localId: expense.id,
    establishmentId: expense.establishmentId,
    amount: amountToDecimal(expense.amountCents),
    type: expense.type.value,
    category: expense.category,
    supply: expense.supply,
    date: expense.date,
    description: expense.description,
    receiptNumber: expense.receiptNumber,
    loadedById: expense.loadedById,
    loadedByName: expense.loadedByName,
    createdAt: expense.createdAt,
    updatedAt: expense.updatedAt,
    customCategoryId: expense.customCategoryId,
    syncStatus: switch (expense.syncStatus) {
      OperatingExpenseSyncStatus.pending => BrickOperatingExpenseSyncStatus.pending,
      OperatingExpenseSyncStatus.synchronized => BrickOperatingExpenseSyncStatus.synchronized,
      OperatingExpenseSyncStatus.rejected => BrickOperatingExpenseSyncStatus.rejected,
    },
    syncErrorCode: expense.syncErrorCode,
  );

  /// Convierte el modelo persistido en entidad de dominio.
  static OperatingExpense fromBrick(BrickOperatingExpenseModel model) => OperatingExpense(
    id: model.localId,
    establishmentId: model.establishmentId,
    amountCents: decimalToCents(model.amount),
    type: OperatingExpenseType.values.firstWhere((type) => type.value == model.type),
    category: model.category,
    supply: model.supply,
    date: model.date,
    description: model.description,
    receiptNumber: model.receiptNumber,
    loadedById: model.loadedById,
    loadedByName: model.loadedByName,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
    customCategoryId: model.customCategoryId,
    syncStatus: switch (model.syncStatus) {
      BrickOperatingExpenseSyncStatus.pending => OperatingExpenseSyncStatus.pending,
      BrickOperatingExpenseSyncStatus.synchronized => OperatingExpenseSyncStatus.synchronized,
      BrickOperatingExpenseSyncStatus.rejected => OperatingExpenseSyncStatus.rejected,
    },
    syncErrorCode: model.syncErrorCode,
  );
}

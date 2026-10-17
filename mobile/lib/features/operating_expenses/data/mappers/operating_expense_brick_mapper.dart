import 'package:frontend_mayoral/brick/models/operating_expense.model.dart';
import 'package:frontend_mayoral/core/formatters/decimal_amount_formatter.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/models/operating_expense_remote_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';

/// Traduce egresos entre dominio y persistencia Brick.
class OperatingExpenseBrickMapper {
  const OperatingExpenseBrickMapper._();

  /// Convierte centavos enteros a decimal canonico de dos posiciones.
  static String amountToDecimal(int cents) => DecimalAmountFormatter.centsToDecimal(cents);

  /// Convierte un decimal backend sin pasar por punto flotante.
  static int decimalToCents(String amount) => DecimalAmountFormatter.decimalToCents(amount);

  /// Convierte el contrato HTTP validado en un modelo tecnico de cache.
  static BrickOperatingExpenseModel fromRemote(
    OperatingExpenseRemoteDto expense,
  ) => BrickOperatingExpenseModel(
    localId: expense.id,
    establishmentId: expense.establishmentId,
    amount: expense.amount,
    type: expense.type,
    category: expense.category,
    supply: expense.supply,
    date: expense.date,
    description: expense.description,
    receiptNumber: expense.receiptNumber,
    loadedById: expense.loadedById,
    loadedByName: _loadedByName(expense.loadedBy),
    createdAt: expense.createdAt,
    updatedAt: expense.updatedAt,
    deletedAt: expense.deletedAt,
    syncStatus: BrickOperatingExpenseSyncStatus.synchronized,
  );

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

  static String? _loadedByName(OperatingExpenseRemoteUserDto? user) {
    if (user == null) return null;
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    return fullName.isEmpty ? user.email : fullName;
  }
}

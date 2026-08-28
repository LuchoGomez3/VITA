import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_failure_messages.dart';

/// Textos centralizados de egresos operativos.
class OperatingExpenseStrings {
  const OperatingExpenseStrings._();
  static const title = 'Registrar egreso operativo';
  static const register = 'Registrar egreso';
  static const establishment = 'Establecimiento activo';
  static const requiredEstablishment = 'Seleccioná un establecimiento activo para registrar egresos.';
  static const amount = 'Monto';
  static const type = 'Tipo de egreso';
  static const category = 'Categoría';
  static const addCategory = 'Agregar categoría';
  static const cancel = 'Cancelar';
  static const add = 'Agregar';
  static const categoryName = 'Nombre de la categoría';
  static const supply = 'Producto o servicio';
  static const date = 'Fecha';
  static const description = 'Descripción o concepto (opcional)';
  static const receipt = 'Número de comprobante/factura (opcional)';
  static const save = 'Guardar egreso';
  static const successTitle = 'Egreso registrado';
  static const savingTitle = 'Guardando egreso';
  static const savingMessage = 'Estamos guardando el egreso y verificando su sincronización.';
  static const cloudSuccessMessage = 'El egreso se guardó correctamente en la nube.';
  static const localSuccessMessage =
      'El egreso quedó guardado en este dispositivo y se sincronizará cuando haya conexión.';
  static const rejectedMessage =
      'El egreso quedó guardado en este dispositivo, pero el servidor rechazó la sincronización.';
  static const summary = 'Resumen del egreso';
  static const concept = 'Concepto';
  static const receiptSummary = 'Comprobante';
  static const addAnotherExpense = 'Agregar otro gasto';
  static const backHome = 'Volver a la pantalla principal';
  static const invalidAmount = 'El monto ingresado debe ser un valor mayor a cero';
  static const futureDate = 'No se pueden registrar egresos con fecha futura';
  static const requiredSupply = 'El producto o servicio es obligatorio';
  static const requiredCategory = 'La categoría es obligatoria';
  static const requiredCategoryName = 'El nombre de la categoría es obligatorio';
  static const incompatibleCategory = 'La categoría no corresponde al tipo de egreso seleccionado';
  static const saveError = 'No se pudo guardar el egreso en el dispositivo.';
  static const saveCategoryError = 'No se pudo guardar la categoría en el dispositivo.';
  static const loadCategoriesError = 'No se pudieron leer las categorías disponibles.';
  static const historyTitle = 'Movimientos';
  static const expensesTab = 'Egresos';
  static const incomeTab = 'Ingresos';
  static const incomeComingSoon = 'Los ingresos operativos se implementarán en una próxima etapa.';
  static const totalExpenses = 'Total';
  static const records = 'registros encontrados';
  static const oneRecord = 'registro encontrado';
  static const exportCsv = 'Exportar CSV';
  static const exportSuccess = 'Archivo listo para guardar o compartir.';
  static const exportError = 'No se pudo exportar el archivo. Reintentá cuando tengas conexión.';
  static const exportPendingWarning =
      'La exportación requiere conexión y no incluye egresos pendientes de sincronización.';
  static const filters = 'Filtros';
  static const dateRange = 'Rango de fechas';
  static const dateFrom = 'Desde';
  static const dateTo = 'Hasta';
  static const dateHint = 'Fecha';
  static const currentMonth = 'Mes actual';
  static const lastQuarter = 'Último trimestre';
  static const customRange = 'Rango personalizado';
  static const allHistory = 'Todo el historial';
  static const allTypes = 'Todos';
  static const administrativeType = 'Administrativo';
  static const productiveType = 'Productivo';
  static const allCategories = 'Todas';
  static const clearFilters = 'Limpiar filtros';
  static const retry = 'Reintentar';
  static const pendingSync = 'Pendiente de sincronización';
  static const pendingSummary = 'Hay egresos pendientes de sincronización';
  static const totalIncludesPending = 'El total incluye registros pendientes.';
  static const cachedWithoutConnection = 'Mostrando datos guardados sin conexión.';
  static const emptyHistory = 'Todavía no hay egresos registrados';
  static const emptyFilters = 'No encontramos egresos para los filtros seleccionados';
  static const loadHistoryError = 'No se pudo cargar el historial de egresos.';
  static const remoteError = OperatingExpenseFailureMessages.remote;
  static const offlineMessage = OperatingExpenseFailureMessages.offline;
  static const sessionExpired = OperatingExpenseFailureMessages.sessionExpired;
  static const accessDenied = OperatingExpenseFailureMessages.accessDenied;
  static const conceptLabel = 'Concepto del egreso';
  static const registeredBy = 'Registrado por';
  static const receiptLabel = 'Comprobante';
  static const descriptionLabel = 'Descripción';
  static const unknownRegistrant = 'Usuario no disponible';

  /// Traduce un error de validacion del dominio al texto que vera el usuario.
  static String validationError(OperatingExpenseValidationError error) => switch (error) {
    OperatingExpenseValidationError.invalidAmount => invalidAmount,
    OperatingExpenseValidationError.futureDate => futureDate,
    OperatingExpenseValidationError.requiredSupply => requiredSupply,
    OperatingExpenseValidationError.requiredCategory => requiredCategory,
    OperatingExpenseValidationError.requiredCategoryName => requiredCategoryName,
    OperatingExpenseValidationError.incompatibleCategory => incompatibleCategory,
  };

  /// Traduce una falla esperada de persistencia a un mensaje funcional.
  static String persistenceError(OperatingExpensePersistenceError error) => switch (error) {
    OperatingExpensePersistenceError.saveExpense => saveError,
    OperatingExpensePersistenceError.saveCategory => saveCategoryError,
    OperatingExpensePersistenceError.loadCategories => loadCategoriesError,
    OperatingExpensePersistenceError.loadHistory => loadHistoryError,
    OperatingExpensePersistenceError.refreshHistory => remoteError,
    OperatingExpensePersistenceError.exportOffline => exportPendingWarning,
    OperatingExpensePersistenceError.financialAccessDenied => accessDenied,
    OperatingExpensePersistenceError.exportFailed => exportError,
  };

  /// Etiqueta visible para cada periodo.
  static String periodLabel(OperatingExpensePeriod period) => switch (period) {
    OperatingExpensePeriod.currentMonth => currentMonth,
    OperatingExpensePeriod.lastQuarter => lastQuarter,
    OperatingExpensePeriod.custom => customRange,
    OperatingExpensePeriod.allHistory => allHistory,
  };
}

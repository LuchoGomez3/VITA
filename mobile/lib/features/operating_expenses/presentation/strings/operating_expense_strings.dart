import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';

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
  static const supply = 'Insumo';
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
  static const requiredSupply = 'El insumo es obligatorio';
  static const requiredCategory = 'La categoría es obligatoria';
  static const requiredCategoryName = 'El nombre de la categoría es obligatorio';
  static const incompatibleCategory = 'La categoría no corresponde al tipo de egreso seleccionado';
  static const saveError = 'No se pudo guardar el egreso en el dispositivo.';
  static const saveCategoryError = 'No se pudo guardar la categoría en el dispositivo.';
  static const loadCategoriesError = 'No se pudieron leer las categorías disponibles.';

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
  };
}

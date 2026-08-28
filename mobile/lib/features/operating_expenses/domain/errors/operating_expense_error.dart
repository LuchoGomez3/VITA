/// Errores funcionales que puede detectar la validacion de un egreso.
enum OperatingExpenseValidationError {
  /// El importe no representa un valor positivo.
  invalidAmount,

  /// La fecha seleccionada es posterior al dia actual.
  futureDate,

  /// El insumo no fue informado.
  requiredSupply,

  /// La categoria no fue seleccionada.
  requiredCategory,

  /// El nombre de una categoria personalizada esta vacio.
  requiredCategoryName,

  /// La categoria no pertenece al tipo de egreso elegido.
  incompatibleCategory,
}

/// Fallas esperadas de persistencia que la presentacion puede comunicar.
enum OperatingExpensePersistenceError {
  /// No fue posible persistir el egreso localmente.
  saveExpense,

  /// No fue posible persistir una categoria personalizada.
  saveCategory,

  /// No fue posible recuperar el catalogo disponible.
  loadCategories,

  /// No fue posible leer el historial local.
  loadHistory,

  /// No fue posible actualizar el historial central.
  refreshHistory,

  /// La exportacion requiere conectividad.
  exportOffline,

  /// El backend rechazo el acceso financiero.
  financialAccessDenied,

  /// No fue posible generar o descargar el CSV.
  exportFailed,
}

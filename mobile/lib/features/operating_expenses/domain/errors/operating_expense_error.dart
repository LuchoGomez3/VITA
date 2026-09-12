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

/// Fallas funcionales que pueden atravesar las capas de la feature.
enum OperatingExpenseFailure {
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

  /// La operacion requiere conectividad.
  offline,

  /// La sesion no permite continuar la operacion.
  unauthorized,

  /// El backend rechazo el acceso financiero.
  accessDenied,

  /// El backend devolvio datos que no cumplen el contrato.
  invalidResponse,

  /// El backend no pudo completar la operacion.
  remote,

  /// No fue posible generar o descargar el CSV.
  exportFailed,
}

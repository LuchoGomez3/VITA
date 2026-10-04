/// Causas estructuradas que presentacion traduce a mensajes para el usuario.
enum LivestockSaleError {
  /// El establecimiento no esta disponible.
  requiredEstablishment,

  /// La fecha de operacion es futura.
  futureOperationDate,

  /// Falta nombre o razon social.
  requiredBuyerName,

  /// El nombre de persona contiene caracteres no admitidos.
  invalidBuyerName,

  /// Una persona fisica no tiene apellido.
  requiredBuyerLastName,

  /// El apellido contiene caracteres no admitidos.
  invalidBuyerLastName,

  /// Se informo apellido para una empresa.
  companyWithLastName,

  /// El DTe esta vacio o contiene caracteres no numericos.
  invalidDteNumber,

  /// No hay animales seleccionados o sus UUID estan repetidos.
  invalidAnimals,

  /// Uno de los animales ya no existe localmente.
  animalNotFound,

  /// Uno de los animales pertenece a otro establecimiento.
  differentEstablishment,

  /// Uno de los animales ya no esta disponible para vender.
  animalNotActive,

  /// El total debe ser positivo y caber en la precision del backend.
  invalidTotalAmount,

  /// Una venta al bulto contiene peso o precio unitario.
  bulkWithUnitValues,

  /// Una venta por kilo no tiene peso comercial valido.
  invalidTotalWeight,

  /// Una venta por kilo no tiene precio unitario valido.
  invalidPricePerKg,

  /// El total no coincide con peso por precio unitario.
  inconsistentCalculatedTotal,

  /// Falta cobro inicial para una venta total o parcial.
  requiredInitialPayment,

  /// Una venta pendiente contiene un cobro inicial.
  pendingWithInitialPayment,

  /// El importe cobrado no respeta la condicion seleccionada.
  invalidInitialPaymentAmount,

  /// La fecha del cobro es futura.
  futureInitialPaymentDate,

  /// SQLite no pudo guardar la operacion atomica.
  localSave,

  /// Un valor persistido no coincide con el contrato conocido.
  invalidStoredData,
}

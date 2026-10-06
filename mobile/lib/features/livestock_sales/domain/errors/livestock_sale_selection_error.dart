/// Causas funcionales por las que un animal no puede sumarse a una venta.
enum LivestockSaleSelectionError {
  /// La caravana no tiene exactamente 15 digitos numericos.
  invalidRfid,

  /// No existe un animal local con esa caravana.
  animalNotFound,

  /// El animal pertenece a otro establecimiento.
  differentEstablishment,

  /// El animal ya fue vendido.
  animalSold,

  /// El animal fue registrado como muerto.
  animalDead,

  /// El animal fue dado de baja por otro motivo.
  animalRemoved,

  /// El dispositivo no conoce un estado productivo confiable.
  animalStatusUnknown,

  /// El animal ya forma parte de la seleccion actual.
  duplicateAnimal,

  /// No se pudo consultar el inventario guardado en el dispositivo.
  localRead,
}

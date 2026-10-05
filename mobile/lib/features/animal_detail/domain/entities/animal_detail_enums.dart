// Hoy estos tipos se definen dentro de `animal_detail` para evitar que esta
// feature dependa de `animal_register`. Cuando crezcan mas flujos sobre
// animales (edicion, RFID, sanidad, alimentacion), conviene evaluar una feature
// padre `animal` o un dominio compartido para no duplicar estos conceptos.

/// Sexo del animal dentro del dominio mobile.
enum AnimalSex {
  /// Animal macho.
  male,

  /// Animal hembra.
  female,
}

/// Metodo usado para obtener el peso del animal.
enum AnimalWeighingMethod {
  /// Peso ingresado manualmente.
  manual,

  /// Peso recibido desde una balanza Bluetooth.
  bluetoothScale,

  /// Peso estimado por un modelo local en el dispositivo.
  artificialIntelligence,
}

/// Estado de sincronizacion del animal guardado en el dispositivo.
enum AnimalSyncStatus {
  /// Guardado localmente y pendiente de llegar al backend.
  pending,

  /// Confirmado por el backend.
  synchronized,

  /// Rechazado por el backend y pendiente de revision del usuario.
  rejected,
}

/// Estado de negocio del animal, separado de su estado de sincronización.
enum AnimalStatus {
  /// Animal disponible para operaciones productivas.
  active,

  /// Animal comercializado.
  sold,

  /// Baja por muerte, reversible como corrección desde la ficha.
  dead,

  /// Otra baja administrativa.
  inactive,
}

/// Condición reproductiva validada según sexo y reglas de categoría.
enum AnimalReproductiveStatus {
  /// Todavía no se registró una condición conocida.
  undetermined,

  /// Hembra confirmada sin preñez.
  empty,

  /// Hembra confirmada preñada.
  pregnant,
}

/// Motivos de validación que presentation traduce a mensajes para el usuario.
enum AnimalDetailEditFailure {
  /// Peso no finito o no positivo.
  invalidWeight,

  /// Nota sin contenido.
  emptyObservation,

  /// Operación productiva sobre un animal dado de baja o vendido.
  inactiveAnimal,

  /// Categoría que no pertenece al catálogo o no admite el sexo.
  incompatibleCategory,

  /// Condición incompatible con el sexo o las reglas de categoría.
  reproductionNotAllowed,

  /// Animal ausente de la caché tras la carga de la ficha.
  animalNotFound,

  /// La baja ya cambió y no corresponde sobrescribirla con un deshacer viejo.
  staleUndo,

  /// Error al guardar el cambio local.
  saveFailed,
}

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

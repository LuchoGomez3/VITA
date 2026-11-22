/// Fuente de lecturas RFID independiente del transporte que las entrega.
///
/// La implementacion inicial recibe teclas HID de un baston emparejado por el
/// sistema operativo. Implementaciones futuras pueden entregar el mismo stream
/// desde BLE o Bluetooth serial sin cambiar el flujo de identificacion.
abstract class RfidReadingSource {
  /// Stream de lecturas completas, aun sin validar por reglas de negocio.
  Stream<String> get readings;

  /// Indica si la fuente esta aceptando una nueva lectura.
  bool get isReading;

  /// Comienza a aceptar lecturas.
  Future<void> startReading();

  /// Deja de aceptar lecturas y descarta cualquier dato parcial.
  Future<void> stopReading();

  /// Libera los recursos asociados a la fuente.
  Future<void> dispose();
}

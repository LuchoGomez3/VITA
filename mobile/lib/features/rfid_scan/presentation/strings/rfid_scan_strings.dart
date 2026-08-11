/// Textos de la pantalla de identificacion mediante caravana RFID.
class RfidScanStrings {
  const RfidScanStrings._();

  static const pageTitle = 'Identificar animal';
  static const methodQuestion = '¿Cómo querés identificarlo?';
  static const methodDescription = 'Usá el bastón RFID o ingresá la caravana manualmente.';
  static const idleTitle = 'Listo para identificar';
  static const idleDescription = 'Iniciá la lectura y acercá el bastón a la caravana electrónica.';
  static const startReading = 'Iniciar lectura';
  static const manualEntryTitle = 'O ingresá la caravana manualmente';
  static const manualEntryHint = '15 dígitos RFID';
  static const searchManualRfid = 'Buscar caravana';
  static const cancelReading = 'Cancelar lectura';
  static const listeningTitle = 'Esperando lectura';
  static const listeningDescription = 'Acercá el bastón a la caravana del animal.';
  static const invalidTitle = 'Caravana inválida';
  static const invalidDescription = 'La lectura debe contener exactamente 15 dígitos numéricos.';
  static const notFoundTitle = 'Animal no registrado';
  static const notFoundDescription = 'Esta caravana no está disponible en los datos locales del dispositivo.';
  static const registerAnimal = 'Registrar nuevo animal';
  static const foundTitle = 'Animal identificado';
  static const viewDetail = 'Ver ficha completa';
  static const scanAgain = 'Leer otra caravana';
  static const timeoutTitle = 'No se recibió una lectura';
  static const timeoutDescription = 'Revisá que el bastón esté conectado e intentá nuevamente.';
  static const errorTitle = 'No se pudo identificar el animal';
  static const errorDescription = 'Ocurrió un problema al procesar la lectura local.';
  static const rfidLabel = 'RFID';
  static const visualTagLabel = 'Caravana visual';
  static const breedLabel = 'Raza';
  static const sexLabel = 'Sexo';
  static const categoryLabel = 'Categoría';
  static const lotLabel = 'Lote';
  static const unavailableValue = 'Sin dato';
  static const male = 'Macho';
  static const female = 'Hembra';
}

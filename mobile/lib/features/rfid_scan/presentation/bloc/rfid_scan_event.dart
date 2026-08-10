part of 'rfid_scan_bloc.dart';

/// Eventos que modifican el ciclo de lectura RFID o comunican su resultado.
@freezed
sealed class RfidScanEvent with _$RfidScanEvent {
  /// El usuario inicia una nueva lectura RFID.
  const factory RfidScanEvent.listeningRequested() = _ListeningRequested;

  /// El usuario cancela la lectura actual.
  const factory RfidScanEvent.stopped() = _Stopped;

  /// La fuente HID completo una lectura al recibir Enter.
  const factory RfidScanEvent.readingReceived({
    required String reading,
  }) = _ReadingReceived;

  /// La capa de validacion rechazo la lectura recibida.
  const factory RfidScanEvent.invalidReadingDetected({
    required String reading,
  }) = _InvalidReadingDetected;

  /// La busqueda local encontro un animal para el RFID leido.
  const factory RfidScanEvent.animalFound({
    required IdentifiedAnimal animal,
  }) = _AnimalFound;

  /// La busqueda local no encontro un animal para el RFID leido.
  const factory RfidScanEvent.animalNotFound({
    required String rfid,
  }) = _AnimalNotFound;

  /// No se recibio una lectura antes de vencer el tiempo de espera.
  const factory RfidScanEvent.timeoutElapsed() = _TimeoutElapsed;

  /// La fuente de lecturas informo un error no recuperable desde la UI.
  const factory RfidScanEvent.errorOccurred() = _ErrorOccurred;
}

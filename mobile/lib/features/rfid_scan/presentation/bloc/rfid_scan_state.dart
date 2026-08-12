part of 'rfid_scan_bloc.dart';

/// Estados posibles de la pantalla de identificacion por RFID.
@freezed
sealed class RfidScanState with _$RfidScanState {
  /// Aun no hay una lectura activa.
  const factory RfidScanState.inactive() = _Inactive;

  /// La app esta lista para recibir los caracteres del baston HID.
  const factory RfidScanState.listening() = _Listening;

  /// El valor recibido no cumple las reglas de una caravana RFID.
  const factory RfidScanState.invalid({
    required String reading,
  }) = _Invalid;

  /// La busqueda local encontro un animal asociado a la lectura.
  const factory RfidScanState.found({
    required IdentifiedAnimal animal,
  }) = _Found;

  /// La busqueda local no encontro un animal asociado a la lectura.
  const factory RfidScanState.notFound({
    required String rfid,
  }) = _NotFound;

  /// La fuente no recibio una lectura dentro del tiempo esperado.
  const factory RfidScanState.timeout() = _Timeout;

  /// Ocurrio un error al iniciar o usar la fuente de lecturas.
  const factory RfidScanState.error() = _Error;
}

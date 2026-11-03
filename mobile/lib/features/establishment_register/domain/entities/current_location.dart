import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_location.freezed.dart';

/// Posición del dispositivo leída del GPS.
///
/// Se usa como punto de referencia del establecimiento (paso 3 del registro).
/// El GPS no necesita conexión a internet, así que la lectura funciona igual
/// en el campo sin señal de datos.
@freezed
sealed class CurrentLocation with _$CurrentLocation {
  /// Crea una lectura de ubicación.
  const factory CurrentLocation({
    required double latitud,
    required double longitud,

    /// Radio de error estimado por el GPS, en metros.
    required double precisionMetros,
  }) = _CurrentLocation;
}

/// Motivo por el que no se pudo leer la ubicación.
///
/// Viaja en `DomainException.reason` para que la presentación elija el mensaje
/// sin guardar copy dentro del dominio.
enum CurrentLocationFailure {
  /// El GPS del dispositivo está apagado.
  serviceDisabled,

  /// El usuario negó el permiso de ubicación (se puede volver a pedir).
  permissionDenied,

  /// El permiso quedó negado de forma permanente: sólo se habilita desde los
  /// ajustes del sistema.
  permissionDeniedForever,

  /// El GPS no consiguió una posición dentro del tiempo límite (p. ej. bajo
  /// techo o sin cielo abierto).
  timeout,
}

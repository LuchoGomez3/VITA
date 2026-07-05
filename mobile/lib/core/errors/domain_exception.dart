import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_exception.freezed.dart';

/// Codigos de error de dominio que la UI puede interpretar.
enum DomainErrorCode {
  /// Error no categorizado.
  unknown,

  /// Error de validacion de datos.
  validation,

  /// Recurso inexistente.
  notFound,

  /// Sesion ausente o invalida.
  unauthorized,

  /// Error de conectividad o backend no disponible.
  offline,

  /// Error de sincronizacion offline-first.
  syncFailed,
}

/// Error funcional de dominio compartido por las capas de la app.
@freezed
abstract class DomainException with _$DomainException implements Exception {
  /// Crea un error funcional con mensaje visible para UI.
  const factory DomainException({
    required String message,
    @Default(DomainErrorCode.unknown) DomainErrorCode code,
  }) = _DomainException;
}

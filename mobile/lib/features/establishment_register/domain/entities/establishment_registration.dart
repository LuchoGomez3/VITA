import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';

part 'establishment_registration.freezed.dart';

/// Datos de un establecimiento listos para enviar al backend.
@freezed
sealed class EstablishmentRegistration with _$EstablishmentRegistration {
  /// Crea el request de alta de establecimiento.
  const factory EstablishmentRegistration({
    required String nombre,
    required String descripcion,
    required List<String> tiposProduccion,
    required String cuitTitular,
    required String nroRenspa,
    required String provincia,
    required String departamento,
    required String localidad,
    required double latitud,
    required double longitud,
    required double superficieHectareas,
    required int cantidadVertices,
  }) = _EstablishmentRegistration;
}

/// Establecimiento ya persistido, devuelto al finalizar el alta.
@freezed
sealed class RegisteredEstablishment with _$RegisteredEstablishment {
  /// Crea el resultado de un alta exitosa.
  const factory RegisteredEstablishment({
    required String id,
    required EstablishmentRegistration registration,
    required DateTime createdAt,
    required UserRole role,
  }) = _RegisteredEstablishment;
}

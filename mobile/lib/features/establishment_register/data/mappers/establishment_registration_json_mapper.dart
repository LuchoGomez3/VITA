import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';

/// Mapper JSON del alta de establecimiento contra `/api/v1/establecimientos`.
class EstablishmentRegistrationJsonMapper {
  const EstablishmentRegistrationJsonMapper._();

  /// Arma el body del `POST`, en snake_case (convención de la API).
  ///
  /// No incluye `poligono`: el paso 4 es una réplica visual estática sin
  /// coordenadas reales de vértices (ver
  /// `.claude/specs/registrar-establecimiento.md`), sólo se envía la
  /// superficie ya calculada.
  static Map<String, dynamic> toJson(EstablishmentRegistration registration) {
    return {
      'nombre': registration.nombre,
      'descripcion': registration.descripcion,
      'tipo_produccion': registration.tiposProduccion,
      'cuit': registration.cuitTitular,
      'nro_renspa': registration.nroRenspa,
      'provincia': registration.provincia,
      'departamento': registration.departamento,
      'localidad': registration.localidad,
      'latitud': registration.latitud,
      'longitud': registration.longitud,
      'superficie_ha': registration.superficieHectareas,
    };
  }

  /// Combina la confirmación del backend (`id`, `created_at`) con el registro
  /// ya conocido localmente, para no tener que re-derivar el resto de los
  /// campos desde la respuesta.
  static RegisteredEstablishment registeredFromJson(
    Map<String, dynamic> json,
    EstablishmentRegistration registration,
  ) {
    final id = json['id'];
    final createdAt = json['created_at'];
    if (id is String && id.isNotEmpty && createdAt is String) {
      return RegisteredEstablishment(
        id: id,
        registration: registration,
        createdAt: DateTime.parse(createdAt),
      );
    }

    throw const FormatException(
      'El backend no devolvio un establecimiento valido.',
    );
  }
}

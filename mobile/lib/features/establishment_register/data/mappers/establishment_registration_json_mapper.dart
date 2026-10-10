import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';

/// Mapper JSON del alta de establecimiento contra `/api/v1/establecimientos`.
class EstablishmentRegistrationJsonMapper {
  const EstablishmentRegistrationJsonMapper._();

  /// Arma el body del `POST`, en snake_case (convención de la API).
  ///
  /// `poligono` sólo viaja si se dibujó: si la superficie se cargó a mano, se
  /// omite y el backend lo guarda como nulo. `orden` arranca en 1, igual que
  /// la numeración de vértices que ve el productor. La superficie se redondea
  /// a 2 decimales, la precisión de `superficie_ha` en la base.
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
      'superficie_ha': double.parse(registration.superficieHectareas.toStringAsFixed(2)),
      if (registration.poligono.isNotEmpty)
        'poligono': [
          for (final (index, point) in registration.poligono.indexed)
            {'orden': index + 1, 'latitud': point.latitud, 'longitud': point.longitud},
        ],
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
        role: UserRolePermissions.fromBackend(
          json['rol'] is String ? json['rol'] as String : null,
        ),
      );
    }

    throw const FormatException(
      'El backend no devolvio un establecimiento valido.',
    );
  }
}

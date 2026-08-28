import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';

/// Obtiene de forma segura el rol offline de un establecimiento concreto.
class GetEstablishmentRoleUseCase {
  /// Crea el caso de uso con el catalogo compartido.
  const GetEstablishmentRoleUseCase(this._catalog);

  final EstablishmentCatalog _catalog;

  /// Devuelve `unknown` si el catalogo falta, esta corrupto o no contiene el ID.
  Future<UserRole> call(String establishmentId) async {
    try {
      final membership = await _catalog.getById(establishmentId);
      return membership?.role ?? UserRole.unknown;
    } on Object {
      return UserRole.unknown;
    }
  }
}

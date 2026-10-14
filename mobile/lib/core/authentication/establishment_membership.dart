import 'package:frontend_mayoral/core/authentication/user_role.dart';

/// Membresia de la persona autenticada en un establecimiento.
final class EstablishmentMembership {
  /// Crea una membresia disponible en el catalogo offline.
  const EstablishmentMembership({
    required this.id,
    required this.name,
    required this.role,
  });

  /// Identificador estable del establecimiento.
  final String id;

  /// Nombre visible del establecimiento.
  final String name;

  /// Rol de la persona exclusivamente dentro de este establecimiento.
  final UserRole role;
}

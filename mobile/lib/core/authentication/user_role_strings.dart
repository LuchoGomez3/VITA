import 'package:frontend_mayoral/core/authentication/user_role.dart';

/// Textos visibles centralizados para roles por establecimiento.
abstract final class UserRoleStrings {
  /// Nombre localizado del rol.
  static String name(UserRole role) => switch (role) {
    UserRole.admin => 'Administrador',
    UserRole.owner => 'Dueño',
    UserRole.employee => 'Empleado',
    UserRole.unknown => 'Sin rol asignado',
  };
}

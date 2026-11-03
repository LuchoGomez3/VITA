import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';

/// Textos del manual de usuario. El contenido de cada sección vive en
/// `assets/manual/*.md`.
abstract final class UserManualStrings {
  /// Título de la pantalla.
  static const title = 'Manual de usuario';

  /// Aviso de que el manual está en el celular.
  static const offlineHint = 'Está guardado en el celular: lo podés leer sin señal.';

  /// Explica qué secciones se ven, según los roles de la persona.
  static String rolesHint(Set<UserRole> roles) =>
      roles.isEmpty ? 'Te mostramos las secciones generales.' : 'Te mostramos lo que podés hacer como ${_join(roles)}.';

  /// Etiqueta de una sección que no aplica a todos los roles.
  static String appliesTo(Set<UserRole> roles) => 'Para ${_join(roles)}';

  /// No hay secciones para mostrar.
  static const empty = 'No hay secciones del manual para tu rol.';

  /// No se pudo leer el manual.
  static const loadError = 'No pudimos abrir el manual. Probá de nuevo.';

  /// Reintentar la carga.
  static const retry = 'Reintentar';

  /// Orden fijo para nombrar roles: de más a menos permisos.
  static const List<UserRole> _order = [UserRole.owner, UserRole.admin, UserRole.employee, UserRole.veterinarian];

  static String _join(Set<UserRole> roles) {
    final names = [
      for (final role in _order)
        if (roles.contains(role)) UserRoleStrings.name(role).toLowerCase(),
    ];
    if (names.length <= 1) return names.join();
    return '${names.sublist(0, names.length - 1).join(', ')} y ${names.last}';
  }
}

/// Rol de una persona dentro de un establecimiento concreto.
enum UserRole {
  /// Administrador con acceso financiero.
  admin,

  /// Propietario con acceso financiero.
  owner,

  /// Empleado sin acceso financiero.
  employee,

  /// Rol ausente o no reconocido por esta version de la app.
  unknown,
}

/// Traduccion del contrato backend y reglas de permisos por membresia.
extension UserRolePermissions on UserRole {
  /// Solo administradores y propietarios pueden consultar finanzas.
  bool get canViewFinancialInformation => this == UserRole.admin || this == UserRole.owner;

  /// Interpreta el rol recibido para un establecimiento.
  static UserRole fromBackend(String? value) => switch (value) {
    'admin' || 'administrator' => UserRole.admin,
    'owner' => UserRole.owner,
    'employee' => UserRole.employee,
    _ => UserRole.unknown,
  };

  /// Valor estable usado por backend y persistencia local.
  String get backendValue => switch (this) {
    UserRole.admin => 'admin',
    UserRole.owner => 'owner',
    UserRole.employee => 'employee',
    UserRole.unknown => 'unknown',
  };
}

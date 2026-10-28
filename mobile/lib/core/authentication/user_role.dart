/// Rol de una persona dentro de un establecimiento concreto.
enum UserRole {
  /// Administrador con acceso financiero.
  admin,

  /// Propietario con acceso financiero.
  owner,

  /// Empleado sin acceso financiero.
  employee,

  /// Veterinario. Por ahora opera como empleado: sin finanzas ni gestion de
  /// equipo (adr-0012).
  veterinarian,

  /// Rol ausente o no reconocido por esta version de la app.
  unknown,
}

/// Traduccion del contrato backend y reglas de permisos por membresia.
extension UserRolePermissions on UserRole {
  /// Los roles operativos conocidos pueden registrar pesajes sin conexión.
  bool get canRecordWeighing => switch (this) {
    UserRole.admin || UserRole.owner || UserRole.employee || UserRole.veterinarian => true,
    UserRole.unknown => false,
  };

  /// Solo administradores y propietarios pueden consultar finanzas.
  bool get canViewFinancialInformation => this == UserRole.admin || this == UserRole.owner;

  /// Solo propietarios y administradores invitan, reenvian, cancelan y quitan
  /// gente del equipo. El backend aplica la misma regla.
  bool get canManageTeam => this == UserRole.admin || this == UserRole.owner;

  /// Roles que este rol puede asignar al invitar (un admin no invita duenos).
  List<UserRole> get assignableRoles => switch (this) {
    UserRole.owner => const [UserRole.owner, UserRole.admin, UserRole.employee, UserRole.veterinarian],
    UserRole.admin => const [UserRole.admin, UserRole.employee, UserRole.veterinarian],
    _ => const [],
  };

  /// Roles de la gente que este rol puede quitar del equipo.
  bool canRemove(UserRole target) => switch (this) {
    UserRole.owner => true,
    UserRole.admin => target == UserRole.employee || target == UserRole.veterinarian,
    _ => false,
  };

  /// Interpreta el rol recibido para un establecimiento.
  static UserRole fromBackend(String? value) => switch (value) {
    'admin' || 'administrator' => UserRole.admin,
    'owner' => UserRole.owner,
    'employee' => UserRole.employee,
    'veterinarian' => UserRole.veterinarian,
    _ => UserRole.unknown,
  };

  /// Valor estable usado por backend y persistencia local.
  String get backendValue => switch (this) {
    UserRole.admin => 'admin',
    UserRole.owner => 'owner',
    UserRole.employee => 'employee',
    UserRole.veterinarian => 'veterinarian',
    UserRole.unknown => 'unknown',
  };
}

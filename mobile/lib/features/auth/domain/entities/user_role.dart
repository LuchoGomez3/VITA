/// Application roles currently recognized by the auth domain.
enum UserRole {
  /// Administrator role.
  admin,

  /// Establishment manager role.
  encargado,

  /// Field operator role.
  operario,

  /// Fallback role when the backend value is not recognized.
  unknown,
}

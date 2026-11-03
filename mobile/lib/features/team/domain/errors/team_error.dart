/// Falla del equipo tal como la informa el backend.
///
/// Viaja en `DomainException.reason` para que la presentación elija el texto y,
/// al canjear un código, muestre cuántos intentos le quedan a la persona.
typedef TeamFailure = ({TeamErrorReason? reason, int? remainingAttempts});

/// Motivos funcionales que el backend informa con un código estable.
enum TeamErrorReason {
  /// El usuario no es dueño ni administrador.
  notAllowed,

  /// El rol de quien gestiona no alcanza para el rol elegido.
  roleNotAssignable,

  /// La persona ya forma parte del equipo.
  alreadyMember,

  /// Ya hay una invitación pendiente para ese email.
  duplicatedInvitation,

  /// El código no existe o está mal escrito.
  invalidCode,

  /// El código venció.
  expiredCode,

  /// El código ya se usó.
  usedCode,

  /// La invitación se canceló.
  revokedCode,

  /// El código es para otro email.
  codeForAnotherEmail,

  /// Se pasó el límite de intentos.
  tooManyAttempts,

  /// No se puede quitar al titular.
  holderNotRemovable,

  /// Nadie se quita a sí mismo.
  cannotRemoveYourself;

  /// Traduce el `code` de error del backend; `null` si no es de esta feature.
  static TeamErrorReason? fromBackendCode(String? code) => switch (code) {
    'equipo_sin_permiso' => notAllowed,
    'rol_no_asignable' => roleNotAssignable,
    'ya_es_miembro' => alreadyMember,
    'invitacion_pendiente_duplicada' => duplicatedInvitation,
    'codigo_invalido' => invalidCode,
    'codigo_vencido' => expiredCode,
    'codigo_usado' => usedCode,
    'codigo_revocado' => revokedCode,
    'codigo_de_otro_email' => codeForAnotherEmail,
    'titular_no_removible' => holderNotRemovable,
    'no_podes_quitarte' => cannotRemoveYourself,
    _ => null,
  };
}

import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';

/// Textos centralizados del equipo del establecimiento.
abstract final class TeamStrings {
  // ─── Equipo ───────────────────────────────────────────────────────────────

  /// Título de la pantalla.
  static const title = 'Equipo';

  /// Título de la sección de usuarios activos.
  static String membersSection(int count) => 'Usuarios · $count';

  /// Título de la sección de invitaciones pendientes.
  static String invitationsSection(int count) => 'Invitaciones pendientes · $count';

  /// Botón para invitar.
  static const inviteFab = 'Invitar usuario';

  /// Estado de un miembro activo.
  static const activeStatus = 'Activo';

  /// Estado de una invitación sin aceptar.
  static const invitedStatus = 'Invit. pend.';

  /// Estado de una invitación vencida.
  static const expiredStatus = 'Vencida';

  /// Nota del titular.
  static const holderNote = 'Titular del establecimiento';

  /// Vencimiento de una invitación.
  static String expiresOn(DateTime date) => 'Vence el ${_date(date)}';

  /// Invitación vencida.
  static String expiredOn(DateTime date) => 'Venció el ${_date(date)} · reenviala para que sirva';

  /// El email de la invitación no salió.
  static const emailNotSent = 'El email no salió · reenviala';

  /// Aviso sin conexión.
  static String offlineBanner(DateTime? fetchedAt) => fetchedAt == null
      ? 'Sin conexión. Para ver y gestionar el equipo hace falta señal.'
      : 'Sin conexión. Es el equipo al ${_dateTime(fetchedAt)}; para invitar o quitar hace falta señal.';

  /// No hay nada guardado ni conexión.
  static const emptyOffline = 'Todavía no se cargó el equipo de este campo.';

  /// El establecimiento no está en el celular.
  static const establishmentMissing = 'No encontramos este establecimiento en el celular.';

  /// Menú de acciones de una fila.
  static const actionsTooltip = 'Acciones';

  /// Reenviar una invitación.
  static const resendAction = 'Reenviar invitación';

  /// Cancelar una invitación.
  static const cancelAction = 'Cancelar invitación';

  /// Quitar a alguien del equipo.
  static const removeAction = 'Quitar del equipo';

  /// Confirmación de cancelar.
  static String cancelConfirmTitle(String email) => '¿Cancelar la invitación a $email?';

  /// Explicación de cancelar.
  static const cancelConfirmMessage = 'El código que le llegó por email deja de servir.';

  /// Confirmación de quitar.
  static String removeConfirmTitle(String name) => '¿Quitar a $name del equipo?';

  /// Explicación de quitar.
  static const removeConfirmMessage =
      'Deja de ver este establecimiento. Lo que cargó se conserva, y podés volver a invitarlo.';

  /// Botón para volver atrás en una confirmación.
  static const keepCta = 'Volver';

  /// Botón para confirmar cancelar.
  static const confirmCancelCta = 'Cancelar invitación';

  /// Botón para confirmar quitar.
  static const confirmRemoveCta = 'Quitar';

  /// Aviso: se reenvió.
  static const resentNotice = 'Reenviamos la invitación con un código nuevo.';

  /// Aviso: código nuevo sin email.
  static const resentWithoutEmailNotice = 'Generamos un código nuevo pero el email no salió. Probá de nuevo más tarde.';

  /// Aviso: se canceló.
  static const cancelledNotice = 'Invitación cancelada.';

  /// Aviso: se quitó.
  static const removedNotice = 'Lo quitamos del equipo.';

  // ─── Invitar ──────────────────────────────────────────────────────────────

  /// Título de la pantalla de invitación.
  static const inviteTitle = 'Invitar usuario';

  /// Botón de cerrar.
  static const closeTooltip = 'Cerrar';

  /// Campo de email.
  static const emailLabel = 'Email del invitado';

  /// Ayuda del campo de email.
  static const emailHelper = 'Le llega un código para sumarse. Tiene que entrar a VITA con este email.';

  /// Email vacío.
  static const emailRequired = 'Escribí el email de la persona.';

  /// Email inválido.
  static const emailInvalid = 'Revisá el email: no parece válido.';

  /// Sección de rol.
  static const roleSection = 'Rol';

  /// Botón de enviar.
  static const sendCta = 'Enviar invitación';

  /// Botón mientras se envía.
  static const sendingCta = 'Enviando…';

  /// Aviso: invitación enviada.
  static String sentNotice(String email) => 'Le mandamos la invitación a $email.';

  /// Aviso: invitación creada pero el email no salió.
  static const sentWithoutEmailNotice = 'La invitación quedó creada pero el email no salió. Reenviala desde el equipo.';

  /// Descripción de cada rol en la invitación.
  static String roleDescription(UserRole role) => switch (role) {
    UserRole.owner => 'Control total del establecimiento: equipo, datos y finanzas.',
    UserRole.admin => 'Configuración, datos, finanzas y equipo. No puede sumar dueños.',
    UserRole.employee => 'Operación diaria: animales, pesajes, sanidad y movimientos.',
    UserRole.veterinarian => 'Sanidad y operación diaria del rodeo. Sin acceso a finanzas.',
    UserRole.unknown => '',
  };

  // ─── Sumarse con código ───────────────────────────────────────────────────

  /// Título de la pantalla.
  static const joinTitle = 'Sumarme a un establecimiento';

  /// Explicación.
  static const joinIntro =
      'Ingresá el código que te llegó por email. Tenés que haber entrado a VITA con ese mismo email.';

  /// Campo del código.
  static const codeLabel = 'Código de invitación';

  /// Ejemplo del código.
  static const codeHint = 'K7QM-4XPD';

  /// Botón de validar.
  static const checkCta = 'Continuar';

  /// Botón mientras valida.
  static const checkingCta = 'Revisando…';

  /// Previsualización.
  static String previewMessage(String establishment, UserRole role) =>
      'Te vas a sumar a $establishment como ${UserRoleStrings.name(role)}.';

  /// Quién invitó.
  static String previewInvitedBy(String name) => 'Te invitó $name.';

  /// Botón de confirmar.
  static const joinCta = 'Sumarme';

  /// Botón mientras confirma.
  static const joiningCta = 'Sumándote…';

  /// Volver a escribir el código.
  static const otherCodeCta = 'Usar otro código';

  /// Aviso: ya se sumó.
  static String joinedNotice(String establishment) => 'Ya formás parte de $establishment.';

  // ─── Errores ──────────────────────────────────────────────────────────────

  /// Mensaje para el usuario de un error del equipo.
  static String error(DomainException error) {
    final reason = error.reason;
    if (reason is TeamErrorReason) {
      return switch (reason) {
        TeamErrorReason.notAllowed => 'Solo el dueño o un administrador pueden gestionar el equipo.',
        TeamErrorReason.roleNotAssignable => 'Tu rol no te permite gestionar a alguien con ese rol.',
        TeamErrorReason.alreadyMember => 'Esa persona ya forma parte del equipo.',
        TeamErrorReason.duplicatedInvitation =>
          'Ya hay una invitación pendiente para ese email. Podés reenviarla desde el equipo.',
        TeamErrorReason.invalidCode => 'El código no es válido. Revisá que esté bien escrito.',
        TeamErrorReason.expiredCode => 'El código venció. Pedile a quien te invitó que te lo reenvíe.',
        TeamErrorReason.usedCode => 'Este código ya se usó.',
        TeamErrorReason.revokedCode => 'La invitación fue cancelada. Pedile una nueva a quien te invitó.',
        TeamErrorReason.codeForAnotherEmail =>
          'Este código es para otro email. Entrá a VITA con el email al que llegó la invitación.',
        TeamErrorReason.tooManyAttempts => 'Hiciste muchos intentos. Esperá un rato y volvé a probar.',
        TeamErrorReason.holderNotRemovable => 'No se puede quitar al titular del establecimiento.',
        TeamErrorReason.cannotRemoveYourself => 'No podés quitarte a vos mismo del equipo.',
      };
    }
    if (error.code == DomainErrorCode.offline) {
      return 'Sin conexión. Para esto hace falta señal; probá cuando vuelva.';
    }
    return error.message;
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _date(DateTime date) {
    final local = date.toLocal();
    return '${_two(local.day)}/${_two(local.month)}/${local.year}';
  }

  static String _dateTime(DateTime date) {
    final local = date.toLocal();
    return '${_date(local)} ${_two(local.hour)}:${_two(local.minute)}';
  }
}

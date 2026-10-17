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

  /// Segunda línea de una invitación: todavía no hay nombre para mostrar.
  static const invitationSubtitle = 'Invitación por email, sin aceptar';

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

  /// No se pudo traer el equipo y no hay nada guardado.
  static const loadFailed = 'No pudimos cargar el equipo.';

  /// Reintentar la carga.
  static const retryCta = 'Reintentar';

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
  static const emailHelper = 'Le llega un código para sumarse con este email.';

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

  // ─── Invitación creada (owner) ────────────────────────────────────────────

  /// Título de la pantalla.
  static const createdTitle = 'Invitación creada';

  /// Chip de la invitación recién creada.
  static const pendingStatus = 'Pendiente';

  /// Vencimiento y uso del código.
  static String codeValidity(DateTime expiresAt) => 'Vence el ${_date(expiresAt)} · uso único';

  /// Cómo se usa el código.
  static const createdExplanation =
      'Le enviamos el código por correo. Si no le llega, compartíselo por WhatsApp o dictáselo: '
      'lo ingresa en la app desde "Sumarme a un establecimiento".';

  /// El email no salió.
  static const createdWithoutEmailExplanation =
      'No pudimos mandar el correo. Compartíselo por WhatsApp o dictáselo: lo ingresa en la app '
      'desde "Sumarme a un establecimiento".';

  /// Copiar el código.
  static const copyCta = 'Copiar';

  /// Compartir el código.
  static const shareCta = 'Compartir';

  /// Aviso: se copió.
  static const codeCopied = 'Código copiado.';

  /// Mensaje que se comparte por WhatsApp u otra app.
  static String shareMessage(String establishment, String code) =>
      'Te invité a $establishment en VITA. Entrá a la app con este email, andá a Perfil > '
      'Sumarme a otro establecimiento e ingresá el código $code (vence en 7 días).';

  /// Cerrar la pantalla.
  static const doneCta = 'Listo';

  /// Cancelando.
  static const cancellingCta = 'Cancelando…';

  // ─── Sumarse con código (invitado) ────────────────────────────────────────

  /// Título de la pantalla.
  static const joinTitle = 'Sumarme a un establecimiento';

  /// Título del paso de ingresar el código.
  static const enterCodeTitle = 'Ingresá tu código';

  /// Explicación del código.
  static const enterCodeIntro =
      'Son 6 caracteres, letras y números. Te lo mandó el dueño o administrador del campo por correo o mensaje.';

  /// Explicación corta (con un error a la vista).
  static const enterCodeIntroShort = 'Son 6 caracteres, letras y números.';

  /// Aclaración de mayúsculas.
  static const caseInsensitive = 'No distingue mayúsculas de minúsculas.';

  /// Pegar desde el portapapeles.
  static const pasteCta = 'Pegar código copiado';

  /// Aviso de conexión.
  static const onlineNote =
      'Para validar el código necesitás conexión. Después vas a poder trabajar en el campo sin señal.';

  /// Etiqueta del código.
  static const codeLabel = 'Código de invitación';

  /// Validar.
  static const validateCta = 'Validar código';

  /// Validando.
  static const checkingCta = 'Revisando…';

  /// Reintentar el mismo código.
  static const retryCodeCta = 'Volver a intentar';

  /// Borrar el código.
  static const clearCodeCta = 'Borrar y escribir de nuevo';

  /// Intentos que quedan.
  static String remainingAttempts(int remaining) => switch (remaining) {
    0 => 'No te quedan intentos por ahora. Esperá un rato.',
    1 => 'Te queda 1 intento.',
    _ => 'Te quedan $remaining intentos.',
  };

  /// Código válido.
  static const validCode = 'Código válido';

  /// Sección del campo.
  static const invitedTo = 'Te invitaron a';

  /// RENSPA del campo.
  static String renspa(String value) => 'RENSPA $value';

  /// Fila de quién invitó.
  static const invitedByLabel = 'Invitado por';

  /// Quién invitó y con qué rol.
  static String invitedByValue(String name, UserRole? role) =>
      role == null ? name : '$name · ${UserRoleStrings.name(role)}';

  /// Fila del rol.
  static const yourRoleLabel = 'Tu rol';

  /// Fila del email.
  static const emailRowLabel = 'Correo';

  /// Título de lo que podrá hacer.
  static String abilitiesTitle(UserRole role) => 'Como ${UserRoleStrings.name(role).toLowerCase()} vas a poder';

  /// Lo que puede y no puede hacer cada rol (adr-0012: veterinario opera como
  /// empleado por ahora).
  static ({List<String> can, List<String> cannot}) roleAbilities(UserRole role) => switch (role) {
    UserRole.owner => (
      can: const [
        'Gestionar el equipo y los datos del campo',
        'Ver finanzas y ventas',
        'Cargar animales, pesajes y sanidad',
      ],
      cannot: const [],
    ),
    UserRole.admin => (
      can: const [
        'Invitar y quitar empleados y veterinarios',
        'Ver finanzas y ventas',
        'Cargar animales, pesajes y sanidad',
      ],
      cannot: const ['Sumar dueños al campo'],
    ),
    UserRole.employee || UserRole.veterinarian => (
      can: const [
        'Dar de alta animales y registrar pesajes',
        'Aplicar vacunas y tratamientos',
        'Mover animales entre potreros',
      ],
      cannot: const ['Gestionar el equipo ni ver finanzas'],
    ),
    UserRole.unknown => (can: const [], cannot: const []),
  };

  /// Confirmar.
  static String joinEstablishmentCta(String establishment) => 'Unirme a $establishment';

  /// Confirmando.
  static const joiningCta = 'Sumándote…';

  /// No es su invitación.
  static const notMyInvitationCta = 'No es mi invitación';

  /// Título del éxito.
  static String joinedTitle(String establishment) => 'Ya sos parte de $establishment';

  /// Subtítulo del éxito.
  static String joinedSubtitle(UserRole role, String invitedBy) {
    final asRole = 'Entraste como ${UserRoleStrings.name(role).toLowerCase()}.';
    return invitedBy.isEmpty ? asRole : '$asRole Le avisamos a $invitedBy.';
  }

  /// Descargando.
  static const downloadingData = 'Descargando datos del campo';

  /// Descarga terminada.
  static const downloadedTitle = 'Datos del campo';

  /// Mientras descarga.
  static const downloadRunning = 'Animales y potreros, para usar sin señal.';

  /// Terminó.
  static const downloadDone = 'Listo: quedaron en el celular para usar sin señal.';

  /// Falló.
  static const downloadFailed = 'No pudimos bajar todo ahora; se completa en la próxima sincronización.';

  /// Ir al inicio.
  static const goHomeCta = 'Ir al inicio';

  /// Título del error de un código.
  static String codeErrorTitle(DomainException error) {
    final failure = error.reason;
    final reason = failure is TeamFailure ? failure.reason : null;
    return switch (reason) {
      TeamErrorReason.expiredCode => 'El código venció',
      TeamErrorReason.usedCode => 'El código ya se usó',
      TeamErrorReason.revokedCode => 'La invitación fue cancelada',
      TeamErrorReason.codeForAnotherEmail => 'El código es para otra cuenta',
      TeamErrorReason.tooManyAttempts => 'Demasiados intentos',
      TeamErrorReason.alreadyMember => 'Ya formás parte del campo',
      _ when error.code == DomainErrorCode.offline => 'Sin conexión',
      _ => 'El código no es válido',
    };
  }

  // ─── Errores ──────────────────────────────────────────────────────────────

  /// Mensaje para el usuario de un error del equipo.
  static String error(DomainException error) {
    final failure = error.reason;
    final reason = failure is TeamFailure ? failure.reason : null;
    if (reason != null) {
      return switch (reason) {
        TeamErrorReason.notAllowed => 'Solo el dueño o un administrador pueden gestionar el equipo.',
        TeamErrorReason.roleNotAssignable => 'Tu rol no te permite gestionar a alguien con ese rol.',
        TeamErrorReason.alreadyMember => 'Esa persona ya forma parte del equipo.',
        TeamErrorReason.duplicatedInvitation =>
          'Ya hay una invitación pendiente para ese email. Podés reenviarla desde el equipo.',
        TeamErrorReason.invalidCode =>
          'Revisá que esté bien escrito. Si ya pasaron 7 días o ya fue usado, pedile al dueño que te envíe uno nuevo.',
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

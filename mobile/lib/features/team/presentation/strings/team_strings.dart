/// Textos centralizados del flujo de gestión de equipo.
abstract final class TeamStrings {
  /// Título de la pantalla de listado.
  static const title = 'Equipo';

  /// Título de la sección de usuarios, con la cantidad.
  static String usersSectionTitle(int count) => 'Usuarios · $count';

  /// Etiqueta del FAB para invitar un usuario nuevo.
  static const inviteFabLabel = 'Invitar usuario';

  /// Etiqueta de estado activo.
  static const activeStatusLabel = 'Activo';

  /// Etiqueta de estado de invitación pendiente.
  static const invitedStatusLabel = 'Invit. pend.';

  /// Título de la pantalla de invitación.
  static const inviteTitle = 'Invitar usuario';

  /// Tooltip del botón de cerrar en la pantalla de invitación.
  static const inviteCloseTooltip = 'Cerrar';

  /// Etiqueta del campo de email del invitado.
  static const inviteEmailFieldLabel = 'Email del invitado';

  /// Título de la sección de selección de rol.
  static const inviteRoleSectionTitle = 'Rol';

  /// Etiqueta del CTA para enviar la invitación.
  static const sendInviteCta = 'Enviar invitación';

  /// Mensaje mostrado al enviar la invitación mock.
  static const inviteSentToast = 'Invitación enviada';
}

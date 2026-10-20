import 'package:frontend_mayoral/core/authentication/user_role.dart';

/// Persona con acceso activo al establecimiento.
typedef TeamMember = ({
  String userId,
  String firstName,
  String lastName,
  String email,
  UserRole role,

  /// Titular del establecimiento: no se puede quitar del equipo.
  bool isHolder,

  /// Color de la cabecera de su perfil (`#RRGGBB`), para el avatar.
  String? headerColor,
  DateTime memberSince,
});

/// Invitación por email que todavía no se canjeó.
typedef TeamInvitation = ({
  String id,
  String email,
  UserRole role,
  DateTime expiresAt,

  /// Venció sin canjearse: solo sirve reenviarla.
  bool isExpired,

  /// `false` si el último envío del email falló.
  bool emailSent,
  DateTime createdAt,
});

/// Equipo completo de un establecimiento, tal como lo devolvió el servidor.
typedef TeamSnapshot = ({
  List<TeamMember> members,
  List<TeamInvitation> invitations,

  /// Cuándo se trajo del servidor; sin conexión se muestra lo de esa fecha.
  DateTime fetchedAt,
});

/// Invitación recién creada (o reenviada) con su código en claro.
///
/// El servidor lo devuelve esta única vez, para que el dueño lo comparta por
/// WhatsApp si el email no llega; no se guarda en el celular.
typedef CreatedInvitation = ({TeamInvitation invitation, String code});

/// Lo que ve quien canjea un código antes de confirmar.
typedef InvitationPreview = ({
  String establishmentId,
  String establishmentName,
  String? renspa,
  String? locality,
  String? province,
  UserRole role,

  /// Email al que se mandó la invitación (el de la sesión).
  String email,
  String invitedBy,

  /// Rol de quien invitó; `null` si ya no forma parte del campo.
  UserRole? invitedByRole,
  DateTime expiresAt,
});

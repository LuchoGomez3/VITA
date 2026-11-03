import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';

part 'team.freezed.dart';

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
@Freezed(copyWith: false, map: FreezedMapOptions.none, when: FreezedWhenOptions.none)
sealed class TeamSnapshot with _$TeamSnapshot {
  /// Copia las listas para que tampoco el llamador pueda modificarlas.
  factory TeamSnapshot({
    required List<TeamMember> members,
    required List<TeamInvitation> invitations,
    required DateTime fetchedAt,
    bool isComplete = true,
  }) => TeamSnapshot._value(
    members: List.unmodifiable(members),
    invitations: List.unmodifiable(invitations),
    fetchedAt: fetchedAt,
    isComplete: isComplete,
  );

  const TeamSnapshot._();

  /// Constructor interno; toda entrada pública copia las colecciones.
  const factory TeamSnapshot._value({
    required List<TeamMember> members,
    required List<TeamInvitation> invitations,
    required DateTime fetchedAt,
    @Default(true) bool isComplete,
  }) = _TeamSnapshot;

  /// Cada copia conserva ownership de sus listas.
  TeamSnapshot copyWith({
    List<TeamMember>? members,
    List<TeamInvitation>? invitations,
    DateTime? fetchedAt,
    bool? isComplete,
  }) => TeamSnapshot(
    members: members ?? this.members,
    invitations: invitations ?? this.invitations,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// Confirmación remota, independiente de si se pudo guardar para uso offline.
@freezed
sealed class TeamMutation<T> with _$TeamMutation<T> {
  /// Resultado conocido; nunca contiene el código dentro de [snapshot].
  const factory TeamMutation({
    required T value,
    required TeamChange change,
    required TeamSnapshot snapshot,
    DomainException? persistenceError,
  }) = _TeamMutation<T>;
  const TeamMutation._();

  /// Un resultado parcial no descarta datos que la pantalla ya conoce.
  TeamSnapshot reconcile(TeamSnapshot? previous) =>
      snapshot.isComplete || previous == null ? snapshot : change.apply(previous);
}

/// Efecto confirmado que puede aplicarse sin volver a consultar al servidor.
@freezed
sealed class TeamChange with _$TeamChange {
  /// Invitación nueva o reenviada: se reconcilia por ID.
  const factory TeamChange.invitation(TeamInvitation invitation) = ChangedInvitation;

  /// Invitación cancelada.
  const factory TeamChange.cancelled(String invitationId) = CancelledInvitation;

  /// Miembro quitado.
  const factory TeamChange.removed(String userId) = RemovedTeamMember;
  const TeamChange._();

  /// Aplica solo el efecto conocido; conserva la fecha de la última lectura completa.
  TeamSnapshot apply(TeamSnapshot snapshot) => switch (this) {
    ChangedInvitation(:final invitation) => snapshot.copyWith(
      invitations: [...snapshot.invitations.where((i) => i.id != invitation.id), invitation],
    ),
    CancelledInvitation(:final invitationId) => snapshot.copyWith(
      invitations: snapshot.invitations.where((i) => i.id != invitationId).toList(),
    ),
    RemovedTeamMember(:final userId) => snapshot.copyWith(
      members: snapshot.members.where((m) => m.userId != userId).toList(),
    ),
  };
}

/// Una aceptación confirmada no se convierte en rechazo por fallar el storage.
@freezed
sealed class TeamAcceptance with _$TeamAcceptance {
  /// Membresía otorgada por el servidor y resultado del guardado local.
  const factory TeamAcceptance({
    required EstablishmentMembership membership,
    DomainException? persistenceError,
  }) = _TeamAcceptance;
}

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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:meta/meta.dart';

/// Validación local del email antes de mandarlo al servidor.
enum InviteEmailError {
  /// Está vacío.
  required,

  /// No tiene forma de email.
  invalid,
}

/// Estado del formulario de invitación.
@immutable
class InviteTeamMemberState {
  /// Crea el estado.
  const InviteTeamMemberState({
    required this.role,
    this.emailError,
    this.isSending = false,
    this.sent,
    this.error,
  });

  /// Rol elegido.
  final UserRole role;

  /// Error de validación del email, si se intentó enviar.
  final InviteEmailError? emailError;

  /// Si la invitación se está enviando.
  final bool isSending;

  /// Invitación creada con su código; la página abre la pantalla de compartir.
  final CreatedInvitation? sent;

  /// Error del servidor, para mostrarlo una vez.
  final DomainException? error;

  @override
  bool operator ==(Object other) =>
      other is InviteTeamMemberState &&
      other.role == role &&
      other.emailError == emailError &&
      other.isSending == isSending &&
      other.sent == sent &&
      other.error == error;

  @override
  int get hashCode => Object.hash(role, emailError, isSending, sent, error);
}

/// Valida y envía una invitación al equipo.
class InviteTeamMemberCubit extends Cubit<InviteTeamMemberState> {
  /// Crea el Cubit; [assignableRoles] sale del rol de quien invita.
  InviteTeamMemberCubit({
    required this.establishmentId,
    required this.assignableRoles,
    required InviteTeamMemberUseCase invite,
  }) : _invite = invite,
       super(
         InviteTeamMemberState(
           // Empleado por defecto: es la invitación más común (el capataz).
           role: assignableRoles.contains(UserRole.employee) ? UserRole.employee : assignableRoles.first,
         ),
       );

  /// Establecimiento al que se invita.
  final String establishmentId;

  /// Roles que se pueden elegir.
  final List<UserRole> assignableRoles;

  final InviteTeamMemberUseCase _invite;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Cambia el rol elegido.
  void selectRole(UserRole role) {
    if (assignableRoles.contains(role)) {
      emit(InviteTeamMemberState(role: role, emailError: state.emailError));
    }
  }

  /// Valida [email] y envía la invitación.
  Future<void> submit(String email) async {
    if (state.isSending) {
      return;
    }
    final normalized = email.trim();
    final emailError = normalized.isEmpty
        ? InviteEmailError.required
        : (_emailPattern.hasMatch(normalized) ? null : InviteEmailError.invalid);
    if (emailError != null) {
      emit(InviteTeamMemberState(role: state.role, emailError: emailError));
      return;
    }
    emit(InviteTeamMemberState(role: state.role, isSending: true));
    final result = await _invite(establishmentId, email: normalized, role: state.role);
    switch (result) {
      case Success<CreatedInvitation>(:final data):
        emit(InviteTeamMemberState(role: state.role, sent: data));
      case Failure<CreatedInvitation>(:final error):
        emit(InviteTeamMemberState(role: state.role, error: error));
    }
  }
}

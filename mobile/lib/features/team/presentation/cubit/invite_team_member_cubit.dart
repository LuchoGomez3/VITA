import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';

part 'invite_team_member_cubit.freezed.dart';

/// Errores de campo resueltos por el caso de uso.
enum InviteEmailError {
  /// Email vacío.
  required,

  /// Email inválido.
  invalid,
}

/// Inicialización y envío tienen resultados separados.
@freezed
sealed class InviteTeamMemberState with _$InviteTeamMemberState {
  /// Estado inicial, sin permisos hasta resolver el catálogo.
  const factory InviteTeamMemberState({
    @Default(UserRole.employee) UserRole role,
    @Default(ResultState<List<UserRole>>.initial()) ResultState<List<UserRole>> initialization,
    @Default(ResultState<TeamMutation<CreatedInvitation>>.initial())
    ResultState<TeamMutation<CreatedInvitation>> submission,
  }) = _InviteTeamMemberState;
  const InviteTeamMemberState._();

  /// Roles autorizados localmente, inmutables.
  List<UserRole> get assignableRoles => switch (initialization) {
    Data<List<UserRole>>(:final data) => data,
    _ => const [],
  };

  /// No se permite enviar sin contexto resuelto.
  bool get isSending => submission is Loading<TeamMutation<CreatedInvitation>>;

  /// Confirmación efímera, incluso si no pudo guardarse en cache.
  TeamMutation<CreatedInvitation>? get sent => switch (submission) {
    Data<TeamMutation<CreatedInvitation>>(:final data) => data,
    _ => null,
  };

  /// Error técnico/funcional para presentación.
  DomainException? get error => switch (submission) {
    ResultError<TeamMutation<CreatedInvitation>>(:final error) => error,
    _ => switch (initialization) {
      ResultError<List<UserRole>>(:final error) => error,
      _ => null,
    },
  };

  /// Validación visual que acompaña la validación de dominio.
  InviteEmailError? get emailError {
    final reason = error?.reason;
    return switch (reason) {
      (reason: TeamErrorReason.emailRequired, remainingAttempts: _) => InviteEmailError.required,
      (reason: TeamErrorReason.emailInvalid, remainingAttempts: _) => InviteEmailError.invalid,
      _ => null,
    };
  }
}

/// Pertenece a BlocProvider; la inicialización nunca crea otra instancia tardía.
class InviteTeamMemberCubit extends Cubit<InviteTeamMemberState> {
  /// Crea el formulario con casos de uso explícitos.
  InviteTeamMemberCubit({
    required this.establishmentId,
    required GetTeamMembershipUseCase getMembership,
    required InviteTeamMemberUseCase invite,
    bool Function()? isSessionCurrent,
  }) : _getMembership = getMembership,
       _invite = invite,
       _isSessionCurrent = isSessionCurrent ?? (() => true),
       super(const InviteTeamMemberState());

  final bool Function() _isSessionCurrent;
  bool get _canPresent => !isClosed && _isSessionCurrent();

  /// Establecimiento del formulario.
  final String establishmentId;
  final GetTeamMembershipUseCase _getMembership;
  final InviteTeamMemberUseCase _invite;

  /// Roles para la UI.
  List<UserRole> get assignableRoles => state.assignableRoles;

  /// Resuelve permisos fail-closed y permite reintentar fallas de storage.
  Future<void> initialize() async {
    if (!_canPresent || state.initialization is Loading<List<UserRole>>) return;
    emit(state.copyWith(initialization: const ResultState.loading()));
    final result = await _getMembership(establishmentId);
    if (!_canPresent) return;
    switch (result) {
      case Success<EstablishmentMembership?>(:final data):
        final roles = data?.role.assignableRoles ?? const <UserRole>[];
        emit(state.copyWith(initialization: ResultState.data(List.unmodifiable(roles))));
      case Failure<EstablishmentMembership?>(:final error):
        emit(state.copyWith(initialization: ResultState.error(error)));
    }
  }

  /// Cambia la selección solo si no hay una invitación en curso.
  void selectRole(UserRole role) {
    if (_canPresent && !state.isSending && assignableRoles.contains(role)) {
      emit(state.copyWith(role: role, submission: const ResultState.initial()));
    }
  }

  /// El envío y la persistencia continúan aunque se cierre el formulario.
  Future<void> submit(String email) async {
    if (!_canPresent || state.isSending || assignableRoles.isEmpty) return;
    final role = state.role;
    emit(state.copyWith(submission: const ResultState.loading()));
    final result = await _invite(establishmentId, email: email, role: role);
    if (!_canPresent) return;
    emit(
      state.copyWith(
        submission: result.when(success: ResultState.data, failure: ResultState.error),
      ),
    );
  }
}

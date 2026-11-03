import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';

/// Posee la cancelación; la pantalla solo confirma la intención y navega.
class InvitationCreatedCubit extends Cubit<ResultState<TeamMutation<void>>> {
  /// Crea el Cubit con el alcance explícito de la invitación.
  InvitationCreatedCubit({
    required String establishmentId,
    required TeamInvitation invitation,
    required ManageTeamUseCase manageTeam,
    bool Function()? isSessionCurrent,
  }) : _establishmentId = establishmentId,
       _invitation = invitation,
       _manageTeam = manageTeam,
       _isSessionCurrent = isSessionCurrent ?? (() => true),
       super(const ResultState.initial());
  final String _establishmentId;
  final TeamInvitation _invitation;
  final ManageTeamUseCase _manageTeam;

  final bool Function() _isSessionCurrent;
  bool get _canPresent => !isClosed && _isSessionCurrent();

  /// No cancela la persistencia confirmada cuando se cierra la página.
  Future<void> cancel() async {
    if (!_canPresent || state is Loading<TeamMutation<void>>) return;
    emit(const ResultState.loading());
    final result = await _manageTeam.cancel(_establishmentId, _invitation);
    if (!_canPresent) return;
    emit(result.when(success: ResultState.data, failure: ResultState.error));
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invite_team_member_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/team_cubit.dart';

import '../team_fakes.dart';

TeamCubit _teamCubit(FakeTeamRepository repository, {UserRole role = UserRole.owner, bool known = true}) => TeamCubit(
  establishmentId: 'campo-1',
  findEstablishment: (_) async => known ? EstablishmentMembership(id: 'campo-1', name: 'La Sirena', role: role) : null,
  readCached: ReadCachedTeamUseCase(repository),
  refreshTeam: RefreshTeamUseCase(repository),
  manageTeam: ManageTeamUseCase(repository),
);

void main() {
  group('TeamCubit', () {
    test('muestra lo guardado y lo reemplaza por lo del servidor', () async {
      final repository = FakeTeamRepository()..cached = snapshotOf(invitations: []);
      final cubit = _teamCubit(repository);
      final states = <TeamState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.load();

      expect(states.first.snapshot!.invitations, isEmpty);
      expect(cubit.state.snapshot!.invitations, [pendingVet]);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.actionsEnabled, isTrue);
      await subscription.cancel();
    });

    test('sin conexión conserva lo guardado, sin error, y bloquea las acciones', () async {
      final repository = FakeTeamRepository()
        ..cached = snapshotOf()
        ..refreshResult = const Result.failure(offlineError);
      final cubit = _teamCubit(repository);

      await cubit.load();
      await cubit.remove(worker);

      expect(cubit.state.isOffline, isTrue);
      expect(cubit.state.error, isNull);
      expect(cubit.state.snapshot, isNotNull);
      expect(cubit.state.actionsEnabled, isFalse);
      expect(repository.calls, isNot(contains('remove:u-mariano')));
    });

    test('sin conexión y sin nada guardado informa el error', () async {
      final repository = FakeTeamRepository()..refreshResult = const Result.failure(offlineError);
      final cubit = _teamCubit(repository);

      await cubit.load();

      expect(cubit.state.snapshot, isNull);
      expect(cubit.state.error, offlineError);
    });

    test('un empleado o un veterinario ven el equipo pero no lo gestionan', () async {
      for (final role in [UserRole.employee, UserRole.veterinarian]) {
        final cubit = _teamCubit(FakeTeamRepository(), role: role);
        await cubit.load();
        expect(cubit.state.snapshot, isNotNull);
        expect(cubit.state.canManage, isFalse);
      }
    });

    test('un establecimiento que no está en el celular se informa', () async {
      final cubit = _teamCubit(FakeTeamRepository(), known: false);

      await cubit.load();

      expect(cubit.state.establishmentMissing, isTrue);
    });

    test('quitar, cancelar y reenviar avisan y recargan el equipo', () async {
      final repository = FakeTeamRepository();
      final cubit = _teamCubit(repository);
      await cubit.load();
      final notices = <TeamNotice>[];
      final subscription = cubit.stream.where((s) => s.notice != null).listen((s) => notices.add(s.notice!));

      await cubit.remove(worker);
      await cubit.cancel(pendingVet);
      repository.resendResult = Result.success((
        invitation: (
          id: pendingVet.id,
          email: pendingVet.email,
          role: pendingVet.role,
          expiresAt: pendingVet.expiresAt,
          isExpired: false,
          emailSent: false,
          createdAt: pendingVet.createdAt,
        ),
        code: 'Q8R-T3W',
      ));
      final created = cubit.stream.firstWhere((s) => s.created != null);
      await cubit.resend(pendingVet);
      await Future<void>.delayed(Duration.zero);

      expect(notices, [TeamNotice.removed, TeamNotice.cancelled, TeamNotice.resentWithoutEmail]);
      // Reenviar abre "Invitación creada" con el código nuevo.
      expect((await created).created!.code, 'Q8R-T3W');
      expect(repository.calls.where((c) => c == 'refresh'), hasLength(4));
      await subscription.cancel();
    });

    test('un error de una acción se informa sin perder el equipo', () async {
      const error = DomainException(
        message: 'x',
        code: DomainErrorCode.conflict,
        reason: (reason: TeamErrorReason.holderNotRemovable, remainingAttempts: null),
      );
      final repository = FakeTeamRepository()..removeResult = const Result.failure(error);
      final cubit = _teamCubit(repository);
      await cubit.load();

      await cubit.remove(holder);

      expect(cubit.state.error, error);
      expect(cubit.state.snapshot, isNotNull);
      expect(cubit.state.busyId, isNull);
    });
  });

  group('InviteTeamMemberCubit', () {
    InviteTeamMemberCubit inviteCubit(FakeTeamRepository repository, List<UserRole> roles) => InviteTeamMemberCubit(
      establishmentId: 'campo-1',
      assignableRoles: roles,
      invite: InviteTeamMemberUseCase(repository),
    );

    test('empieza en Empleado y valida el email antes de mandarlo', () async {
      final repository = FakeTeamRepository();
      final cubit = inviteCubit(repository, UserRole.admin.assignableRoles);

      expect(cubit.state.role, UserRole.employee);
      await cubit.submit('   ');
      expect(cubit.state.emailError, InviteEmailError.required);
      await cubit.submit('no-es-email');
      expect(cubit.state.emailError, InviteEmailError.invalid);
      expect(repository.calls, isEmpty);
    });

    test('no deja elegir un rol que no se puede asignar', () {
      final cubit = inviteCubit(FakeTeamRepository(), UserRole.admin.assignableRoles)..selectRole(UserRole.owner);

      expect(cubit.state.role, UserRole.employee);
      cubit.selectRole(UserRole.veterinarian);
      expect(cubit.state.role, UserRole.veterinarian);
    });

    test('envía la invitación y expone el resultado o el error', () async {
      final repository = FakeTeamRepository();
      final cubit = inviteCubit(repository, UserRole.owner.assignableRoles)..selectRole(UserRole.admin);

      await cubit.submit(' socio@example.com ');
      expect(repository.calls, ['invite:socio@example.com:admin']);
      expect(cubit.state.sent!.code, '7K4-P2M');

      repository.inviteResult = const Result.failure(offlineError);
      await cubit.submit('socio@example.com');
      expect(cubit.state.error, offlineError);
      expect(cubit.state.isSending, isFalse);
    });
  });

  group('JoinEstablishmentCubit', () {
    JoinEstablishmentCubit joinCubit(FakeTeamRepository repository, {bool syncFails = false, List<String>? log}) =>
        JoinEstablishmentCubit(
          JoinEstablishmentUseCase(repository),
          syncData: () async {
            log?.add('sync');
            return syncFails
                ? const Result.failure(offlineError)
                : Result.success(PostAuthenticationSummary(establishmentIds: const ['campo-1']));
          },
        );

    test('valida, muestra la previsualización, se suma y baja los datos', () async {
      final repository = FakeTeamRepository();
      final log = <String>[];
      final cubit = joinCubit(repository, log: log)..edit('7k4-p2m');

      await cubit.check();
      expect(cubit.state.step, JoinStep.confirm);
      expect(cubit.state.preview!.establishmentName, 'La Sirena');

      await cubit.confirm();
      expect(cubit.state.step, JoinStep.joined);
      expect(cubit.state.joined!.name, 'La Sirena');
      expect(cubit.state.dataSync, JoinDataSync.done);
      expect(repository.calls, ['preview:7K4P2M', 'accept:7K4P2M']);
      expect(log, ['sync']);
    });

    test('si la descarga falla igual queda sumado', () async {
      final cubit = joinCubit(FakeTeamRepository(), syncFails: true)..edit('7K4P2M');
      await cubit.check();

      await cubit.confirm();

      expect(cubit.state.step, JoinStep.joined);
      expect(cubit.state.dataSync, JoinDataSync.failed);
    });

    test('un código incompleto no se manda; uno inválido queda en rojo hasta editarlo', () async {
      const error = DomainException(message: 'x', reason: (reason: TeamErrorReason.invalidCode, remainingAttempts: 4));
      final repository = FakeTeamRepository()..previewResult = const Result.failure(error);
      final cubit = joinCubit(repository)..edit('7K4');

      await cubit.check();
      expect(repository.calls, isEmpty);

      cubit.edit('7K4P2N');
      await cubit.check();
      expect(cubit.state.step, JoinStep.enterCode);
      expect(cubit.state.error, error);
      expect(cubit.state.code, '7K4P2N');

      cubit.edit('7K4P2');
      expect(cubit.state.error, isNull);
    });

    test('"Volver a intentar" tras un rechazo saca el error y deja el código', () async {
      const error = DomainException(message: 'x', reason: (reason: TeamErrorReason.invalidCode, remainingAttempts: 3));
      final repository = FakeTeamRepository()..previewResult = const Result.failure(error);
      final cubit = joinCubit(repository)..edit('7K4P2N');
      await cubit.check();

      cubit.dismissError();

      expect(cubit.state.error, isNull);
      expect(cubit.state.code, '7K4P2N');
    });

    test('pegar un código con guion y de más lo recorta a 6', () {
      final cubit = joinCubit(FakeTeamRepository())..edit(' 7k4-p2m-xyz ');

      expect(cubit.state.code, '7K4P2M');
    });

    test('si el canje falla se queda en la confirmación; "No es mi invitación" vuelve a empezar', () async {
      final repository = FakeTeamRepository()..acceptResult = const Result.failure(offlineError);
      final cubit = joinCubit(repository)..edit('7K4P2M');
      await cubit.check();

      await cubit.confirm();

      expect(cubit.state.step, JoinStep.confirm);
      expect(cubit.state.error, offlineError);
      cubit.clear();
      expect(cubit.state.step, JoinStep.enterCode);
      expect(cubit.state.code, isEmpty);
    });
  });
}

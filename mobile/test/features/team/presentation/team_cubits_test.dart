import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
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
        id: pendingVet.id,
        email: pendingVet.email,
        role: pendingVet.role,
        expiresAt: pendingVet.expiresAt,
        isExpired: false,
        emailSent: false,
        createdAt: pendingVet.createdAt,
      ));
      await cubit.resend(pendingVet);
      await Future<void>.delayed(Duration.zero);

      expect(notices, [TeamNotice.removed, TeamNotice.cancelled, TeamNotice.resentWithoutEmail]);
      expect(repository.calls.where((c) => c == 'refresh'), hasLength(4));
      await subscription.cancel();
    });

    test('un error de una acción se informa sin perder el equipo', () async {
      const error = DomainException(
        message: 'x',
        code: DomainErrorCode.conflict,
        reason: TeamErrorReason.holderNotRemovable,
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
      expect(cubit.state.sent, pendingVet);

      repository.inviteResult = const Result.failure(offlineError);
      await cubit.submit('socio@example.com');
      expect(cubit.state.error, offlineError);
      expect(cubit.state.isSending, isFalse);
    });
  });

  group('JoinEstablishmentCubit', () {
    test('valida, muestra la previsualización y se suma', () async {
      final repository = FakeTeamRepository();
      final cubit = JoinEstablishmentCubit(JoinEstablishmentUseCase(repository));

      await cubit.check('k7qm-4xpd');
      expect(cubit.state.step, JoinStep.confirm);
      expect(cubit.state.preview!.establishmentName, 'La Sirena');

      await cubit.confirm();
      expect(cubit.state.step, JoinStep.joined);
      expect(cubit.state.joined!.name, 'La Sirena');
      expect(repository.calls, ['preview:K7QM4XPD', 'accept:K7QM4XPD']);
    });

    test('un código incompleto no se manda y uno inválido vuelve a escribirse', () async {
      const error = DomainException(message: 'x', reason: TeamErrorReason.invalidCode);
      final repository = FakeTeamRepository()..previewResult = const Result.failure(error);
      final cubit = JoinEstablishmentCubit(JoinEstablishmentUseCase(repository));

      await cubit.check('K7QM');
      expect(repository.calls, isEmpty);

      await cubit.check('K7QM4XPD');
      expect(cubit.state.step, JoinStep.enterCode);
      expect(cubit.state.error, error);
    });

    test('si el canje falla se queda en la confirmación para reintentar', () async {
      final repository = FakeTeamRepository()..acceptResult = const Result.failure(offlineError);
      final cubit = JoinEstablishmentCubit(JoinEstablishmentUseCase(repository));
      await cubit.check('K7QM4XPD');

      await cubit.confirm();

      expect(cubit.state.step, JoinStep.confirm);
      expect(cubit.state.error, offlineError);
      cubit.editCode();
      expect(cubit.state.step, JoinStep.enterCode);
    });
  });
}

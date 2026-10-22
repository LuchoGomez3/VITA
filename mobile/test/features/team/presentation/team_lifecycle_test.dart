import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invite_team_member_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/team_cubit.dart';

import '../team_fakes.dart';

TeamCubit _team(FakeTeamRepository repository) => TeamCubit(
  establishmentId: 'campo-1',
  getMembership: GetTeamMembershipUseCase(repository),
  readCached: ReadCachedTeamUseCase(repository),
  refreshTeam: RefreshTeamUseCase(repository),
  manageTeam: ManageTeamUseCase(repository),
);
InviteTeamMemberCubit _invite(FakeTeamRepository repository) => InviteTeamMemberCubit(
  establishmentId: 'campo-1',
  getMembership: GetTeamMembershipUseCase(repository),
  invite: InviteTeamMemberUseCase(repository),
);
Future<Result<PostAuthenticationSummary>> _prepared() async =>
    Result.success(PostAuthenticationSummary(establishmentIds: ['campo-1']));

void main() {
  test('cerrar durante validación no emite al resolver', () async {
    final pending = Completer<Result<InvitationPreview>>();
    final repository = FakeTeamRepository()..previewPending = pending.future;
    final cubit = JoinEstablishmentCubit(JoinEstablishmentUseCase(repository, prepareData: _prepared))..edit('7K4P2M');
    final checking = cubit.check();
    await cubit.close();
    final closedState = cubit.state;
    pending.complete(repository.previewResult);
    await checking;
    expect(cubit.state, closedState);
    expect(repository.calls, ['preview:7K4P2M']);
  });

  test('una validación vieja no reemplaza el código que se volvió a escribir', () async {
    final pending = Completer<Result<InvitationPreview>>();
    final repository = FakeTeamRepository()..previewPending = pending.future;
    final cubit = JoinEstablishmentCubit(JoinEstablishmentUseCase(repository, prepareData: _prepared))..edit('7K4P2M');
    addTearDown(cubit.close);
    final checking = cubit.check();
    cubit
      ..clear()
      ..edit('Q8RT3W');
    pending.complete(repository.previewResult);
    await checking;
    expect(cubit.state.step, JoinStep.enterCode);
    expect(cubit.state.code, 'Q8RT3W');
    expect(cubit.state.preview, isNull);
  });

  test('cerrar durante inicialización de Invitar descarta el resultado', () async {
    final pending = Completer<Result<EstablishmentMembership?>>();
    final repository = FakeTeamRepository()..membershipPending = pending.future;
    final cubit = _invite(repository);
    final loading = cubit.initialize();
    await cubit.close();
    final closedState = cubit.state;
    pending.complete(repository.membershipResult);
    await loading;
    expect(cubit.state, closedState);
    expect(repository.calls, isEmpty);
  });

  test('cerrar Equipo durante inicialización no inicia requests posteriores', () async {
    final pending = Completer<Result<EstablishmentMembership?>>();
    final repository = FakeTeamRepository()..membershipPending = pending.future;
    final cubit = _team(repository);
    final loading = cubit.load();
    await cubit.close();
    pending.complete(repository.membershipResult);
    await loading;
    expect(repository.calls, isEmpty);
  });

  test('cerrar durante invitación deja terminar el guardado sin nuevas emisiones', () async {
    final pending = Completer<Result<CreatedInvitation>>();
    final repository = FakeTeamRepository()..invitePending = pending.future;
    final cubit = _invite(repository);
    await cubit.initialize();
    final operation = cubit.submit('vet@example.com');
    await cubit.close();
    final closedState = cubit.state;
    pending.complete(repository.inviteResult);
    await operation;
    expect(cubit.state, closedState);
    expect(repository.calls, ['invite:vet@example.com:employee']);
    expect(repository.cached!.invitations, [pendingVet]);
  });

  test('cerrar durante descarga posterior al canje no emite al terminar', () async {
    final pending = Completer<Result<PostAuthenticationSummary>>();
    final started = Completer<void>();
    final repository = FakeTeamRepository();
    final cubit = JoinEstablishmentCubit(
      JoinEstablishmentUseCase(
        repository,
        prepareData: () {
          started.complete();
          return pending.future;
        },
      ),
    )..edit('7K4P2M');
    await cubit.check();
    final operation = cubit.confirm();
    await started.future;
    expect(cubit.state.step, JoinStep.joined);
    expect(cubit.state.code, isEmpty);
    await cubit.close();
    final closedState = cubit.state;
    pending.complete(await _prepared());
    await operation;
    expect(cubit.state, closedState);
    expect(repository.calls.where((c) => c.startsWith('accept:')), hasLength(1));
  });

  test('cerrar mientras backend canjea no cancela la descarga persistente', () async {
    final pending = Completer<Result<TeamAcceptance>>();
    final repository = FakeTeamRepository()..acceptPending = pending.future;
    var syncCalls = 0;
    final cubit = JoinEstablishmentCubit(
      JoinEstablishmentUseCase(
        repository,
        prepareData: () {
          syncCalls++;
          return _prepared();
        },
      ),
    )..edit('7K4P2M');
    await cubit.check();
    final operation = cubit.confirm();
    await cubit.close();
    pending.complete(repository.acceptResult);
    await operation;
    expect(syncCalls, 1);
  });

  test('aceptación con falla local se recupera sin volver a canjear', () async {
    final repository = FakeTeamRepository()
      ..membershipResult = const Result.success(null)
      ..acceptResult = Result.success(
        TeamAcceptance(
          membership: const EstablishmentMembership(id: 'campo-1', name: 'La Sirena', role: UserRole.employee),
          persistenceError: teamError(TeamErrorReason.storageUnavailable),
        ),
      );
    var syncCalls = 0;
    final cubit = JoinEstablishmentCubit(
      JoinEstablishmentUseCase(
        repository,
        prepareData: () async {
          syncCalls++;
          return syncCalls == 1 ? const Result.failure(offlineError) : _prepared();
        },
      ),
    )..edit('7K4P2M');
    addTearDown(cubit.close);
    await cubit.check();
    await cubit.confirm();
    expect(cubit.state.step, JoinStep.joined);
    expect(cubit.state.persistence, isA<ResultError<void>>());
    expect(cubit.state.download, isA<ResultError<PostAuthenticationSummary>>());
    await cubit.recover();
    expect(cubit.state.persistence, isA<Data<void>>());
    expect(cubit.state.download, isA<Data<PostAuthenticationSummary>>());
    expect(repository.calls.where((c) => c.startsWith('accept:')), ['accept:7K4P2M']);
  });

  test('si la recuperación guardó catálogo pero falló la descarga, solo queda pendiente la descarga', () async {
    final repository = FakeTeamRepository()
      ..acceptResult = Result.success(
        TeamAcceptance(
          membership: const EstablishmentMembership(id: 'campo-1', name: 'La Sirena', role: UserRole.employee),
          persistenceError: teamError(TeamErrorReason.storageUnavailable),
        ),
      );
    final cubit = JoinEstablishmentCubit(
      JoinEstablishmentUseCase(repository, prepareData: () async => const Result.failure(offlineError)),
    )..edit('7K4P2M');
    addTearDown(cubit.close);
    await cubit.check();
    await cubit.confirm();
    expect(cubit.state.step, JoinStep.joined);
    expect(cubit.state.persistence, isA<Data<void>>());
    expect(cubit.state.download, isA<ResultError<PostAuthenticationSummary>>());
  });

  test('el dominio rechaza roles ausentes, desconocidos y empleados', () async {
    for (final role in [null, UserRole.unknown, UserRole.employee, UserRole.veterinarian]) {
      final repository = FakeTeamRepository()
        ..membershipResult = Result.success(
          role == null ? null : EstablishmentMembership(id: 'campo-1', name: 'La Sirena', role: role),
        );
      final cubit = _invite(repository);
      await cubit.initialize();
      await cubit.submit('vet@example.com');
      final result = await InviteTeamMemberUseCase(repository)(
        'campo-1',
        email: 'vet@example.com',
        role: UserRole.employee,
      );
      expect(result, isA<Failure<TeamMutation<CreatedInvitation>>>());
      expect(repository.calls, isEmpty);
      expect(cubit.assignableRoles, isEmpty);
      await cubit.close();
    }
  });

  test('admin no invita dueños ni quita administradores, y nadie quita al titular', () async {
    final repository = FakeTeamRepository()
      ..membershipResult = const Result.success(
        EstablishmentMembership(id: 'campo-1', name: 'La Sirena', role: UserRole.admin),
      );
    final invitation = await InviteTeamMemberUseCase(repository)(
      'campo-1',
      email: 'vet@example.com',
      role: UserRole.owner,
    );
    final removal = await ManageTeamUseCase(repository).remove('campo-1', holder);
    expect(invitation, isA<Failure<TeamMutation<CreatedInvitation>>>());
    expect(removal, isA<Failure<TeamMutation<void>>>());
    expect(repository.calls, isEmpty);
  });

  test('snapshot y copias no exponen ni retienen listas mutables del llamador', () {
    final members = [worker];
    final snapshot = snapshotOf(members: members);
    members.clear();
    expect(snapshot.members, [worker]);
    expect(() => snapshot.members.clear(), throwsUnsupportedError);
    final invitations = [pendingVet];
    final copy = snapshot.copyWith(invitations: invitations);
    invitations.clear();
    expect(copy.invitations, [pendingVet]);
    expect(() => copy.invitations.clear(), throwsUnsupportedError);
  });

  test('una mutación confirmada se publica aunque el refresco falle', () async {
    final repository = FakeTeamRepository()..cached = snapshotOf();
    final cubit = _team(repository);
    addTearDown(cubit.close);
    await cubit.load();
    repository.refreshResult = const Result.failure(offlineError);
    await cubit.cancel(pendingVet);
    expect(cubit.state.snapshot!.invitations, isEmpty);
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.busyId, isNull);
    expect(cubit.state.isOffline, isTrue);
  });
  test('fallas de inicialización llegan a estados terminales sin conceder permisos', () async {
    final repository = FakeTeamRepository()
      ..membershipResult = Result.failure(teamError(TeamErrorReason.storageUnavailable));
    final invite = _invite(repository);
    final team = _team(repository);
    await invite.initialize();
    await team.load();
    expect(invite.state.initialization, isA<ResultError<List<UserRole>>>());
    expect(invite.assignableRoles, isEmpty);
    expect(team.state.isLoading, isFalse);
    expect(team.state.error, isNotNull);
    expect(team.state.canManage, isFalse);
    await invite.close();
    await team.close();
  });

  test('cerrar Equipo durante refresco no publica ni dispara otra lectura', () async {
    final pending = Completer<Result<TeamSnapshot>>();
    final repository = FakeTeamRepository()..refreshPending = pending.future;
    final cubit = _team(repository);
    final refreshing = cubit.load();
    await cubit.stream.firstWhere((state) => state.refresh is Loading<TeamSnapshot>);
    await cubit.close();
    final closedState = cubit.state;
    pending.complete(Result.success(snapshotOf()));
    await refreshing;
    expect(cubit.state, closedState);
    expect(repository.calls, ['refresh']);
  });

  test('un refresco viejo no reemplaza otro más reciente', () async {
    final repository = _DeferredRefreshRepository();
    final cubit = _team(repository);
    addTearDown(cubit.close);
    await cubit.load();
    final first = Completer<Result<TeamSnapshot>>();
    final second = Completer<Result<TeamSnapshot>>();
    repository.pending.addAll([first, second]);
    final oldRefresh = cubit.refresh();
    final newRefresh = cubit.refresh();
    final newest = snapshotOf(invitations: []);
    second.complete(Result.success(newest));
    await newRefresh;
    first.complete(Result.success(snapshotOf()));
    await oldRefresh;
    expect(cubit.state.snapshot, newest);
  });

  test('no se cambia el rol mientras se envía una invitación', () async {
    final pending = Completer<Result<CreatedInvitation>>();
    final repository = FakeTeamRepository()..invitePending = pending.future;
    final cubit = _invite(repository);
    addTearDown(cubit.close);
    await cubit.initialize();
    final sending = cubit.submit('vet@example.com');
    cubit.selectRole(UserRole.owner);
    await cubit.submit('vet@example.com');
    expect(cubit.state.role, UserRole.employee);
    expect(cubit.state.isSending, isTrue);
    pending.complete(repository.inviteResult);
    await sending;
    expect(repository.calls.where((call) => call.startsWith('invite:')), hasLength(1));
  });
  test('cerrar durante acción no emite y rechaza submits repetidos', () async {
    for (final action in ['resend', 'cancel', 'remove']) {
      final repository = _DeferredMutationRepository();
      final cubit = _team(repository);
      await cubit.load();
      Future<void> run() => switch (action) {
        'resend' => cubit.resend(pendingVet),
        'cancel' => cubit.cancel(pendingVet),
        _ => cubit.remove(worker),
      };
      final operation = run();
      await repository.started.future;
      await run();
      expect(repository.mutationCalls, 1);
      await cubit.close();
      final closedState = cubit.state;
      repository.release.complete();
      await operation;
      expect(cubit.state, closedState);
      expect(repository.calls.where((c) => c == 'refresh'), hasLength(1));
      expect(repository.cached, isNotNull);
    }
  });

  test('confirmar repetido durante canje no envía dos requests', () async {
    final pending = Completer<Result<TeamAcceptance>>();
    final repository = FakeTeamRepository()..acceptPending = pending.future;
    final cubit = JoinEstablishmentCubit(JoinEstablishmentUseCase(repository, prepareData: _prepared))..edit('7K4P2M');
    addTearDown(cubit.close);
    await cubit.check();
    final accepting = cubit.confirm();
    await cubit.confirm();
    expect(repository.calls.where((c) => c.startsWith('accept:')), hasLength(1));
    pending.complete(repository.acceptResult);
    await accepting;
    expect(cubit.state.step, JoinStep.joined);
  });

  test('no se publican resultados ni se sincroniza para una sesión reemplazada', () async {
    var current = true;
    final pending = Completer<Result<TeamAcceptance>>();
    final repository = FakeTeamRepository()..acceptPending = pending.future;
    var syncCalls = 0;
    final cubit = JoinEstablishmentCubit(
      JoinEstablishmentUseCase(
        repository,
        prepareData: () {
          syncCalls++;
          return _prepared();
        },
      ),
      isSessionCurrent: () => current,
    )..edit('7K4P2M');
    addTearDown(cubit.close);
    await cubit.check();
    final accepting = cubit.confirm();
    final before = cubit.state;
    current = false;
    pending.complete(repository.acceptResult);
    await accepting;
    expect(cubit.state, before);
    expect(syncCalls, 0);
  });
}

class _DeferredRefreshRepository extends FakeTeamRepository {
  final List<Completer<Result<TeamSnapshot>>> pending = [];
  @override
  Future<Result<TeamSnapshot>> refresh(String establishmentId) =>
      pending.isEmpty ? super.refresh(establishmentId) : pending.removeAt(0).future;
}

class _DeferredMutationRepository extends FakeTeamRepository {
  final started = Completer<void>();
  final release = Completer<void>();
  int mutationCalls = 0;
  Future<void> wait() async {
    mutationCalls++;
    started.complete();
    await release.future;
  }

  @override
  Future<Result<TeamMutation<CreatedInvitation>>> resend(String establishmentId, String invitationId) async {
    await wait();
    return super.resend(establishmentId, invitationId);
  }

  @override
  Future<Result<TeamMutation<void>>> cancel(String establishmentId, String invitationId) async {
    await wait();
    return super.cancel(establishmentId, invitationId);
  }

  @override
  Future<Result<TeamMutation<void>>> removeMember(String establishmentId, String userId) async {
    await wait();
    return super.removeMember(establishmentId, userId);
  }
}

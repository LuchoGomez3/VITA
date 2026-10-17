import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invite_team_member_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/team_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/invite_team_member_page.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/join_establishment_page.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/team_page.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:go_router/go_router.dart';

import '../team_fakes.dart';

/// Monta [page] detrás de una pantalla inicial, para que `pop` tenga a dónde
/// volver y se pueda leer lo que devuelve.
Future<List<Object?>> _pump(WidgetTester tester, Widget page) async {
  final popped = <Object?>[];
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: TextButton(
            onPressed: () async => popped.add(await context.push<Object?>('/page')),
            child: const Text('abrir'),
          ),
        ),
      ),
      GoRoute(path: '/page', builder: (context, state) => page),
      GoRoute(path: '/perfil/establecimiento/:id/equipo/invitar', builder: (context, state) => const Scaffold()),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return popped;
}

TeamPage _teamPage(FakeTeamRepository repository, UserRole role) => TeamPage(
  establishmentId: 'campo-1',
  createCubit: (id) => TeamCubit(
    establishmentId: id,
    findEstablishment: (_) async => EstablishmentMembership(id: id, name: 'La Sirena', role: role),
    readCached: ReadCachedTeamUseCase(repository),
    refreshTeam: RefreshTeamUseCase(repository),
    manageTeam: ManageTeamUseCase(repository),
  ),
);

void main() {
  group('TeamPage', () {
    testWidgets('muestra activos e invitaciones y el dueño puede invitar y gestionar', (tester) async {
      await _pump(tester, _teamPage(FakeTeamRepository(), UserRole.owner));

      expect(find.text('La Sirena'), findsOneWidget);
      expect(find.text(TeamStrings.membersSection(2)), findsOneWidget);
      expect(find.text('Cecilia Lazarte'), findsOneWidget);
      expect(find.text(TeamStrings.holderNote), findsOneWidget);
      expect(find.text(TeamStrings.invitationsSection(1)), findsOneWidget);
      expect(find.text(TeamStrings.invitedStatus), findsOneWidget);
      expect(find.text(TeamStrings.inviteFab), findsOneWidget);
      // El titular no tiene menú; el empleado y la invitación sí.
      expect(find.byTooltip(TeamStrings.actionsTooltip), findsNWidgets(2));
    });

    testWidgets('quitar pide confirmación antes de llamar al servidor', (tester) async {
      final repository = FakeTeamRepository();
      await _pump(tester, _teamPage(repository, UserRole.owner));

      await tester.tap(find.byTooltip(TeamStrings.actionsTooltip).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(TeamStrings.removeAction));
      await tester.pumpAndSettle();
      expect(find.text(TeamStrings.removeConfirmTitle('Mariano Suárez')), findsOneWidget);
      await tester.tap(find.text(TeamStrings.keepCta));
      await tester.pumpAndSettle();
      expect(repository.calls, isNot(contains('remove:u-mariano')));

      await tester.tap(find.byTooltip(TeamStrings.actionsTooltip).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(TeamStrings.removeAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TeamStrings.confirmRemoveCta));
      await tester.pumpAndSettle();

      expect(repository.calls, contains('remove:u-mariano'));
      expect(find.text(TeamStrings.removedNotice), findsOneWidget);
    });

    testWidgets('un empleado ve el equipo sin botón de invitar ni acciones', (tester) async {
      await _pump(tester, _teamPage(FakeTeamRepository(), UserRole.employee));

      expect(find.text('Mariano Suárez'), findsOneWidget);
      expect(find.text(TeamStrings.inviteFab), findsNothing);
      expect(find.byTooltip(TeamStrings.actionsTooltip), findsNothing);
    });

    testWidgets('sin conexión muestra lo guardado con el aviso y sin acciones', (tester) async {
      final repository = FakeTeamRepository()
        ..cached = snapshotOf()
        ..refreshResult = const Result.failure(offlineError);
      await _pump(tester, _teamPage(repository, UserRole.owner));

      expect(find.textContaining('Sin conexión'), findsOneWidget);
      expect(find.text('Mariano Suárez'), findsOneWidget);
      expect(find.byTooltip(TeamStrings.actionsTooltip), findsNothing);
    });
  });

  group('InviteTeamMemberPage', () {
    InviteTeamMemberPage invitePage(FakeTeamRepository repository, UserRole inviter) => InviteTeamMemberPage(
      establishmentId: 'campo-1',
      createCubit: (id) async => inviter.canManageTeam
          ? InviteTeamMemberCubit(
              establishmentId: id,
              assignableRoles: inviter.assignableRoles,
              invite: InviteTeamMemberUseCase(repository),
            )
          : null,
    );

    testWidgets('un admin no ve la opción de invitar dueños', (tester) async {
      await _pump(tester, invitePage(FakeTeamRepository(), UserRole.admin));

      expect(find.text('Administrador'), findsOneWidget);
      expect(find.text('Veterinario'), findsOneWidget);
      expect(find.text('Dueño'), findsNothing);
    });

    testWidgets('valida el email y al enviar vuelve a Equipo con true', (tester) async {
      final repository = FakeTeamRepository();
      final popped = await _pump(tester, invitePage(repository, UserRole.owner));

      await tester.tap(find.text(TeamStrings.sendCta));
      await tester.pumpAndSettle();
      expect(find.text(TeamStrings.emailRequired), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'vet@example.com');
      await tester.scrollUntilVisible(find.text('Veterinario'), 100, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Veterinario'));
      await tester.tap(find.text(TeamStrings.sendCta));
      await tester.pumpAndSettle();

      expect(repository.calls, ['invite:vet@example.com:veterinarian']);
      expect(popped, [true]);
    });

    testWidgets('quien no puede invitar vuelve sin ver el formulario', (tester) async {
      final popped = await _pump(tester, invitePage(FakeTeamRepository(), UserRole.employee));

      expect(popped, [false]);
      expect(find.text(TeamStrings.sendCta), findsNothing);
    });
  });

  group('JoinEstablishmentPage', () {
    testWidgets('con el código muestra el campo y el rol antes de sumarse', (tester) async {
      final repository = FakeTeamRepository();
      final popped = await _pump(
        tester,
        JoinEstablishmentPage(createCubit: () => JoinEstablishmentCubit(JoinEstablishmentUseCase(repository))),
      );

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      await tester.enterText(find.byType(TextFormField), 'k7qm-4xpd');
      await tester.pump();
      await tester.tap(find.text(TeamStrings.checkCta));
      await tester.pumpAndSettle();

      expect(find.text(TeamStrings.previewMessage('La Sirena', UserRole.veterinarian)), findsOneWidget);
      expect(find.text(TeamStrings.previewInvitedBy('Cecilia Lazarte')), findsOneWidget);

      await tester.tap(find.text(TeamStrings.joinCta));
      await tester.pumpAndSettle();

      expect(repository.calls, ['preview:K7QM4XPD', 'accept:K7QM4XPD']);
      expect(popped, [true]);
    });
  });
}

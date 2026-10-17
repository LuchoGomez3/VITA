import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invite_team_member_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/team_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/invitation_created_page.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/invite_team_member_page.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/join_establishment_page.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/team_page.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:go_router/go_router.dart';

import '../team_fakes.dart';

/// Monta [page] detrás de una pantalla inicial, para que `pop` tenga a dónde
/// volver y se pueda leer lo que devuelve.
Future<List<Object?>> _pump(WidgetTester tester, Widget page) async {
  // Tamaño de un celular (el del emulador): el default de los tests es más
  // chico y los botones fijos de abajo taparían el contenido.
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
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

  testWidgets('si no se pudo cargar y no hay nada guardado ofrece reintentar', (tester) async {
    final repository = FakeTeamRepository()..refreshResult = const Result.failure(DomainException(message: 'x'));
    await _pump(tester, _teamPage(repository, UserRole.owner));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(TeamStrings.loadFailed), findsOneWidget);

    repository.refreshResult = Result.success(snapshotOf());
    await tester.tap(find.text(TeamStrings.retryCta));
    await tester.pumpAndSettle();

    expect(find.text('Mariano Suárez'), findsOneWidget);
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

    testWidgets('valida el email y al enviar vuelve a Equipo con la invitación y su código', (tester) async {
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
      expect((popped.single! as CreatedInvitation).code, '7K4-P2M');
    });

    testWidgets('quien no puede invitar vuelve sin ver el formulario', (tester) async {
      final popped = await _pump(tester, invitePage(FakeTeamRepository(), UserRole.employee));

      expect(popped, [null]);
      expect(find.text(TeamStrings.sendCta), findsNothing);
    });
  });

  group('InvitationCreatedPage', () {
    final created = (invitation: pendingVet, code: '7K4-P2M');

    testWidgets('muestra el código para compartir y se puede copiar', (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      });
      final popped = await _pump(
        tester,
        InvitationCreatedPage(
          created: created,
          establishmentName: 'La Sirena',
          cancelInvitation: () async => const Result.success(null),
        ),
      );

      expect(find.text('7K4-P2M'), findsOneWidget);
      expect(find.text('vet@example.com'), findsOneWidget);
      expect(find.text(TeamStrings.codeValidity(pendingVet.expiresAt)), findsOneWidget);
      await tester.tap(find.text(TeamStrings.copyCta));
      await tester.pumpAndSettle();
      expect(copied, ['7K4-P2M']);

      await tester.tap(find.text(TeamStrings.doneCta));
      await tester.pumpAndSettle();
      expect(popped, [true]);
    });

    testWidgets('cancelar pide confirmación y vuelve a Equipo', (tester) async {
      var cancelled = 0;
      final popped = await _pump(
        tester,
        InvitationCreatedPage(
          created: created,
          establishmentName: 'La Sirena',
          cancelInvitation: () async {
            cancelled++;
            return const Result.success(null);
          },
        ),
      );

      await tester.tap(find.text(TeamStrings.cancelAction));
      await tester.pumpAndSettle();
      // El botón del diálogo dice lo mismo que el de la pantalla: es el último.
      await tester.tap(find.text(TeamStrings.confirmCancelCta).last);
      await tester.pumpAndSettle();

      expect(cancelled, 1);
      expect(popped, [true]);
    });
  });

  group('JoinEstablishmentPage', () {
    JoinEstablishmentPage joinPage(FakeTeamRepository repository) => JoinEstablishmentPage(
      createCubit: () => JoinEstablishmentCubit(
        JoinEstablishmentUseCase(repository),
        syncData: () async => Result.success(PostAuthenticationSummary(establishmentIds: const ['campo-1'])),
      ),
    );

    testWidgets('con el código muestra la confirmación del diseño y al sumarse el éxito', (tester) async {
      final repository = FakeTeamRepository();
      final popped = await _pump(tester, joinPage(repository));

      expect(find.text(TeamStrings.enterCodeTitle), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '7k4p2m');
      await tester.pump();
      expect(find.text('7'), findsOneWidget);
      await tester.tap(find.text(TeamStrings.validateCta));
      await tester.pumpAndSettle();

      expect(find.text(TeamStrings.validCode), findsOneWidget);
      expect(find.text(TeamStrings.renspa('07.123.0.00456/01')), findsOneWidget);
      expect(find.text('Coronel Moldes, Córdoba'), findsOneWidget);
      expect(find.text(TeamStrings.invitedByValue('Cecilia Lazarte', UserRole.owner)), findsOneWidget);
      expect(find.text(TeamStrings.abilitiesTitle(UserRole.veterinarian)), findsOneWidget);

      await tester.tap(find.text(TeamStrings.joinEstablishmentCta('La Sirena')));
      await tester.pumpAndSettle();

      expect(repository.calls, ['preview:7K4P2M', 'accept:7K4P2M']);
      expect(find.text(TeamStrings.joinedTitle('La Sirena')), findsOneWidget);
      expect(find.text(TeamStrings.downloadDone), findsOneWidget);
      expect(find.text(TeamStrings.goHomeCta), findsOneWidget);

      // "Ir al inicio" le devuelve el control a Perfil (que recarga la lista).
      await tester.tap(find.text(TeamStrings.goHomeCta));
      await tester.pumpAndSettle();
      expect(popped, [true]);
    });

    testWidgets('un código inválido queda en rojo con los intentos que quedan', (tester) async {
      final repository = FakeTeamRepository()
        ..previewResult = const Result.failure(
          DomainException(message: 'x', reason: (reason: TeamErrorReason.invalidCode, remainingAttempts: 4)),
        );
      await _pump(tester, joinPage(repository));

      await tester.enterText(find.byType(TextField), '7K4P2N');
      await tester.pump();
      await tester.tap(find.text(TeamStrings.validateCta));
      await tester.pumpAndSettle();

      expect(find.text('El código no es válido'), findsOneWidget);
      expect(find.text(TeamStrings.remainingAttempts(4)), findsOneWidget);

      await tester.tap(find.text(TeamStrings.clearCodeCta));
      await tester.pumpAndSettle();
      expect(find.text(TeamStrings.enterCodeIntro), findsOneWidget);
      expect(find.text('7'), findsNothing);
    });
  });
}

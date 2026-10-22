import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/get_establishment_role_use_case.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/restore_session_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/strings/login_strings.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard_source.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_establishment_select.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/initial_data_sync_repository.dart';
import 'package:frontend_mayoral/features/sync/domain/services/offline_sync_coordinator.dart';
import 'package:frontend_mayoral/features/sync/domain/use_cases/prepare_initial_data_sync_use_case.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/data/repositories/team_repository_impl.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/join_establishment_page.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../team_fakes.dart';

const _newField = <String, Object?>{
  'id': 'campo-1',
  'owner_id': 'owner',
  'nombre': 'La Sirena',
  'name': 'La Sirena',
  'rol': 'veterinarian',
  'role': 'veterinarian',
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': '2026-10-20T00:00:00Z',
};
const _oldField = <String, Object?>{
  'id': 'old',
  'owner_id': 'owner',
  'name': 'Campo anterior',
  'role': 'owner',
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': '2026-10-20T00:00:00Z',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login sin campos abre canje, cancela y accede al campo aceptado durante descarga', (tester) async {
    final harness = _Harness();
    await harness.pump(tester, authenticated: false);
    harness.router.go(AppRoutes.login);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'vet@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'synthetic-password');
    await tester.tap(find.text(LoginStrings.submitButton));
    await tester.pumpAndSettle();
    expect(harness.router.routeInformationProvider.value.uri.path, AppRoutes.establishmentRegisterEmpty);
    await tester.tap(find.text(EstablishmentRegisterStrings.emptyStateJoinExistingButton));
    await tester.pumpAndSettle();
    expect(find.byType(JoinEstablishmentPage), findsOneWidget);
    expect(harness.router.canPop(), isTrue);
    harness.router.pop();
    await tester.pumpAndSettle();
    expect(harness.router.routeInformationProvider.value.uri.path, AppRoutes.establishmentRegisterEmpty);
    await tester.tap(find.text(EstablishmentRegisterStrings.emptyStateJoinExistingButton));
    await tester.pumpAndSettle();
    await harness.enterAndConfirm(tester);
    expect(harness.join.state.step, JoinStep.joined);
    expect(harness.download.isCompleted, isFalse);
    await tester.tap(find.text(TeamStrings.goHomeCta));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(harness.join.isClosed, isTrue);
    await harness.selectNewField(tester);
    harness.download.complete(const Result.failure(offlineError));
    await tester.pumpAndSettle();
    expect(harness.home.state.establishments, contains('campo-1'));
    expect(harness.home.state.selectedEstablishmentId, 'campo-1');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inicio montado recibe membresía aunque se cierre el canje antes del ciclo viejo y falle la descarga', (
    tester,
  ) async {
    final harness = _Harness(withOldField: true, delayOldCatalog: true);
    await harness.pump(tester);
    await tester.pump();
    final mountedHome = harness.home;
    expect(mountedHome.state.establishments, contains('old'));
    expect(harness.sync.calls, 1);
    harness.router.go(AppRoutes.profile);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(ProfileStrings.joinEstablishmentLabel));
    await tester.tap(find.text(ProfileStrings.joinEstablishmentLabel));
    await tester.pumpAndSettle();
    harness.router.pop();
    await tester.pumpAndSettle();
    expect(harness.router.routeInformationProvider.value.uri.path, AppRoutes.profile);
    await tester.tap(find.text(ProfileStrings.joinEstablishmentLabel));
    await tester.pumpAndSettle();
    await harness.enterAndConfirm(tester);
    expect(harness.join.state.step, JoinStep.joining, reason: harness.join.state.toString());
    expect(harness.accepted, isTrue);
    // La respuesta de la consulta vieja todavía no escribió su catálogo.
    expect(harness.join.state.step, JoinStep.joining);
    harness.router.pop();
    harness.router.go(AppRoutes.home);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(harness.join.isClosed, isTrue);
    harness.oldCatalog.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(identical(harness.home, mountedHome), isTrue);
    expect(harness.sync.calls, 2);
    expect(harness.download.isCompleted, isFalse);
    await harness.selectNewField(tester);
    harness.download.complete(const Result.failure(offlineError));
    await tester.pumpAndSettle();
    expect(identical(harness.home, mountedHome), isTrue);
    expect(harness.home.state.establishments.keys, containsAll(['old', 'campo-1']));
    expect((await harness.catalog.getById('campo-1'))?.name, 'La Sirena');
    expect(tester.takeException(), isNull);
  });
}

class _Harness {
  _Harness({this.withOldField = false, this.delayOldCatalog = false}) {
    if (withOldField) storage.values[SecureStorageKeys.establishmentCatalog] = jsonEncode([_oldField]);
    catalog = EstablishmentCatalog(secureStorage: storage);
    sync = _Sync(this);
    coordinator = OfflineSyncCoordinator(prepareInitialDataSyncUseCase: PrepareInitialDataSyncUseCase(sync));
  }
  final bool withOldField;
  final bool delayOldCatalog;
  final storage = MemoryStorage();
  final oldCatalog = Completer<void>();
  final download = Completer<Result<PostAuthenticationSummary>>();
  late final EstablishmentCatalog catalog;
  late final _Sync sync;
  late final OfflineSyncCoordinator coordinator;
  late GoRouter router;
  late HomeDashboardCubit home;
  late JoinEstablishmentCubit join;
  bool accepted = false;

  Future<void> pump(WidgetTester tester, {bool authenticated = true}) async {
    tester.view
      ..physicalSize = const Size(390, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SessionBackendAccessTokenProvider.instance.clearAccessToken();
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      final arguments = (call.arguments as Map).cast<String, Object?>();
      final key = arguments['key'] as String?;
      return switch (call.method) {
        'read' => storage.values[key],
        'write' => storage.values[key!] = arguments['value']! as String,
        'delete' => storage.values.remove(key),
        _ => null,
      };
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
    final authRepository = _AuthRepository();
    final auth = AuthSessionCubit(
      restoreSessionUseCase: RestoreSessionUseCase(authRepository),
      signOutUseCase: SignOutUseCase(authRepository),
    );
    if (authenticated) {
      auth.setAuthenticated(_session);
    } else {
      await auth.restoreSession();
    }
    final refresh = AuthRouterRefreshNotifier(auth);
    router = AppRouter.create(
      authSessionCubit: auth,
      refreshListenable: refresh,
      getEstablishmentRole: GetEstablishmentRoleUseCase(catalog),
      createHomeCubit: () => home = HomeDashboardCubit(
        getHomeDashboardUseCase: GetHomeDashboardUseCase(_HomeRepository(catalog)),
        getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(_HomeRepository(catalog)),
        refreshOfflineData: coordinator.synchronize,
        syncResults: coordinator.results,
      ),
      loginBlocFactory: () => LoginBloc(
        signInUseCase: SignInUseCase(authRepository),
        preparePostAuthentication: () async => Result.success(PostAuthenticationSummary(establishmentIds: [])),
      ),
      joinCubitFactory: () {
        final repository = TeamRepositoryImpl(
          remote: TeamRemoteDataSource(
            baseUrl: 'https://api.example.com',
            tokenProvider: _Token(),
            client: MockClient((request) async {
              if (request.url.path.endsWith('/validaciones')) {
                return _ok({
                  'establecimiento_id': 'campo-1',
                  'establecimiento_nombre': 'La Sirena',
                  'rol': 'veterinarian',
                  'email': 'vet@example.com',
                  'invitado_por': 'Cecilia',
                  'expira_en': '2026-10-27T00:00:00Z',
                });
              }
              expect(request.url.path, '/api/v1/invitaciones/aceptaciones');
              accepted = true;
              return _ok(_newField);
            }),
          ),
          secureStorage: storage,
          establishmentCatalog: catalog,
          updateCatalog: (persist) => coordinator.updateCatalog(() async {
            await persist();
            return PostAuthenticationSummary(
              establishmentIds: (await catalog.getMemberships()).map((m) => m.id).toList(),
            );
          }),
        );
        return join = JoinEstablishmentCubit(
          JoinEstablishmentUseCase(repository, prepareData: coordinator.synchronize),
        );
      },
    );
    addTearDown(() async {
      router.dispose();
      refresh.dispose();
      await auth.close();
      await coordinator.dispose();
    });
    await tester.pumpWidget(
      BlocProvider.value(
        value: auth,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> enterAndConfirm(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), '7K4P2M');
    await tester.pump();
    await tester.tap(find.text(TeamStrings.validateCta));
    await tester.pumpAndSettle();
    await tester.tap(find.text(TeamStrings.joinEstablishmentCta('La Sirena')));
    await tester.pump();
    for (var frame = 0; frame < 20 && !accepted; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> selectNewField(WidgetTester tester) async {
    await tester.tap(find.byType(HomeEstablishmentSelect));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('La Sirena'), findsOneWidget);
    await tester.tap(find.text('La Sirena'));
    await tester.pump();
    expect(home.state.selectedEstablishmentId, 'campo-1');
  }
}

class _Sync implements InitialDataSyncRepository {
  _Sync(this.harness);
  final _Harness harness;
  int calls = 0;
  @override
  Future<Result<PostAuthenticationSummary>> sync() async {
    calls++;
    // La consulta ve la membresía en el momento de iniciarse, no al responder.
    final fields = [if (harness.withOldField) _oldField, if (harness.accepted) _newField];
    if (harness.delayOldCatalog && calls == 1) await harness.oldCatalog.future;
    await harness.storage.write(key: SecureStorageKeys.establishmentCatalog, value: jsonEncode(fields));
    if (harness.accepted && !(harness.delayOldCatalog && calls == 1)) return harness.download.future;
    return Result.success(PostAuthenticationSummary(establishmentIds: fields.map((e) => e['id']! as String).toList()));
  }
}

class _HomeRepository implements HomeDashboardRepository {
  _HomeRepository(this.catalog);
  final EstablishmentCatalog catalog;
  @override
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments() async =>
      Result.success({for (final m in await catalog.getMemberships()) m.id: m});
  @override
  Future<Result<HomeDashboardSource>> getDashboardSource({Set<String>? establishmentIds}) async => const Result.success(
    HomeDashboardSource(animals: [], weighings: [], categoryNamesById: {}, operatingExpensesCents: 0),
  );
}

class _Token implements BackendAccessTokenProvider {
  @override
  Future<String?> getAccessToken() async => 'synthetic-token';
}

http.Response _ok(Object data) => http.Response(
  jsonEncode({'success': true, 'data': data}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
final _session = AuthSession(
  user: const AppUser(id: 'user', email: 'vet@example.com', firstName: 'Persona', lastName: 'Sintética'),
  accessToken: 'synthetic-token',
  refreshToken: 'synthetic-refresh',
  accessTokenExpiresAt: DateTime.utc(2030),
);

class _AuthRepository implements AuthRepository {
  @override
  Future<Result<AuthSession>> restoreSession() async => const Result.failure(offlineError);
  @override
  Future<Result<AuthSession>> signIn({required String email, required String password}) async =>
      Result.success(_session);
  @override
  Future<void> signOut() async {}
  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

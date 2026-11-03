import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/models/stored_auth_session.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/restore_session_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/data/repositories/team_repository_impl.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/team_composition.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../team_fakes.dart';

void main() {
  final provider = SessionBackendAccessTokenProvider.instance;
  setUp(provider.clearAccessToken);
  tearDown(() {
    provider
      ..clearAccessToken()
      ..refreshCallback = null;
  });

  for (final (operation, cleanupFailure) in [
    for (final operation in ['equipo', 'validar', 'aceptar', 'invitar', 'cancelar', 'equipo sin sesión local'])
      for (final failure in [null, PlatformException(code: 'storage-unavailable'), TimeoutException('delete')])
        (operation, failure),
  ]) {
    test('$operation sale de la ruta protegida (limpieza: ${cleanupFailure?.runtimeType})', () async {
      final storage = _DeleteFailingStorage()
        ..failure = cleanupFailure
        ..failedKey = cleanupFailure is TimeoutException
            ? SecureStorageKeys.teamSnapshot
            : SecureStorageKeys.authSession;
      storage.values[SecureStorageKeys.authSession] = StoredAuthSession.fromDomain(_session).toEncodedJson();
      storage.values[SecureStorageKeys.establishmentCatalog] = jsonEncode([
        {'id': 'campo-1', 'name': 'Campo sintético', 'role': 'owner'},
      ]);
      final authClient = MockClient((request) async {
        expect(request.url.path, '/api/auth/refresh');
        return http.Response(jsonEncode({'detail': 'invalid refresh'}), 401);
      });
      addTearDown(authClient.close);
      final authRepository = AuthRepositoryImpl(
        localDataSource: AuthLocalDataSource(secureStorage: storage),
        remoteDataSource: AuthRemoteDataSource(backendBaseUrl: 'https://api.example.com', client: authClient),
        tokenProvider: provider,
      );
      provider
        ..session = BackendTokenSession(
          accessToken: _session.accessToken,
          refreshToken: _session.refreshToken,
          accessTokenExpiresAt: _session.accessTokenExpiresAt,
        )
        ..refreshCallback = (token) async {
          final result = await authRepository.refreshSession(refreshTokenOverride: token);
          return switch (result) {
            Failure<AuthSession>(:final error) => throw error,
            _ => throw StateError('Unexpected successful refresh'),
          };
        };
      final auth = AuthSessionCubit(
        restoreSessionUseCase: RestoreSessionUseCase(authRepository),
        signOutUseCase: SignOutUseCase(authRepository),
        authRejections: [provider.authRejections],
      )..setAuthenticated(_session);
      addTearDown(auth.close);
      final generation = provider.sessionGeneration;
      bool isCurrent() => generation == provider.sessionGeneration;
      var teamRequests = 0;
      final teamClient = MockClient((request) async {
        teamRequests++;
        final data = request.url.path.endsWith('/validaciones')
            ? {
                'establecimiento_id': 'campo-1',
                'establecimiento_nombre': 'Campo sintético',
                'rol': 'employee',
                'expira_en': '2030-01-01T00:00:00Z',
              }
            : <Object?>[];
        return http.Response(
          jsonEncode({'success': true, 'data': data}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      addTearDown(teamClient.close);
      final repository = TeamRepositoryImpl(
        remote: TeamRemoteDataSource(
          baseUrl: 'https://api.example.com',
          tokenProvider: provider,
          client: teamClient,
          isSessionCurrent: isCurrent,
        ),
        secureStorage: storage,
        establishmentCatalog: EstablishmentCatalog(secureStorage: storage),
        isSessionCurrent: isCurrent,
        persistSessionData: provider.persistSessionData,
      );
      final team = createTeamCubit('campo-1', repository: repository);
      final join = createJoinEstablishmentCubit(
        repository: repository,
        prepareData: () async => Result.success(PostAuthenticationSummary(establishmentIds: ['campo-1'])),
      );
      final invite = createInviteTeamMemberCubit('campo-1', repository: repository);
      final created = createInvitationCreatedCubit('campo-1', pendingVet, repository: repository);
      addTearDown(team.close);
      addTearDown(join.close);
      addTearDown(invite.close);
      addTearDown(created.close);
      await team.load();
      await invite.initialize();
      join.edit('7K4P2M');
      if (operation == 'aceptar') {
        await join.check();
        expect(join.state.step, JoinStep.confirm);
      }
      final requestsBeforeExpiry = teamRequests;
      final signedOut = auth.stream.firstWhere(
        (state) => state is AuthSessionUnauthenticated || state is AuthSessionCleanupFailed,
      );
      if (operation == 'equipo sin sesión local') storage.values.remove(SecureStorageKeys.authSession);
      provider.session = BackendTokenSession(
        accessToken: 'expired',
        refreshToken: 'revoked',
        accessTokenExpiresAt: DateTime.utc(2000),
      );

      switch (operation) {
        case 'equipo' || 'equipo sin sesión local':
          await team.refresh();
        case 'validar':
          await join.check();
        case 'aceptar':
          await join.confirm();
        case 'invitar':
          await invite.submit('synthetic@example.com');
        case 'cancelar':
          await created.cancel();
      }
      await signedOut;

      if (cleanupFailure != null) {
        expect(auth.state, isA<AuthSessionCleanupFailed>());
        for (final route in [AppRoutes.home, AppRoutes.joinEstablishment, AppRoutes.login, AppRoutes.signUpForm]) {
          expect(AppRouter.redirectFor(authState: auth.state, location: route), AppRoutes.authCheck);
        }
        await auth.restoreSession();
        auth.setAuthenticated(_session);
        expect(auth.state, isA<AuthSessionCleanupFailed>(), reason: 'La limpieza pendiente no permite otra cuenta');
        storage.failure = null;
        await auth.signOut();
      }
      expect(auth.state, isA<AuthSessionUnauthenticated>());
      expect(provider.session, isNull);
      expect(teamRequests, requestsBeforeExpiry, reason: 'No se envía HTTP con el token vencido');
      expect(storage.values[SecureStorageKeys.authSession], isNull);
      expect(storage.values[SecureStorageKeys.establishmentCatalog], isNull);
      expect(storage.values[SecureStorageKeys.teamSnapshot], isNull);
      expect(
        AppRouter.redirectFor(
          authState: auth.state,
          location: operation.startsWith('equipo') ? AppRoutes.teamFor('campo-1') : AppRoutes.joinEstablishment,
        ),
        AppRoutes.signUp,
      );
    });
  }
}

class _DeleteFailingStorage extends MemoryStorage {
  Exception? failure;
  String? failedKey;

  @override
  Future<void> delete(String key) async {
    if (failure case final error? when key == failedKey) throw error;
    await super.delete(key);
  }
}

final _session = AuthSession(
  user: const AppUser(
    id: 'synthetic-user',
    email: 'synthetic@example.com',
    firstName: 'Persona',
    lastName: 'Sintética',
  ),
  accessToken: 'synthetic-token',
  refreshToken: 'synthetic-refresh',
  accessTokenExpiresAt: DateTime.utc(2030),
);

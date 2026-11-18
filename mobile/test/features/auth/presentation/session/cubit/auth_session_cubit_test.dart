import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/restore_session_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/pages/auth_check_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/strings/auth_session_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('la limpieza fallida muestra reintento y solo después permite entrar', (tester) async {
    final repository = _AuthRepository()..signOutFailure = const DomainException(message: 'Cleanup failed');
    final cubit = AuthSessionCubit(
      restoreSessionUseCase: RestoreSessionUseCase(repository),
      signOutUseCase: SignOutUseCase(repository),
    )..setAuthenticated(_session);
    addTearDown(cubit.close);
    await cubit.signOut();
    final refresh = AuthRouterRefreshNotifier(cubit);
    final router = GoRouter(
      initialLocation: AppRoutes.authCheck,
      refreshListenable: refresh,
      redirect: (_, state) => AppRouter.redirectFor(authState: cubit.state, location: state.uri.path),
      routes: [
        GoRoute(path: AppRoutes.authCheck, builder: (_, _) => const AuthCheckPage()),
        GoRoute(
          path: AppRoutes.signUp,
          builder: (_, _) => const Scaffold(body: Text('Auth entry')),
        ),
      ],
    );
    addTearDown(router.dispose);
    addTearDown(refresh.dispose);
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    expect(find.text(AuthSessionStrings.cleanupFailed), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    repository.signOutFailure = null;
    await tester.tap(find.text(AuthSessionStrings.retryCleanup));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.signUp);
    expect(find.text('Auth entry'), findsOneWidget);
    expect(repository.signOutCalls, 2);
  });

  test('escucha ambas fuentes de rechazo y cancela suscripciones al cerrar', () async {
    final brick = StreamController<void>.broadcast(sync: true);
    final direct = StreamController<void>.broadcast(sync: true);
    addTearDown(brick.close);
    addTearDown(direct.close);
    final repository = _AuthRepository();
    final cubit = AuthSessionCubit(
      restoreSessionUseCase: RestoreSessionUseCase(repository),
      signOutUseCase: SignOutUseCase(repository),
      authRejections: [brick.stream, direct.stream],
    )..setAuthenticated(_session);
    final invalidated = cubit.stream.firstWhere((state) => state is AuthSessionUnauthenticated);
    direct.add(null);
    brick.add(null);
    await invalidated;
    expect(repository.signOutCalls, 1);
    expect(brick.hasListener, isTrue);
    expect(direct.hasListener, isTrue);
    await cubit.close();
    expect(brick.hasListener, isFalse);
    expect(direct.hasListener, isFalse);
  });

  test('restores locally before starting the non-blocking sync', () async {
    final syncStarted = Completer<void>();
    final syncFinished = Completer<Result<PostAuthenticationSummary>>();
    final repository = _AuthRepository();
    final cubit = AuthSessionCubit(
      restoreSessionUseCase: RestoreSessionUseCase(repository),
      signOutUseCase: SignOutUseCase(repository),
      refreshOfflineData: () {
        syncStarted.complete();
        return syncFinished.future;
      },
    );

    await cubit.restoreSession();
    await syncStarted.future;

    expect(cubit.state, AuthSessionState.authenticated(_session));
    expect(syncFinished.isCompleted, isFalse);

    syncFinished.complete(
      Result.success(
        PostAuthenticationSummary(establishmentIds: const ['farm-id']),
      ),
    );
    await cubit.close();
  });
}

final _session = AuthSession(
  user: const AppUser(
    id: 'user-id',
    email: 'producer@example.com',
    firstName: 'Ana',
    lastName: 'Productora',
  ),
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  accessTokenExpiresAt: DateTime.utc(2026, 10, 15, 18),
);

class _AuthRepository implements AuthRepository {
  int signOutCalls = 0;
  DomainException? signOutFailure;
  @override
  Future<Result<AuthSession>> restoreSession() async => Result.success(_session);

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutFailure case final error?) throw error;
  }

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) => throw StateError('Unexpected signIn call');

  @override
  Future<Result<AuthSession>> register({
    required RegistrationRequest request,
  }) => throw StateError('Unexpected register call');

  @override
  Future<Result<AuthSession>> refreshSession() => throw StateError('Unexpected refreshSession call');

  @override
  Future<Result<AuthSession>> getCurrentSession() => throw StateError('Unexpected getCurrentSession call');

  @override
  Future<Result<AppUser>> getCurrentUser() => throw StateError('Unexpected getCurrentUser call');
}

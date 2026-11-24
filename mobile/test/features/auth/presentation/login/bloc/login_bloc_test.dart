import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/pages/login_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/strings/login_strings.dart';

void main() {
  testWidgets('anima el botón durante el login y muestra cuándo prepara los datos', (tester) async {
    final signIn = Completer<Result<AuthSession>>();
    final sync = Completer<Result<PostAuthenticationSummary>>();
    final repository = _LoginAuthRepository(signInResult: Result.success(_session), pendingSignIn: signIn.future);
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          createBloc: () => LoginBloc(
            signInUseCase: SignInUseCase(repository),
            preparePostAuthentication: () => sync.future,
          ),
        ),
      ),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'ernesto@example.com');
    await tester.enterText(fields.last, 'Password1');
    await tester.tap(find.text(LoginStrings.submitButton));
    await tester.pump();
    expect(find.text(LoginStrings.submittingButton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    signIn.complete(Result.success(_session));
    await tester.pump();
    expect(find.text(LoginStrings.preparingOfflineDataButton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    sync.complete(Result.success(PostAuthenticationSummary(establishmentIds: [])));
    await tester.pump();
  });

  test('keeps the reusable preparation summary after a successful login', () async {
    final repository = _LoginAuthRepository(
      signInResult: Result.success(_session),
    );
    final bloc =
        LoginBloc(
          signInUseCase: SignInUseCase(repository),
          preparePostAuthentication: () async {
            return Result.success(
              PostAuthenticationSummary(establishmentIds: ['establishment-1']),
            );
          },
        )..add(
          const LoginSubmitted(
            email: ' ernesto@example.com ',
            password: 'Password1',
          ),
        );
    await _waitForLogin(bloc);

    expect(repository.receivedEmail, 'ernesto@example.com');
    expect(bloc.state.signInResult, ResultState<AuthSession>.data(_session));
    expect(bloc.state.initialDataSyncError, isNull);
    expect(bloc.state.postAuthenticationSummary?.hasEstablishments, isTrue);
    await bloc.close();
  });

  test('keeps the authenticated session when offline preparation fails', () async {
    const syncError = DomainException(
      message: 'No se pudieron preparar los datos offline.',
      code: DomainErrorCode.syncFailed,
    );
    final bloc =
        LoginBloc(
          signInUseCase: SignInUseCase(
            _LoginAuthRepository(signInResult: Result.success(_session)),
          ),
          preparePostAuthentication: () async => const Result.failure(syncError),
        )..add(
          const LoginSubmitted(
            email: 'ernesto@example.com',
            password: 'Password1',
          ),
        );
    await _waitForLogin(bloc);

    expect(bloc.state.signInResult, ResultState<AuthSession>.data(_session));
    expect(bloc.state.initialDataSyncError, syncError);
    expect(bloc.state.postAuthenticationSummary, isNull);
    await bloc.close();
  });
}

Future<void> _waitForLogin(LoginBloc bloc) async {
  await bloc.stream.firstWhere(
    (state) => state.signInResult is Data<AuthSession>,
  );
}

final _session = AuthSession(
  user: const AppUser(
    id: 'user-1',
    email: 'ernesto@example.com',
    firstName: 'Ernesto',
    lastName: 'Diaz',
  ),
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  accessTokenExpiresAt: DateTime.utc(2026, 8, 8, 15),
);

class _LoginAuthRepository implements AuthRepository {
  _LoginAuthRepository({required this.signInResult, this.pendingSignIn});

  final Result<AuthSession> signInResult;
  final Future<Result<AuthSession>>? pendingSignIn;
  String? receivedEmail;

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    receivedEmail = email;
    return pendingSignIn ?? signInResult;
  }

  @override
  Future<Result<AuthSession>> register({required RegistrationRequest request}) => throw UnimplementedError();

  @override
  Future<Result<AuthSession>> restoreSession() => throw UnimplementedError();

  @override
  Future<Result<AuthSession>> refreshSession() => throw UnimplementedError();

  @override
  Future<Result<AuthSession>> getCurrentSession() => throw UnimplementedError();

  @override
  Future<Result<AppUser>> getCurrentUser() => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

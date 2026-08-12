import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_event.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_state.dart';

void main() {
  test('registers, signs in and prepares offline data in order', () async {
    final repository = _SignUpAuthRepository(
      registrationResult: const Result.success(_user),
      signInResult: Result.success(_session),
    );
    final preparationUserIds = <String>[];
    final bloc = _createBloc(
      repository,
      preparePostAuthentication: (userId) async {
        preparationUserIds.add(userId);
        return const Result.success(
          PostAuthenticationSummary(establishmentIds: []),
        );
      },
    );
    final stages = <SignUpStage>[];
    final subscription = bloc.stream.listen((state) => stages.add(state.stage));

    bloc.add(const SignUpSubmitted(request: _request));
    await bloc.stream.firstWhere((state) => state.stage == SignUpStage.success);

    expect(stages, [
      SignUpStage.registering,
      SignUpStage.signingIn,
      SignUpStage.preparingOfflineData,
      SignUpStage.success,
    ]);
    expect(repository.receivedEmail, _request.email);
    expect(repository.receivedPassword, _request.password);
    expect(preparationUserIds, [_user.id]);
    expect(bloc.state.session, _session);
    expect(bloc.state.preparationSummary?.hasEstablishments, isFalse);
    await subscription.cancel();
    await bloc.close();
  });

  test('does not auto-login when account registration fails', () async {
    const error = DomainException(message: 'El email ya esta registrado.');
    final repository = _SignUpAuthRepository(
      registrationResult: const Result.failure(error),
      signInResult: Result.success(_session),
    );
    final bloc = _createBloc(repository)..add(const SignUpSubmitted(request: _request));
    await bloc.stream.firstWhere((state) => state.stage == SignUpStage.failure);

    expect(repository.signInCalls, 0);
    expect(bloc.state.error, error);
    expect(bloc.state.accountCreated, isFalse);
    await bloc.close();
  });

  test('reports auto-login failure after the account was created', () async {
    const error = DomainException(message: 'No se pudo iniciar sesion.');
    final repository = _SignUpAuthRepository(
      registrationResult: const Result.success(_user),
      signInResult: const Result.failure(error),
    );
    final bloc = _createBloc(repository)..add(const SignUpSubmitted(request: _request));
    await bloc.stream.firstWhere((state) => state.stage == SignUpStage.failure);

    expect(bloc.state.error, error);
    expect(bloc.state.accountCreated, isTrue);
    expect(bloc.state.session, isNull);
    await bloc.close();
  });

  test('keeps the session when offline preparation fails', () async {
    const error = DomainException(
      message: 'No se pudieron preparar los datos offline.',
      code: DomainErrorCode.syncFailed,
    );
    final repository = _SignUpAuthRepository(
      registrationResult: const Result.success(_user),
      signInResult: Result.success(_session),
    );
    final bloc = _createBloc(
      repository,
      preparePostAuthentication: (_) async => const Result.failure(error),
    )..add(const SignUpSubmitted(request: _request));
    await bloc.stream.firstWhere((state) => state.stage == SignUpStage.success);

    expect(bloc.state.session, _session);
    expect(bloc.state.preparationError, error);
    await bloc.close();
  });

  test('ignores a repeated submit while registration is running', () async {
    final registration = Completer<Result<AppUser>>();
    final repository = _SignUpAuthRepository(
      registrationResult: registration.future,
      signInResult: Result.success(_session),
    );
    final bloc = _createBloc(repository)
      ..add(const SignUpSubmitted(request: _request))
      ..add(const SignUpSubmitted(request: _request));
    await Future<void>.delayed(Duration.zero);
    registration.complete(const Result.success(_user));
    await bloc.stream.firstWhere((state) => state.stage == SignUpStage.success);

    expect(repository.registrationCalls, 1);
    await bloc.close();
  });
}

SignUpBloc _createBloc(
  _SignUpAuthRepository repository, {
  PreparePostAuthentication? preparePostAuthentication,
}) {
  return SignUpBloc(
    registerUserUseCase: RegisterUserUseCase(repository),
    signInUseCase: SignInUseCase(repository),
    preparePostAuthentication:
        preparePostAuthentication ??
        (_) async => const Result.success(
          PostAuthenticationSummary(establishmentIds: []),
        ),
  );
}

const _request = RegistrationRequest(
  firstName: 'Ernesto',
  lastName: 'Diaz',
  email: 'ernesto@example.com',
  cuit: '20-12345678-6',
  password: 'Password1',
);

const _user = AppUser(
  id: 'user-id',
  email: 'ernesto@example.com',
  firstName: 'Ernesto',
  lastName: 'Diaz',
  cuit: '20123456786',
);

final _session = AuthSession(
  user: _user,
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  accessTokenExpiresAt: DateTime.utc(2026, 8, 8, 15),
);

class _SignUpAuthRepository implements AuthRepository {
  _SignUpAuthRepository({
    required this.registrationResult,
    required this.signInResult,
  });

  final FutureOr<Result<AppUser>> registrationResult;
  final Result<AuthSession> signInResult;
  int registrationCalls = 0;
  int signInCalls = 0;
  String? receivedEmail;
  String? receivedPassword;

  @override
  Future<Result<AppUser>> register({
    required RegistrationRequest request,
  }) async {
    registrationCalls += 1;
    return registrationResult;
  }

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls += 1;
    receivedEmail = email;
    receivedPassword = password;
    return signInResult;
  }

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

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_event.dart';

void main() {
  test('keeps submission blocked while navigating after success', () {
    final state = SignUpState(
      stage: SignUpStage.success,
      session: _session,
      accountCreated: true,
    );

    expect(state.isProcessing, isTrue);
  });

  test('registers and signs in automatically in order', () async {
    final repository = _SignUpAuthRepository(
      registrationResult: Result.success(_session),
    );
    final bloc = _createBloc(repository);
    final stages = <SignUpStage>[];
    final subscription = bloc.stream.listen((state) => stages.add(state.stage));

    bloc.add(const SignUpSubmitted(request: _request));
    await bloc.stream.firstWhere((state) => state.stage == SignUpStage.success);

    expect(stages, [
      SignUpStage.registering,
      SignUpStage.success,
    ]);
    expect(bloc.state.session, _session);
    await subscription.cancel();
    await bloc.close();
  });

  test('does not auto-login when account registration fails', () async {
    const error = DomainException(message: 'El email ya esta registrado.');
    final repository = _SignUpAuthRepository(
      registrationResult: const Result.failure(error),
    );
    final bloc = _createBloc(repository)..add(const SignUpSubmitted(request: _request));
    await bloc.stream.firstWhere((state) => state.stage == SignUpStage.failure);

    expect(bloc.state.error, error);
    expect(bloc.state.accountCreated, isFalse);
    await bloc.close();
  });

  test('ignores a repeated submit while registration is running', () async {
    final registration = Completer<Result<AuthSession>>();
    final repository = _SignUpAuthRepository(
      registrationResult: registration.future,
    );
    final bloc = _createBloc(repository)
      ..add(const SignUpSubmitted(request: _request))
      ..add(const SignUpSubmitted(request: _request));
    await Future<void>.delayed(Duration.zero);
    registration.complete(Result.success(_session));
    await bloc.stream.firstWhere((state) => state.stage == SignUpStage.success);

    expect(repository.registrationCalls, 1);
    await bloc.close();
  });
}

SignUpBloc _createBloc(_SignUpAuthRepository repository) {
  return SignUpBloc(
    registerUserUseCase: RegisterUserUseCase(repository),
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
  });

  final FutureOr<Result<AuthSession>> registrationResult;
  int registrationCalls = 0;

  @override
  Future<Result<AuthSession>> register({
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
    throw UnimplementedError();
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

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_event.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_state.dart';

void main() {
  const request = RegistrationRequest(
    firstName: 'Ernesto',
    lastName: 'Diaz',
    email: 'ernesto@example.com',
    cuit: '20-12345678-6',
    password: 'Password1',
  );

  test('emits loading and data when registration succeeds', () async {
    final repository = _SignUpAuthRepository(
      result: const Result.success(
        AppUser(
          id: 'user-id',
          email: 'ernesto@example.com',
          firstName: 'Ernesto',
          lastName: 'Diaz',
          cuit: '20123456786',
        ),
      ),
    );
    final bloc = SignUpBloc(
      registerUserUseCase: RegisterUserUseCase(repository),
    );
    final states = <SignUpState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const SignUpSubmitted(request: request));
    await Future<void>.delayed(Duration.zero);

    expect(
      states,
      const [
        ResultState<AppUser>.loading(),
        ResultState<AppUser>.data(
          AppUser(
            id: 'user-id',
            email: 'ernesto@example.com',
            firstName: 'Ernesto',
            lastName: 'Diaz',
            cuit: '20123456786',
          ),
        ),
      ],
    );
    await subscription.cancel();
    await bloc.close();
  });

  test('emits loading and error when registration fails', () async {
    const error = DomainException(message: 'El email ya esta registrado.');
    final repository = _SignUpAuthRepository(
      result: const Result.failure(error),
    );
    final bloc = SignUpBloc(
      registerUserUseCase: RegisterUserUseCase(repository),
    );
    final states = <SignUpState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const SignUpSubmitted(request: request));
    await Future<void>.delayed(Duration.zero);

    expect(states, const [
      ResultState<AppUser>.loading(),
      ResultState<AppUser>.error(error),
    ]);
    await subscription.cancel();
    await bloc.close();
  });

  test('releases its owned resources when closed', () async {
    var wasClosed = false;
    final bloc = SignUpBloc(
      registerUserUseCase: RegisterUserUseCase(
        _SignUpAuthRepository(
          result: const Result.failure(
            DomainException(message: 'Resultado no usado en este test.'),
          ),
        ),
      ),
      onClose: () => wasClosed = true,
    );

    await bloc.close();

    expect(wasClosed, isTrue);
  });

  test('ignores a second registration while the first one is loading', () async {
    final registration = Completer<Result<AppUser>>();
    final repository = _SignUpAuthRepository(
      result: registration.future,
    );
    final bloc = SignUpBloc(
      registerUserUseCase: RegisterUserUseCase(repository),
    );

    bloc.add(const SignUpSubmitted(request: request));
    await Future<void>.delayed(Duration.zero);
    bloc.add(const SignUpSubmitted(request: request));
    registration.complete(
      const Result.success(
        AppUser(
          id: 'user-id',
          email: 'ernesto@example.com',
          firstName: 'Ernesto',
          lastName: 'Diaz',
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repository.registrationCalls, 1);
    await bloc.close();
  });
}

class _SignUpAuthRepository implements AuthRepository {
  _SignUpAuthRepository({required this.result});

  final FutureOr<Result<AppUser>> result;
  int registrationCalls = 0;

  @override
  Future<Result<AppUser>> register({
    required RegistrationRequest request,
  }) async {
    registrationCalls += 1;
    return result;
  }

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) {
    return _unusedSessionResult();
  }

  @override
  Future<Result<AuthSession>> restoreSession() => _unusedSessionResult();

  @override
  Future<Result<AuthSession>> refreshSession() => _unusedSessionResult();

  @override
  Future<Result<AuthSession>> getCurrentSession() => _unusedSessionResult();

  @override
  Future<Result<AppUser>> getCurrentUser() async {
    return const Result.failure(
      DomainException(message: 'Operacion no usada en este test.'),
    );
  }

  @override
  Future<void> signOut() async {}

  Future<Result<AuthSession>> _unusedSessionResult() async {
    return const Result.failure(
      DomainException(message: 'Operacion no usada en este test.'),
    );
  }
}

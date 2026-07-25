import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';

void main() {
  test('delegates the registration request to the repository', () async {
    const request = RegistrationRequest(
      firstName: 'Ernesto',
      lastName: 'Diaz',
      email: 'ernesto@example.com',
      cuit: '20-12345678-6',
      password: 'Password1',
    );
    final repository = _RegistrationAuthRepository();
    final useCase = RegisterUserUseCase(repository);

    final result = await useCase(request: request);

    expect(repository.receivedRequest, request);
    switch (result) {
      case Success(:final data):
        expect(data.email, request.email);
      case Failure(:final error):
        fail(error.message);
    }
  });
}

class _RegistrationAuthRepository implements AuthRepository {
  RegistrationRequest? receivedRequest;

  @override
  Future<Result<AppUser>> register({
    required RegistrationRequest request,
  }) async {
    receivedRequest = request;
    return Result.success(
      AppUser(
        id: 'user-id',
        email: request.email,
        firstName: request.firstName,
        lastName: request.lastName,
        cuit: request.cuit,
      ),
    );
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

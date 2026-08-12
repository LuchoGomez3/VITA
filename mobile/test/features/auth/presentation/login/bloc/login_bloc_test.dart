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

void main() {
  test('keeps the reusable preparation summary after a successful login', () async {
    final repository = _LoginAuthRepository(
      signInResult: Result.success(_session),
    );
    final bloc =
        LoginBloc(
          signInUseCase: SignInUseCase(repository),
          preparePostAuthentication: (userId) async {
            expect(userId, _session.user.id);
            return const Result.success(
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
    expect(bloc.initialDataSyncSummary?.hasEstablishments, isTrue);
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
          preparePostAuthentication: (_) async => const Result.failure(syncError),
        )..add(
          const LoginSubmitted(
            email: 'ernesto@example.com',
            password: 'Password1',
          ),
        );
    await _waitForLogin(bloc);

    expect(bloc.state.signInResult, ResultState<AuthSession>.data(_session));
    expect(bloc.state.initialDataSyncError, syncError);
    expect(bloc.initialDataSyncSummary, isNull);
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
  _LoginAuthRepository({required this.signInResult});

  final Result<AuthSession> signInResult;
  String? receivedEmail;

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) async {
    receivedEmail = email;
    return signInResult;
  }

  @override
  Future<Result<AppUser>> register({required RegistrationRequest request}) => throw UnimplementedError();

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

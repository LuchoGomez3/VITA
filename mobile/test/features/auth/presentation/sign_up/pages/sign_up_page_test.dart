import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
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
import 'package:frontend_mayoral/features/auth/presentation/sign_up/pages/sign_up_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('navigates to success without establishments after registration', (
    tester,
  ) async {
    final repository = _PageAuthRepository(
      registrationResult: const Result.success(
        AppUser(
          id: 'user-id',
          email: 'ana@example.com',
          firstName: 'Ana',
          lastName: 'Perez',
          cuit: '20123456786',
        ),
      ),
      signInResult: Result.success(_pageSession),
    );
    await _pumpPage(tester, repository);
    await _completeAndSubmitForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('ana@example.com|false'), findsOneWidget);
    expect(repository.registrationCalls, 1);
    expect(repository.signInCalls, 1);
  });

  testWidgets('forwards existing establishments to the success destination', (
    tester,
  ) async {
    final repository = _PageAuthRepository(
      registrationResult: const Result.success(
        AppUser(
          id: 'user-id',
          email: 'ana@example.com',
          firstName: 'Ana',
          lastName: 'Perez',
          cuit: '20123456786',
        ),
      ),
      signInResult: Result.success(_pageSession),
    );
    await _pumpPage(
      tester,
      repository,
      establishmentIds: const ['establishment-id'],
    );
    await _completeAndSubmitForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('ana@example.com|true'), findsOneWidget);
  });

  testWidgets('shows the offline modal when registration has no connection', (
    tester,
  ) async {
    final repository = _PageAuthRepository(
      registrationResult: const Result.failure(
        DomainException(
          message: 'No se pudo conectar con el backend.',
          code: DomainErrorCode.offline,
        ),
      ),
      signInResult: Result.success(_pageSession),
    );
    await _pumpPage(tester, repository);
    await _completeAndSubmitForm(tester);
    await tester.pumpAndSettle();

    expect(find.text(SignUpStrings.offlineModalTitle), findsOneWidget);
  });

  testWidgets('shows backend errors without leaving the form', (tester) async {
    const errorMessage = 'El email ya esta registrado.';
    final repository = _PageAuthRepository(
      registrationResult: const Result.failure(
        DomainException(
          message: errorMessage,
          code: DomainErrorCode.validation,
        ),
      ),
      signInResult: Result.success(_pageSession),
    );
    await _pumpPage(tester, repository);
    await _completeAndSubmitForm(tester);
    await tester.pump();

    expect(find.text(errorMessage), findsOneWidget);
    expect(find.byType(SignUpPage), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  _PageAuthRepository repository, {
  List<String> establishmentIds = const [],
}) async {
  late final GoRouter router;
  router = GoRouter(
    initialLocation: AppRoutes.signUpForm,
    routes: [
      GoRoute(
        path: AppRoutes.signUpForm,
        builder: (context, state) => SignUpPage(
          createBloc: () => SignUpBloc(
            registerUserUseCase: RegisterUserUseCase(repository),
            signInUseCase: SignInUseCase(repository),
            preparePostAuthentication: (_) async => Result.success(
              PostAuthenticationSummary(
                establishmentIds: establishmentIds,
              ),
            ),
          ),
          onAuthenticated: (_) {},
        ),
      ),
      GoRoute(
        path: AppRoutes.signUpSuccess,
        builder: (context, state) {
          final userData = state.extra! as AppUser;
          final hasEstablishments =
              state.uri.queryParameters['hasEstablishments'] == 'true';
          return Scaffold(
            body: Text('${userData.email}|$hasEstablishments'),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

Future<void> _completeAndSubmitForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Ana');
  await tester.enterText(fields.at(1), 'Perez');
  await tester.enterText(fields.at(2), '20-12345678-6');
  await tester.enterText(fields.at(3), 'ana@example.com');
  await tester.enterText(fields.at(4), 'Password1');
  await tester.pump();

  final registerButton = find.text(SignUpStrings.registerButton);
  await tester.ensureVisible(registerButton);
  await tester.tap(registerButton);
  await tester.pump();
}

class _PageAuthRepository implements AuthRepository {
  _PageAuthRepository({
    required this.registrationResult,
    required this.signInResult,
  });

  final Result<AppUser> registrationResult;
  final Result<AuthSession> signInResult;
  int registrationCalls = 0;
  int signInCalls = 0;

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
    return signInResult;
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

final _pageSession = AuthSession(
  user: const AppUser(
    id: 'user-id',
    email: 'ana@example.com',
    firstName: 'Ana',
    lastName: 'Perez',
    cuit: '20123456786',
  ),
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  accessTokenExpiresAt: DateTime.utc(2026, 8, 8, 15),
);

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/bloc/sign_up_cubit.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/models/sign_up_user_data.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/pages/sign_up_page.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('navigates to success only after registration succeeds', (
    tester,
  ) async {
    final repository = _PageAuthRepository(
      result: const Result.success(
        AppUser(
          id: 'user-id',
          email: 'ana@example.com',
          firstName: 'Ana',
          lastName: 'Perez',
          cuit: '20123456786',
        ),
      ),
    );
    await _pumpPage(tester, repository);
    await _completeAndSubmitForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('ana@example.com'), findsOneWidget);
    expect(repository.registrationCalls, 1);
  });

  testWidgets('shows the offline modal when registration has no connection', (
    tester,
  ) async {
    final repository = _PageAuthRepository(
      result: const Result.failure(
        DomainException(
          message: 'No se pudo conectar con el backend.',
          code: DomainErrorCode.offline,
        ),
      ),
    );
    await _pumpPage(tester, repository);
    await _completeAndSubmitForm(tester);
    await tester.pumpAndSettle();

    expect(find.text(SignUpStrings.offlineModalTitle), findsOneWidget);
  });

  testWidgets('shows backend errors without leaving the form', (tester) async {
    const errorMessage = 'El email ya esta registrado.';
    final repository = _PageAuthRepository(
      result: const Result.failure(
        DomainException(
          message: errorMessage,
          code: DomainErrorCode.validation,
        ),
      ),
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
  _PageAuthRepository repository,
) async {
  late final GoRouter router;
  router = GoRouter(
    initialLocation: AppRoutes.signUpForm,
    routes: [
      GoRoute(
        path: AppRoutes.signUpForm,
        builder: (context, state) => SignUpPage(
          createCubit: () => SignUpCubit(
            registerUserUseCase: RegisterUserUseCase(repository),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUpSuccess,
        builder: (context, state) {
          final userData = state.extra! as SignUpUserData;
          return Scaffold(body: Text(userData.email));
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
  _PageAuthRepository({required this.result});

  final Result<AppUser> result;
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

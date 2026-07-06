import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/app.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/restore_session_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/bloc/auth_session_cubit.dart';

void main() {
  testWidgets('renders auth restore shell on startup', (WidgetTester tester) async {
    final repository = _PendingRestoreAuthRepository();

    await tester.pumpWidget(
      FrontendMayoralApp(
        createAuthSessionCubit: () => AuthSessionCubit(
          restoreSessionUseCase: RestoreSessionUseCase(repository),
          signOutUseCase: SignOutUseCase(repository),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

class _PendingRestoreAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthSession>> restoreSession() {
    return Completer<Result<AuthSession>>().future;
  }

  @override
  Future<Result<AuthSession>> getCurrentSession() {
    return restoreSession();
  }

  @override
  Future<Result<AppUser>> getCurrentUser() {
    return Future.value(
      const Result.failure(
        DomainException(message: 'No hay una sesion en el test.'),
      ),
    );
  }

  @override
  Future<Result<AuthSession>> signIn({
    required String email,
    required String password,
  }) {
    return Future.value(
      const Result.failure(
        DomainException(message: 'Login no usado en este test.'),
      ),
    );
  }

  @override
  Future<void> signOut() async {}
}

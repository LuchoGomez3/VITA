import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';

void main() {
  group('AppRouter.redirectFor', () {
    test('keeps checking state on the technical startup route', () {
      expect(
        AppRouter.redirectFor(
          authState: const AuthSessionState.checking(),
          location: AppRoutes.authCheck,
        ),
        isNull,
      );
    });

    test('moves checking state from any route to auth check', () {
      expect(
        AppRouter.redirectFor(
          authState: const AuthSessionState.checking(),
          location: AppRoutes.home,
        ),
        AppRoutes.authCheck,
      );
    });

    test('blocks private routes without a session', () {
      expect(
        AppRouter.redirectFor(
          authState: const AuthSessionState.unauthenticated(),
          location: AppRoutes.livestock,
        ),
        AppRoutes.signUp,
      );
    });

    test('allows public auth routes without a session', () {
      expect(
        AppRouter.redirectFor(
          authState: const AuthSessionState.unauthenticated(),
          location: AppRoutes.login,
        ),
        isNull,
      );
    });

    test('keeps authenticated users out of login and registration', () {
      for (final location in [
        AppRoutes.authCheck,
        AppRoutes.login,
        AppRoutes.signUp,
        AppRoutes.signUpForm,
      ]) {
        expect(
          AppRouter.redirectFor(
            authState: AuthSessionState.authenticated(_session),
            location: location,
          ),
          AppRoutes.home,
        );
      }
    });

    test('allows private routes with a restored session', () {
      expect(
        AppRouter.redirectFor(
          authState: AuthSessionState.authenticated(_session),
          location: AppRoutes.livestock,
        ),
        isNull,
      );
    });

    test('allows signup success only with its navigation data', () {
      expect(
        AppRouter.redirectFor(
          authState: const AuthSessionState.unauthenticated(),
          location: AppRoutes.signUpSuccess,
          hasSignUpSuccessData: true,
        ),
        isNull,
      );
      expect(
        AppRouter.redirectFor(
          authState: AuthSessionState.authenticated(_session),
          location: AppRoutes.signUpSuccess,
        ),
        AppRoutes.home,
      );
    });
  });
}

final _session = AuthSession(
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

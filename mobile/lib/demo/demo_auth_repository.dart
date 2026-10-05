import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/demo/demo_bootstrap.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/auth_repository.dart';

/// Sesión sintética que evita por completo Supabase durante la presentación.
class DemoAuthRepository implements AuthRepository {
  const DemoAuthRepository();

  /// Credenciales visibles usadas en la presentación.
  static const demoEmail = 'epetrich9@gmail.com';
  static const demoPassword = 'test1234';

  static AuthSession? _currentSession;

  static AuthSession _sessionFor(AppUser user) => AuthSession(
    user: user,
    accessToken: 'demo-local-session',
    refreshToken: 'demo-local-refresh',
    accessTokenExpiresAt: DateTime.utc(2030),
  );

  static Result<AuthSession> _missingSession() => const Result.failure(
    DomainException(
      message: 'Iniciá sesión para continuar.',
      code: DomainErrorCode.unauthorized,
    ),
  );

  @override
  Future<Result<AuthSession>> getCurrentSession() async =>
      _currentSession == null ? _missingSession() : Result.success(_currentSession!);

  @override
  Future<Result<AppUser>> getCurrentUser() async {
    final session = _currentSession;
    if (session == null) {
      return const Result.failure(
        DomainException(
          message: 'Iniciá sesión para continuar.',
          code: DomainErrorCode.unauthorized,
        ),
      );
    }
    return Result.success(session.user);
  }

  @override
  Future<Result<AuthSession>> refreshSession() => getCurrentSession();

  @override
  Future<Result<AuthSession>> register({required RegistrationRequest request}) async {
    final session = _sessionFor(
      AppUser(
        id: DemoIds.user,
        email: request.email.trim(),
        firstName: request.firstName.trim(),
        lastName: request.lastName.trim(),
        cuit: request.cuit.trim(),
      ),
    );
    _currentSession = session;
    return Result.success(session);
  }

  @override
  Future<Result<AuthSession>> restoreSession() => getCurrentSession();

  @override
  Future<Result<AuthSession>> signIn({required String email, required String password}) async {
    if (email.trim().toLowerCase() != demoEmail || password != demoPassword) {
      return const Result.failure(
        DomainException(
          message: 'Correo o contraseña incorrectos.',
          code: DomainErrorCode.unauthorized,
        ),
      );
    }
    final session = _sessionFor(
      const AppUser(
        id: DemoIds.user,
        email: demoEmail,
        firstName: 'Ernesto',
        lastName: 'Petrich',
        cuit: '20-00000000-0',
      ),
    );
    _currentSession = session;
    return Result.success(session);
  }

  @override
  Future<void> signOut() async => _currentSession = null;
}

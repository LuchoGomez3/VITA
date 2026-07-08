import 'package:frontend_mayoral/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend_mayoral/features/auth/data/session_manager.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/cubit/auth_cubit.dart';

/// Composition root de auth: arma el AuthCubit con sus dependencias.
///
/// El repositorio se apoya en el [SessionManager] compartido (misma sesión que
/// usan el guard del router y el sync de Brick), así que el login que ocurre
/// acá queda inmediatamente disponible para todo el resto de la app.
AuthCubit createAuthCubit(SessionManager sessionManager) {
  final repository = AuthRepositoryImpl(sessionManager: sessionManager);
  return AuthCubit(signInUseCase: SignInUseCase(repository));
}

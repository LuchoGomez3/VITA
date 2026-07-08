import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';

/// Estado del flujo de login.
enum AuthStatus {
  /// Sin intento en curso.
  idle,

  /// Login en progreso (valida contra el backend).
  submitting,

  /// Login exitoso.
  success,

  /// Login fallido (credenciales o sin conexión).
  failure,
}

/// Estado inmutable del [AuthCubit] para la pantalla de login.
class AuthState {
  const AuthState({
    this.status = AuthStatus.idle,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  bool get isSubmitting => status == AuthStatus.submitting;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

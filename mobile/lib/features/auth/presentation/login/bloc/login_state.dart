part of 'login_bloc.dart';

/// Estado de la pantalla de login.
///
/// Contiene el resultado de dos operaciones relacionadas pero no identicas:
/// - [signInResult], que determina si las credenciales autenticaron o no.
/// - [initialDataSyncError], que puede fallar aunque el login haya sido exitoso.
/// [postAuthenticationSummary] expone el alcance cuando esa preparacion termina.
///
/// Esa separacion permite ingresar a la app con sesion valida y avisar que la
/// preparacion offline no pudo completarse.
@freezed
sealed class LoginState with _$LoginState {
  /// Crea el estado de login.
  const factory LoginState({
    /// Resultado principal del intento de login.
    required ResultState<AuthSession> signInResult,

    /// Indica que el login ya fue aceptado y se estan preparando datos locales.
    required bool isPreparingOfflineData,

    /// Error no bloqueante de la sync inicial posterior al login.
    DomainException? initialDataSyncError,

    /// Resumen disponible cuando la preparacion posterior fue exitosa.
    PostAuthenticationSummary? postAuthenticationSummary,
  }) = _LoginState;

  /// Estado inicial del formulario.
  factory LoginState.initial() {
    return const LoginState(
      signInResult: ResultState<AuthSession>.initial(),
      isPreparingOfflineData: false,
    );
  }
}

part of 'login_cubit.dart';

/// Estado de la pantalla de login.
@freezed
sealed class LoginState with _$LoginState {
  /// Crea el estado de login.
  const factory LoginState({
    required ResultState<AuthSession> signInResult,
    required bool isPreparingOfflineData,
    DomainException? initialDataSyncError,
  }) = _LoginState;

  /// Estado inicial del formulario.
  factory LoginState.initial() {
    return const LoginState(
      signInResult: ResultState<AuthSession>.initial(),
      isPreparingOfflineData: false,
    );
  }
}

part of 'auth_session_cubit.dart';

/// Estado global de autenticacion.
@freezed
abstract class AuthSessionState with _$AuthSessionState {
  /// La app esta leyendo secure storage para decidir el destino inicial.
  const factory AuthSessionState.checking() = AuthSessionChecking;

  /// Hay una sesion local disponible para operar online u offline.
  const factory AuthSessionState.authenticated(AuthSession session) = AuthSessionAuthenticated;

  /// No hay sesion local utilizable; el usuario debe iniciar sesion con red.
  const factory AuthSessionState.unauthenticated() = AuthSessionUnauthenticated;
}

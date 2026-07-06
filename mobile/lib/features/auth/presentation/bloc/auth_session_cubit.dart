import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/restore_session_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_out_use_case.dart';

part 'auth_session_cubit.freezed.dart';
part 'auth_session_state.dart';

/// Cubit global de sesion autenticada.
///
/// Su responsabilidad es pequena pero central: decidir si la app esta
/// restaurando sesion, autenticada o sin sesion. No hace llamadas de UI ni sabe
/// de rutas; solo coordina casos de uso de auth y expone estado para que el
/// router pueda reaccionar.
class AuthSessionCubit extends Cubit<AuthSessionState> {
  /// Crea el cubit con los casos de uso necesarios para la sesion global.
  AuthSessionCubit({
    required RestoreSessionUseCase restoreSessionUseCase,
    required SignOutUseCase signOutUseCase,
    void Function()? onClose,
  }) : _restoreSessionUseCase = restoreSessionUseCase,
       _signOutUseCase = signOutUseCase,
       _onClose = onClose,
       super(const AuthSessionState.checking());

  final RestoreSessionUseCase _restoreSessionUseCase;
  final SignOutUseCase _signOutUseCase;
  final void Function()? _onClose;

  /// Restaura la sesion guardada durante el arranque de la app.
  Future<void> restoreSession() async {
    emit(const AuthSessionState.checking());

    final result = await _restoreSessionUseCase();
    switch (result) {
      case Success<AuthSession>(:final data):
        emit(AuthSessionState.authenticated(data));
      case Failure<AuthSession>():
        emit(const AuthSessionState.unauthenticated());
    }
  }

  /// Actualiza el estado global luego de un login exitoso.
  ///
  /// El repositorio ya persistio la sesion y alimento el token provider de
  /// Brick. Aca solo reflejamos el nuevo estado para la UI/router.
  void setAuthenticated(AuthSession session) {
    emit(AuthSessionState.authenticated(session));
  }

  /// Cierra la sesion local y deja a Brick sin token en memoria.
  Future<void> signOut() async {
    await _signOutUseCase();
    emit(const AuthSessionState.unauthenticated());
  }

  @override
  Future<void> close() async {
    _onClose?.call();
    return super.close();
  }
}

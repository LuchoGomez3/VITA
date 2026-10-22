import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
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
/// de rutas; coordina casos de uso y dispara una actualizacion no bloqueante
/// despues de restaurar para reconciliar la cache con otros dispositivos.
class AuthSessionCubit extends Cubit<AuthSessionState> {
  /// Crea el cubit con los casos de uso necesarios para la sesion global.
  AuthSessionCubit({
    required RestoreSessionUseCase restoreSessionUseCase,
    required SignOutUseCase signOutUseCase,
    PreparePostAuthentication? refreshOfflineData,
    Iterable<Stream<void>> authRejections = const [],
    void Function()? onClose,
  }) : _restoreSessionUseCase = restoreSessionUseCase,
       _signOutUseCase = signOutUseCase,
       _refreshOfflineData = refreshOfflineData,
       _onClose = onClose,
       super(const AuthSessionState.checking()) {
    for (final source in authRejections) {
      _authRejectionSubscriptions.add(source.listen((_) => unawaited(_invalidateSession())));
    }
  }

  final RestoreSessionUseCase _restoreSessionUseCase;
  final SignOutUseCase _signOutUseCase;
  final PreparePostAuthentication? _refreshOfflineData;
  final void Function()? _onClose;
  final List<StreamSubscription<void>> _authRejectionSubscriptions = [];
  bool _isSigningOut = false;

  /// Restaura la sesion guardada durante el arranque de la app.
  Future<void> restoreSession() async {
    emit(const AuthSessionState.checking());

    final result = await _restoreSessionUseCase();
    switch (result) {
      case Success<AuthSession>(:final data):
        emit(AuthSessionState.authenticated(data));
        final refreshOfflineData = _refreshOfflineData;
        if (refreshOfflineData != null) unawaited(refreshOfflineData());
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
    await _invalidateSession();
  }

  Future<void> _invalidateSession() async {
    if (_isSigningOut || state is AuthSessionUnauthenticated) {
      return;
    }

    _isSigningOut = true;
    try {
      await _signOutUseCase();
      emit(const AuthSessionState.unauthenticated());
    } finally {
      _isSigningOut = false;
    }
  }

  @override
  Future<void> close() async {
    await Future.wait(_authRejectionSubscriptions.map((subscription) => subscription.cancel()));
    _onClose?.call();
    return super.close();
  }
}

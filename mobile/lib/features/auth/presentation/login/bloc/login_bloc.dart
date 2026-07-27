import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/sync/domain/use_cases/prepare_initial_data_sync_use_case.dart';

part 'login_bloc.freezed.dart';
part 'login_state.dart';

/// Bloc que coordina el inicio de sesion mobile.
///
/// Su responsabilidad empieza con credenciales ya validadas por el formulario y
/// termina emitiendo una [AuthSession] o un error de dominio. No conoce rutas ni
/// widgets: la page escucha el estado exitoso para actualizar
/// AuthSessionCubit y navegar.
///
/// A diferencia del registro, login si prepara la experiencia offline-first:
/// despues de autenticar, ejecuta [PrepareInitialDataSyncUseCase]. Si esa sync
/// falla, el login no se revierte; el error queda en [LoginState] para que la UI
/// lo informe sin bloquear el ingreso.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  /// Crea el bloc con sus casos de uso de autenticacion.
  LoginBloc({
    required SignInUseCase signInUseCase,
    required PrepareInitialDataSyncUseCase prepareInitialDataSyncUseCase,
    void Function()? onClose,
  }) : _signInUseCase = signInUseCase,
       _prepareInitialDataSyncUseCase = prepareInitialDataSyncUseCase,
       _onClose = onClose,
       super(LoginState.initial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final SignInUseCase _signInUseCase;
  final PrepareInitialDataSyncUseCase _prepareInitialDataSyncUseCase;
  final void Function()? _onClose;

  /// Maneja el submit del formulario de login.
  ///
  /// Orden del flujo:
  /// 1. autenticar contra backend;
  /// 2. dejar que el repositorio persista sesion e hidrate el token de Brick;
  /// 3. descargar datos iniciales para operar offline;
  /// 4. emitir la sesion aunque la sync inicial haya fallado.
  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        signInResult: const ResultState<AuthSession>.loading(),
        isPreparingOfflineData: false,
        initialDataSyncError: null,
      ),
    );

    final result = await _signInUseCase(
      email: event.email.trim(),
      password: event.password,
    );

    switch (result) {
      case Success<AuthSession>(:final data):
        emit(
          state.copyWith(
            isPreparingOfflineData: true,
          ),
        );

        // La sync inicial usa el token que AuthRepositoryImpl acaba de hidratar
        // en SessionBackendAccessTokenProvider durante el signIn exitoso.
        final syncResult = await _prepareInitialDataSyncUseCase(data.user.id);
        final syncError = switch (syncResult) {
          Failure<void>(:final error) => error,
          Success<void>() => null,
          _ => null,
        };

        emit(
          state.copyWith(
            signInResult: ResultState<AuthSession>.data(data),
            isPreparingOfflineData: false,
            initialDataSyncError: syncError,
          ),
        );
      case Failure<AuthSession>(:final error):
        emit(
          state.copyWith(
            signInResult: ResultState<AuthSession>.error(error),
            isPreparingOfflineData: false,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    _onClose?.call();
    return super.close();
  }
}

/// Evento del flujo de inicio de sesion.
sealed class LoginEvent {
  /// Crea un evento base de login.
  const LoginEvent();
}

/// Solicita iniciar sesion con credenciales validadas por el formulario.
final class LoginSubmitted extends LoginEvent {
  /// Crea el evento de envio del login.
  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  /// Email ingresado por el usuario.
  final String email;

  /// Password ingresada por el usuario.
  final String password;
}

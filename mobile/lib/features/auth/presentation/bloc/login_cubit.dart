import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

/// Cubit que coordina el inicio de sesion mobile.
class LoginCubit extends Cubit<LoginState> {
  /// Crea el cubit con sus casos de uso de autenticacion.
  LoginCubit({
    required SignInUseCase signInUseCase,
    void Function()? onClose,
  }) : _signInUseCase = signInUseCase,
       _onClose = onClose,
       super(LoginState.initial());

  final SignInUseCase _signInUseCase;
  final void Function()? _onClose;

  /// Intenta iniciar sesion con las credenciales del formulario.
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    emit(
      state.copyWith(
        signInResult: const ResultState<AuthSession>.loading(),
      ),
    );

    final result = await _signInUseCase(
      username: username.trim(),
      password: password,
    );

    switch (result) {
      case Success<AuthSession>(:final data):
        emit(
          state.copyWith(
            signInResult: ResultState<AuthSession>.data(data),
          ),
        );
      case Failure<AuthSession>(:final error):
        emit(
          state.copyWith(
            signInResult: ResultState<AuthSession>.error(error),
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

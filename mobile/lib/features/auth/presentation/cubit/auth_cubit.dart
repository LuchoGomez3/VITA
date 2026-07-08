import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/cubit/auth_state.dart';

/// Maneja el estado de la pantalla de login.
///
/// La navegación post-login la resuelve el guard del router (que escucha al
/// SessionManager), así que este cubit solo expone el progreso del intento y el
/// mensaje de error para la UI.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required SignInUseCase signInUseCase})
    : _signInUseCase = signInUseCase,
      super(const AuthState());

  final SignInUseCase _signInUseCase;

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.submitting));

    final result = await _signInUseCase.call(
      username: username,
      password: password,
    );

    switch (result) {
      case Success<AppUser>(:final data):
        emit(state.copyWith(status: AuthStatus.success, user: data));
      case Failure<AppUser>(:final error):
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage: error.message,
          ),
        );
    }
  }
}

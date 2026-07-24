import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/bloc/sign_up_state.dart';

/// Cubit que coordina el alta remota de una cuenta.
class SignUpCubit extends Cubit<SignUpState> {
  /// Crea el cubit con el caso de uso de registro.
  SignUpCubit({
    required RegisterUserUseCase registerUserUseCase,
    void Function()? onClose,
  }) : _registerUserUseCase = registerUserUseCase,
       _onClose = onClose,
       super(const ResultState<void>.initial());

  final RegisterUserUseCase _registerUserUseCase;
  final void Function()? _onClose;

  /// Intenta registrar una cuenta con los datos validados por el formulario.
  Future<void> register({
    required RegistrationRequest request,
  }) async {
    if (state is Loading<void>) {
      return;
    }

    emit(const ResultState<void>.loading());

    final result = await _registerUserUseCase(request: request);
    switch (result) {
      case Success<AppUser>():
        emit(const ResultState<void>.data(null));
      case Failure<AppUser>(:final error):
        emit(ResultState<void>.error(error));
    }
  }

  @override
  Future<void> close() async {
    _onClose?.call();
    return super.close();
  }
}

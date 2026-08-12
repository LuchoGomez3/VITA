import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_event.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_state.dart';

/// Bloc que coordina registro, auto-login y preparacion offline inicial.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  /// Crea el bloc con las operaciones del flujo post-registro.
  SignUpBloc({
    required RegisterUserUseCase registerUserUseCase,
    required SignInUseCase signInUseCase,
    required PreparePostAuthentication preparePostAuthentication,
    void Function()? onClose,
  }) : _registerUserUseCase = registerUserUseCase,
       _signInUseCase = signInUseCase,
       _preparePostAuthentication = preparePostAuthentication,
       _onClose = onClose,
       super(const SignUpState.initial()) {
    on<SignUpSubmitted>(
      _onSubmitted,
      transformer: _droppable(),
    );
  }

  final RegisterUserUseCase _registerUserUseCase;
  final SignInUseCase _signInUseCase;
  final PreparePostAuthentication _preparePostAuthentication;
  final void Function()? _onClose;

  /// Crea la cuenta, inicia sesion y prepara el dispositivo para uso offline.
  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(const SignUpState(stage: SignUpStage.registering));

    final registrationResult = await _registerUserUseCase(
      request: event.request,
    );
    switch (registrationResult) {
      case Success<AppUser>():
        emit(
          const SignUpState(
            stage: SignUpStage.signingIn,
            accountCreated: true,
          ),
        );
      case Failure<AppUser>(:final error):
        emit(SignUpState(stage: SignUpStage.failure, error: error));
        return;
      default:
        return;
    }

    final signInResult = await _signInUseCase(
      email: event.request.email.trim(),
      password: event.request.password,
    );
    final session = switch (signInResult) {
      Success<AuthSession>(:final data) => data,
      Failure<AuthSession>(:final error) => _emitSignInFailure(emit, error),
      _ => null,
    };
    if (session == null) {
      return;
    }

    emit(
      SignUpState(
        stage: SignUpStage.preparingOfflineData,
        session: session,
        accountCreated: true,
      ),
    );
    final preparationResult = await _preparePostAuthentication(
      session.user.id,
    );
    switch (preparationResult) {
      case Success<PostAuthenticationSummary>(:final data):
        emit(
          SignUpState(
            stage: SignUpStage.success,
            session: session,
            preparationSummary: data,
            accountCreated: true,
          ),
        );
      case Failure<PostAuthenticationSummary>(:final error):
        // La cuenta y la sesion ya son validas. La descarga puede reintentarse
        // sin obligar al productor a autenticarse nuevamente.
        emit(
          SignUpState(
            stage: SignUpStage.success,
            session: session,
            preparationError: error,
            accountCreated: true,
          ),
        );
      default:
        break;
    }
  }

  AuthSession? _emitSignInFailure(
    Emitter<SignUpState> emit,
    DomainException error,
  ) {
    emit(
      SignUpState(
        stage: SignUpStage.failure,
        error: error,
        accountCreated: true,
      ),
    );
    return null;
  }

  @override
  Future<void> close() async {
    _onClose?.call();
    return super.close();
  }
}

/// Event transformer local para ignorar submits repetidos mientras uno corre.
///
/// Evita dos POST de registro si el usuario toca dos veces el boton antes de que
/// responda el backend. Se mantiene local para no agregar una dependencia de
/// `bloc_concurrency` solo por este caso.
EventTransformer<Event> _droppable<Event>() {
  return (events, mapper) {
    var isRunning = false;
    var isEventStreamDone = false;
    StreamSubscription<Event>? eventSubscription;
    StreamSubscription<Event>? mapperSubscription;

    late final StreamController<Event> controller;

    void closeWhenDone() {
      if (isEventStreamDone && !isRunning && !controller.isClosed) {
        unawaited(controller.close());
      }
    }

    controller = StreamController<Event>(
      onListen: () {
        eventSubscription = events.listen(
          (event) {
            if (isRunning) {
              return;
            }

            isRunning = true;
            mapperSubscription = mapper(event).listen(
              controller.add,
              onError: controller.addError,
              onDone: () {
                isRunning = false;
                closeWhenDone();
              },
            );
          },
          onError: controller.addError,
          onDone: () {
            isEventStreamDone = true;
            closeWhenDone();
          },
        );
      },
      onCancel: () async {
        await eventSubscription?.cancel();
        await mapperSubscription?.cancel();
      },
    );

    return controller.stream;
  };
}

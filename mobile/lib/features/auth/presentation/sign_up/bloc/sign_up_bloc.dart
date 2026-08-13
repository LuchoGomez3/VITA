import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_event.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_state.dart';

/// Bloc que coordina el registro y el inicio de sesion automatico.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  /// Crea el bloc con las operaciones del flujo post-registro.
  SignUpBloc({
    required RegisterUserUseCase registerUserUseCase,
    void Function()? onClose,
  }) : _registerUserUseCase = registerUserUseCase,
       _onClose = onClose,
       super(const SignUpState.initial()) {
    on<SignUpSubmitted>(
      _onSubmitted,
      transformer: _droppable(),
    );
  }

  final RegisterUserUseCase _registerUserUseCase;
  final void Function()? _onClose;

  /// Crea la cuenta e inicia una sesion persistida automaticamente.
  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(const SignUpState(stage: SignUpStage.registering));

    final result = await _registerUserUseCase(
      request: event.request,
    );
    switch (result) {
      case Success<AuthSession>(:final data):
        emit(
          SignUpState(
            stage: SignUpStage.success,
            session: data,
            accountCreated: true,
          ),
        );
      case Failure<AuthSession>(:final error):
        emit(SignUpState(stage: SignUpStage.failure, error: error));
      default:
        break;
    }
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

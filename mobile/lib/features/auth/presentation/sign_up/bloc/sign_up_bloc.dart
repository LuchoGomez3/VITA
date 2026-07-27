import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/use_cases/register_user_use_case.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_event.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_state.dart';

/// Bloc que coordina el alta online de una cuenta.
///
/// El registro es online-only y no inicia sesion por si mismo. En el contrato
/// actual crea la cuenta en backend y emite el [AppUser] confirmado para la
/// pantalla de exito. Login queda como el unico flujo que persiste sesion,
/// hidrata el token provider de Brick y ejecuta sync inicial.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  /// Crea el bloc con el caso de uso de registro.
  SignUpBloc({
    required RegisterUserUseCase registerUserUseCase,
    void Function()? onClose,
  }) : _registerUserUseCase = registerUserUseCase,
       _onClose = onClose,
       super(const ResultState<AppUser>.initial()) {
    on<SignUpSubmitted>(
      _onSubmitted,
      transformer: _droppable(),
    );
  }

  final RegisterUserUseCase _registerUserUseCase;
  final void Function()? _onClose;

  /// Ejecuta el registro remoto y transforma el resultado de dominio en estado.
  ///
  /// El resultado exitoso transporta [AppUser] para que la UI muestre datos
  /// confirmados por backend en lugar de reconstruirlos desde controllers.
  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(const ResultState<AppUser>.loading());

    final result = await _registerUserUseCase(request: event.request);
    switch (result) {
      case Success<AppUser>(:final data):
        emit(ResultState<AppUser>.data(data));
      case Failure<AppUser>(:final error):
        emit(ResultState<AppUser>.error(error));
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

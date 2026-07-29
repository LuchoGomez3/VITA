import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';

part 'register_establishment_bloc.freezed.dart';
part 'register_establishment_event.dart';
part 'register_establishment_state.dart';

/// Coordina el wizard de registro de establecimiento.
///
/// Este BLoC solo maneja estado de presentacion: el paso visual actual, el
/// borrador que se va completando y el resultado que la UI debe mostrar.
class RegisterEstablishmentBloc extends Bloc<RegisterEstablishmentEvent, RegisterEstablishmentState> {
  /// Crea el BLoC de registro en el paso inicial solicitado.
  RegisterEstablishmentBloc({
    required RegisterEstablishmentUseCase registerEstablishmentUseCase,
    RegisterEstablishmentStep initialStep = RegisterEstablishmentStep.identification,
  }) : _registerEstablishmentUseCase = registerEstablishmentUseCase,
       super(
         RegisterEstablishmentState(
           currentStep: initialStep,
           draft: RegisterEstablishmentDraft.initial(),
         ),
       ) {
    on<_DraftChanged>(_onDraftChanged);
    on<_NextStepRequested>(_onNextStepRequested);
    on<_PreviousStepRequested>(_onPreviousStepRequested);
    on<_StepRequested>(_onStepRequested);
    on<_SubmitRequested>(_onSubmitRequested);
  }

  final RegisterEstablishmentUseCase _registerEstablishmentUseCase;

  /// Reemplaza el borrador completo cuando un campo del formulario cambia.
  void _onDraftChanged(
    _DraftChanged event,
    Emitter<RegisterEstablishmentState> emit,
  ) {
    emit(state.copyWith(draft: event.draft));
  }

  /// Avanza el wizard un paso, sin pasar de la pantalla de revision.
  void _onNextStepRequested(
    _NextStepRequested event,
    Emitter<RegisterEstablishmentState> emit,
  ) {
    if (state.currentStep == RegisterEstablishmentStep.review) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: RegisterEstablishmentStep.values[state.currentStep.index + 1],
      ),
    );
  }

  /// Retrocede el wizard un paso, sin volver antes de identificacion.
  void _onPreviousStepRequested(
    _PreviousStepRequested event,
    Emitter<RegisterEstablishmentState> emit,
  ) {
    if (state.currentStep == RegisterEstablishmentStep.identification) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: RegisterEstablishmentStep.values[state.currentStep.index - 1],
      ),
    );
  }

  /// Salta a un paso especifico cuando la UI pide navegacion directa.
  void _onStepRequested(
    _StepRequested event,
    Emitter<RegisterEstablishmentState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }

  /// Construye el request de dominio a partir del draft y lo envia.
  ///
  // TODO(lucho): Etapa 2 agrega validacion real antes de armar el request
  // (ver .claude/specs/registrar-establecimiento.md). Por ahora el draft
  // siempre se considera valido.
  Future<void> _onSubmitRequested(
    _SubmitRequested event,
    Emitter<RegisterEstablishmentState> emit,
  ) async {
    if (state.submitResult is Loading<RegisteredEstablishment>) {
      return;
    }

    emit(state.copyWith(submitResult: const ResultState.loading()));

    final result = await _registerEstablishmentUseCase(_buildRegistration());

    switch (result) {
      case Success<RegisteredEstablishment>(:final data):
        emit(state.copyWith(submitResult: ResultState.data(data)));
      case Failure<RegisteredEstablishment>(:final error):
        emit(state.copyWith(submitResult: ResultState.error(error)));
    }
  }

  EstablishmentRegistration _buildRegistration() {
    final draft = state.draft;
    return EstablishmentRegistration(
      nombre: draft.nombre,
      descripcion: draft.descripcion,
      tiposProduccion: draft.tiposProduccion.toList(),
      cuitTitular: draft.cuitTitular,
      nroRenspa: draft.nroRenspa,
      provincia: draft.provincia,
      departamento: draft.departamento,
      localidad: draft.localidad,
      latitud: draft.latitud,
      longitud: draft.longitud,
      superficieHectareas: draft.superficieHectareas,
      cantidadVertices: draft.cantidadVertices,
    );
  }
}

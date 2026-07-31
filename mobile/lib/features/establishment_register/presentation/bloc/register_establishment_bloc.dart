import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/use_cases/register_establishment_use_case.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_draft_validation.dart';

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
    void Function()? onClose,
  }) : _registerEstablishmentUseCase = registerEstablishmentUseCase,
       _onClose = onClose,
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
  final void Function()? _onClose;

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

  /// Valida el borrador, construye el request de dominio y lo envia.
  ///
  /// La UI ya deshabilita "Crear establecimiento" mientras algun paso es
  /// invalido; esta revalidacion es defensiva (mismo criterio que
  /// `RegisterAnimalBloc`), para no depender unicamente del estado del boton.
  Future<void> _onSubmitRequested(
    _SubmitRequested event,
    Emitter<RegisterEstablishmentState> emit,
  ) async {
    if (state.submitResult is Loading<RegisteredEstablishment>) {
      return;
    }

    final registration = _buildRegistration();
    if (registration case Failure<EstablishmentRegistration>(:final error)) {
      emit(state.copyWith(submitResult: ResultState.error(error)));
      return;
    }

    emit(state.copyWith(submitResult: const ResultState.loading()));

    final result = await _registerEstablishmentUseCase(
      (registration as Success<EstablishmentRegistration>).data,
    );

    switch (result) {
      case Success<RegisteredEstablishment>(:final data):
        emit(state.copyWith(submitResult: ResultState.data(data)));
      case Failure<RegisteredEstablishment>(:final error):
        emit(state.copyWith(submitResult: ResultState.error(error)));
    }
  }

  Result<EstablishmentRegistration> _buildRegistration() {
    final draft = state.draft;
    if (!draft.isValidForStep(RegisterEstablishmentStep.review)) {
      return const Result.failure(
        DomainException(
          message: 'Revisá los datos cargados: hay pasos incompletos.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    return Result.success(
      EstablishmentRegistration(
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
      ),
    );
  }

  @override
  Future<void> close() async {
    _onClose?.call();
    return super.close();
  }
}

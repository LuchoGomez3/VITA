part of 'register_establishment_bloc.dart';

/// Eventos aceptados por [RegisterEstablishmentBloc].
@freezed
sealed class RegisterEstablishmentEvent with _$RegisterEstablishmentEvent {
  /// Reemplaza el borrador de registro actual.
  const factory RegisterEstablishmentEvent.draftChanged(
    RegisterEstablishmentDraft draft,
  ) = _DraftChanged;

  /// Avanza al siguiente paso del registro.
  const factory RegisterEstablishmentEvent.nextStepRequested() = _NextStepRequested;

  /// Vuelve al paso anterior del registro.
  const factory RegisterEstablishmentEvent.previousStepRequested() = _PreviousStepRequested;

  /// Abre un paso especifico, por ejemplo desde la pantalla de revision.
  const factory RegisterEstablishmentEvent.stepRequested(RegisterEstablishmentStep step) = _StepRequested;

  /// Envia el borrador actual para crear el establecimiento.
  const factory RegisterEstablishmentEvent.submitRequested() = _SubmitRequested;
}

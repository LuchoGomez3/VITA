part of 'register_animal_bloc.dart';

/// Events accepted by [RegisterAnimalBloc].
@freezed
sealed class RegisterAnimalEvent with _$RegisterAnimalEvent {
  /// Replaces the current registration draft.
  const factory RegisterAnimalEvent.draftChanged(
    RegisterAnimalDraft draft,
  ) = _DraftChanged;

  /// Advances to the next registration step.
  const factory RegisterAnimalEvent.nextStepRequested() = _NextStepRequested;

  /// Returns to the previous registration step.
  const factory RegisterAnimalEvent.previousStepRequested() = _PreviousStepRequested;

  /// Opens a specific step, for example from the review screen.
  const factory RegisterAnimalEvent.stepRequested(RegisterAnimalStep step) = _StepRequested;

  /// Persists the current draft locally through the offline-first flow.
  const factory RegisterAnimalEvent.submitRequested() = _SubmitRequested;
}

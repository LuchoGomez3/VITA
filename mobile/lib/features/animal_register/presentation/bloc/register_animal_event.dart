part of 'register_animal_bloc.dart';

/// Events accepted by [RegisterAnimalBloc].
@freezed
sealed class RegisterAnimalEvent with _$RegisterAnimalEvent {
  /// Recibe una caravana válida desde la pantalla de captura HID.
  const factory RegisterAnimalEvent.rfidCaptured(String rfid) = _RfidCaptured;

  /// Carga los animales locales del establecimiento para buscar progenitores.
  const factory RegisterAnimalEvent.parentsRequested() = _ParentsRequested;

  /// Carga el catalogo global de categorias desde la cache offline.
  const factory RegisterAnimalEvent.categoriesRequested() = _CategoriesRequested;

  /// Carga los establecimientos disponibles offline.
  const factory RegisterAnimalEvent.establishmentsRequested() = _EstablishmentsRequested;

  /// Selecciona el establecimiento y carga sus lotes locales.
  const factory RegisterAnimalEvent.establishmentSelected(
    String establishmentId,
  ) = _EstablishmentSelected;

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

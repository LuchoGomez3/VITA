part of 'register_animal_bloc.dart';

/// Steps in the animal registration flow.
enum RegisterAnimalStep {
  /// Electronic and visual identification.
  identification,

  /// Breed, sex, birth date, category, and initial weight.
  basicData,

  /// Parent relationships and destination lot.
  genealogy,

  /// Final registration review.
  review,
}

/// Values collected throughout animal registration.
@freezed
sealed class RegisterAnimalDraft with _$RegisterAnimalDraft {
  /// Creates an animal registration draft.
  const factory RegisterAnimalDraft({
    required String rfid,
    required String visualTagSeries,
    required String visualTagNumber,
    required int earTagColorIndex,
    required String breed,
    required String sex,
    required DateTime birthDate,
    required String category,
    required String birthWeight,
    String? motherId,
    String? fatherId,
    String? destinationId,
  }) = _RegisterAnimalDraft;

  /// Creates the initial values currently displayed by the flow.
  factory RegisterAnimalDraft.initial() => RegisterAnimalDraft(
    rfid: '',
    visualTagSeries: '',
    visualTagNumber: '',
    earTagColorIndex: 0,
    breed: AnimalRegisterStrings.stepTwoBreedOptions.first,
    sex: AnimalRegisterStrings.stepTwoFemale,
    birthDate: DateTime(2025, 3, 14),
    category: AnimalRegisterStrings.stepTwoCategories.first,
    birthWeight: '',
    motherId: 'mother-003-0421',
    destinationId: 'destination-la-cumbre',
  );
}

/// Immutable state of the complete registration flow.
@freezed
sealed class RegisterAnimalState with _$RegisterAnimalState {
  /// Creates the registration state.
  const factory RegisterAnimalState({
    required RegisterAnimalStep currentStep,
    required RegisterAnimalDraft draft,
    @Default(ResultState<RegisteredAnimal>.initial()) ResultState<RegisteredAnimal> submitResult,
  }) = _RegisterAnimalState;
}

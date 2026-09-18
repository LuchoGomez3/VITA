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
    required String breed,
    required String sex,
    required DateTime birthDate,
    required String birthWeight,
    String? categoryId,
    String? categoryName,
    String? establishmentId,
    String? establishmentName,
    AnimalParent? mother,
    AnimalParent? father,
    String? destinationId,
  }) = _RegisterAnimalDraft;

  /// Creates the initial values currently displayed by the flow.
  factory RegisterAnimalDraft.initial({String rfid = ''}) => RegisterAnimalDraft(
    rfid: rfid,
    visualTagSeries: '',
    visualTagNumber: '',
    breed: AnimalRegisterStrings.stepTwoBreedOptions.first,
    sex: AnimalRegisterStrings.stepTwoFemale,
    birthDate: DateTime(2025, 3, 14),
    birthWeight: '',
  );
}

/// Immutable state of the complete registration flow.
@freezed
sealed class RegisterAnimalState with _$RegisterAnimalState {
  /// Creates the registration state.
  const factory RegisterAnimalState({
    required RegisterAnimalStep currentStep,
    required RegisterAnimalDraft draft,
    @Default(ResultState<List<AnimalRegistrationEstablishment>>.initial())
    ResultState<List<AnimalRegistrationEstablishment>> establishmentsState,
    @Default(ResultState<List<AnimalRegistrationDestination>>.initial())
    ResultState<List<AnimalRegistrationDestination>> destinationsState,
    @Default(ResultState<List<AnimalCategory>>.initial()) ResultState<List<AnimalCategory>> categoriesState,
    @Default(ResultState<List<AnimalParent>>.initial()) ResultState<List<AnimalParent>> parentsState,
    @Default(ResultState<RegisteredAnimal>.initial()) ResultState<RegisteredAnimal> submitResult,
  }) = _RegisterAnimalState;

  const RegisterAnimalState._();

  /// Destinos disponibles cuando la lectura local finalizo correctamente.
  List<AnimalRegistrationDestination> get destinations => switch (destinationsState) {
    Data<List<AnimalRegistrationDestination>>(:final data) => data,
    _ => const [],
  };

  /// Establecimientos disponibles cuando finalizó la lectura local.
  List<AnimalRegistrationEstablishment> get establishments => switch (establishmentsState) {
    Data<List<AnimalRegistrationEstablishment>>(:final data) => data,
    _ => const [],
  };

  /// Categorias disponibles cuando finalizo la lectura de la cache local.
  List<AnimalCategory> get categories => switch (categoriesState) {
    Data<List<AnimalCategory>>(:final data) => data,
    _ => const [],
  };
}

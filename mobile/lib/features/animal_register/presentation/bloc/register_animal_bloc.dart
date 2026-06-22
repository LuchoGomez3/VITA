import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/animal_register/data/sources/animal_registration_mock_context.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/register_animal_use_case.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';

part 'register_animal_bloc.freezed.dart';
part 'register_animal_event.dart';
part 'register_animal_state.dart';

/// Coordinates the animal registration draft and its visual steps.
class RegisterAnimalBloc extends Bloc<RegisterAnimalEvent, RegisterAnimalState> {
  /// Creates the registration bloc at the requested step.
  RegisterAnimalBloc({
    required RegisterAnimalUseCase registerAnimalUseCase,
    required AnimalRegistrationMockContext mockContext,
    RegisterAnimalStep initialStep = RegisterAnimalStep.identification,
  }) : _registerAnimalUseCase = registerAnimalUseCase,
       _mockContext = mockContext,
       super(
         RegisterAnimalState(
           currentStep: initialStep,
           draft: RegisterAnimalDraft.initial(),
         ),
       ) {
    on<_DraftChanged>(_onDraftChanged);
    on<_NextStepRequested>(_onNextStepRequested);
    on<_PreviousStepRequested>(_onPreviousStepRequested);
    on<_StepRequested>(_onStepRequested);
    on<_SubmitRequested>(_onSubmitRequested);
  }

  final RegisterAnimalUseCase _registerAnimalUseCase;
  final AnimalRegistrationMockContext _mockContext;

  void _onDraftChanged(
    _DraftChanged event,
    Emitter<RegisterAnimalState> emit,
  ) {
    emit(state.copyWith(draft: event.draft));
  }

  void _onNextStepRequested(
    _NextStepRequested event,
    Emitter<RegisterAnimalState> emit,
  ) {
    if (state.currentStep == RegisterAnimalStep.review) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: RegisterAnimalStep.values[state.currentStep.index + 1],
      ),
    );
  }

  void _onPreviousStepRequested(
    _PreviousStepRequested event,
    Emitter<RegisterAnimalState> emit,
  ) {
    if (state.currentStep == RegisterAnimalStep.identification) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: RegisterAnimalStep.values[state.currentStep.index - 1],
      ),
    );
  }

  void _onStepRequested(
    _StepRequested event,
    Emitter<RegisterAnimalState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }

  Future<void> _onSubmitRequested(
    _SubmitRequested event,
    Emitter<RegisterAnimalState> emit,
  ) async {
    if (state.submitResult is Loading<RegisteredAnimal>) {
      return;
    }

    final registration = _buildRegistration();
    if (registration case Failure<AnimalRegistration>(:final error)) {
      emit(state.copyWith(submitResult: ResultState.error(error)));
      return;
    }

    emit(state.copyWith(submitResult: const ResultState.loading()));

    final result = await _registerAnimalUseCase(
      (registration as Success<AnimalRegistration>).data,
    );

    switch (result) {
      case Success<RegisteredAnimal>(:final data):
        emit(state.copyWith(submitResult: ResultState.data(data)));
      case Failure<RegisteredAnimal>(:final error):
        emit(state.copyWith(submitResult: ResultState.error(error)));
    }
  }

  Result<AnimalRegistration> _buildRegistration() {
    // TODO(agustin): Extract this transformation/validation flow out of the
    // bloc. Presentation should trigger the use case, not assemble the full
    // registration payload with business-context resolution.
    final draft = state.draft;
    final rfid = draft.rfid.trim();
    if (!_isValidRfid(rfid)) {
      return const Result.failure(
        DomainException(
          message: 'Ingresá una caravana RFID válida de 15 dígitos.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    final destinationId = draft.destinationId;
    if (destinationId == null) {
      return const Result.failure(
        DomainException(
          message: 'Seleccioná el potrero de destino antes de guardar.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    final parsedWeight = _parseWeight(draft.birthWeight);
    if (parsedWeight == null || parsedWeight <= 0) {
      return const Result.failure(
        DomainException(
          message: 'Ingresá un peso válido mayor a 0 kg.',
          code: DomainErrorCode.validation,
        ),
      );
    }

    final visualTag = [
      draft.visualTagSeries.trim(),
      draft.visualTagNumber.trim(),
    ].where((value) => value.isNotEmpty).join(' ');

    try {
      return Result.success(
        AnimalRegistration(
          rfidTagNumber: rfid,
          visualTag: visualTag,
          sex: _mapSex(draft.sex),
          breed: draft.breed,
          birthDate: draft.birthDate,
          lotId: _mockContext.resolveLotId(destinationId),
          lotName: _mockContext.resolveLotName(destinationId),
          establishmentId: _mockContext.establishmentId,
          categoryId: _mockContext.resolveCategoryId(draft.category),
          categoryName: draft.category,
          initialWeight: parsedWeight,
          motherId: _mockContext.resolveMotherId(draft.motherId),
          fatherId: _mockContext.resolveFatherId(draft.fatherId),
          weighingMethod: AnimalWeighingMethod.manual,
          weighingDate: DateTime.now().toUtc(),
        ),
      );
    } on DomainException catch (error) {
      return Result.failure(error);
    }
  }

  bool _isValidRfid(String value) {
    return RegExp(r'^\d{15}$').hasMatch(value);
  }

  double? _parseWeight(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  AnimalSex _mapSex(String value) {
    return value == AnimalRegisterStrings.stepTwoMale ? AnimalSex.male : AnimalSex.female;
  }
}

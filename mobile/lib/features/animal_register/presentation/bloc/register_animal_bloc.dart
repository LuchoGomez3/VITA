import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';

part 'register_animal_bloc.freezed.dart';
part 'register_animal_event.dart';
part 'register_animal_state.dart';

/// Coordinates the animal registration draft and its visual steps.
class RegisterAnimalBloc extends Bloc<RegisterAnimalEvent, RegisterAnimalState> {
  /// Creates the registration bloc at the requested step.
  RegisterAnimalBloc({
    RegisterAnimalStep initialStep = RegisterAnimalStep.identification,
  }) : super(
         RegisterAnimalState(
           currentStep: initialStep,
           draft: RegisterAnimalDraft.initial(),
         ),
       ) {
    on<_DraftChanged>(_onDraftChanged);
    on<_NextStepRequested>(_onNextStepRequested);
    on<_PreviousStepRequested>(_onPreviousStepRequested);
    on<_StepRequested>(_onStepRequested);
  }

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
}

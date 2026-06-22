import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';

void main() {
  group('RegisterAnimalBloc', () {
    late RegisterAnimalBloc bloc;

    setUp(() {
      bloc = RegisterAnimalBloc();
      addTearDown(bloc.close);
    });

    test('updates the registration draft', () async {
      final updatedDraft = bloc.state.draft.copyWith(
        rfid: '982000412991416',
      );
      final expectedState = bloc.state.copyWith(draft: updatedDraft);

      final expectation = expectLater(bloc.stream, emits(expectedState));
      bloc.add(RegisterAnimalEvent.draftChanged(updatedDraft));

      await expectation;
    });

    test('moves forward and backward through the flow', () async {
      final forwardState = bloc.state.copyWith(
        currentStep: RegisterAnimalStep.basicData,
      );
      final backwardState = bloc.state;

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([forwardState, backwardState]),
      );
      bloc
        ..add(const RegisterAnimalEvent.nextStepRequested())
        ..add(const RegisterAnimalEvent.previousStepRequested());

      await expectation;
    });

    test('does not advance beyond review', () async {
      final reviewBloc = RegisterAnimalBloc(
        initialStep: RegisterAnimalStep.review,
      );
      addTearDown(reviewBloc.close);

      reviewBloc.add(const RegisterAnimalEvent.nextStepRequested());

      await Future<void>.delayed(Duration.zero);
      expect(reviewBloc.state.currentStep, RegisterAnimalStep.review);
    });
  });
}

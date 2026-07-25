import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/widgets/sign_up_actions.dart';

void main() {
  testWidgets('shows loading text and disables registration while submitting', (
    tester,
  ) async {
    var registrationCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignUpActions(
            isSubmitting: true,
            onLoginPressed: () {},
            onRegisterPressed: () => registrationCalls += 1,
          ),
        ),
      ),
    );

    expect(find.text(SignUpStrings.registeringButton), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    expect(registrationCalls, 0);
  });
}

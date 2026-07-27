import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/widgets/sign_up_form.dart';

void main() {
  testWidgets('name fields accept only letters and up to 50 characters', (
    tester,
  ) async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final cuitController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    addTearDown(firstNameController.dispose);
    addTearDown(lastNameController.dispose);
    addTearDown(cuitController.dispose);
    addTearDown(emailController.dispose);
    addTearDown(passwordController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignUpForm(
            cuitController: cuitController,
            emailController: emailController,
            firstNameController: firstNameController,
            lastNameController: lastNameController,
            passwordController: passwordController,
          ),
        ),
      ),
    );

    final cuitTopBeforeError = tester.getTopLeft(
      find.byType(TextFormField).at(2),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      '${'Á'.padRight(50, 'a')}12-!',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Muñoz Pérez_42',
    );
    await tester.pump();

    expect(firstNameController.text, hasLength(50));
    expect(firstNameController.text, isNot(contains(RegExp(r'[0-9\-!]'))));
    expect(lastNameController.text, 'Muñoz Pérez');
    expect(
      tester.getTopLeft(find.byType(TextFormField).at(2)),
      cuitTopBeforeError,
    );
  });

  testWidgets('name field silently enforces the maximum length', (
    tester,
  ) async {
    final controllers = List.generate(5, (_) => TextEditingController());
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignUpForm(
            cuitController: controllers[0],
            emailController: controllers[1],
            firstNameController: controllers[2],
            lastNameController: controllers[3],
            passwordController: controllers[4],
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'a'.padRight(51, 'a'),
    );
    await tester.pump();

    expect(controllers[2].text, hasLength(50));
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.byType(TextFormField).first,
        matching: find.byType(TextField),
      ),
    );
    final border = field.decoration!.focusedBorder! as OutlineInputBorder;
    expect(border.borderSide.color, AppColors.primary);
  });

  testWidgets('email field validates its format while typing', (tester) async {
    final controllers = List.generate(5, (_) => TextEditingController());
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignUpForm(
            cuitController: controllers[0],
            emailController: controllers[1],
            firstNameController: controllers[2],
            lastNameController: controllers[3],
            passwordController: controllers[4],
          ),
        ),
      ),
    );

    expect(find.text(SignUpStrings.emailInvalidFormatMessage), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(3), 'usuario@dominio');
    await tester.pump();

    expect(find.text(SignUpStrings.emailInvalidFormatMessage), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(3),
      'usuario@dominio.com',
    );
    await tester.pump();

    expect(find.text(SignUpStrings.emailValidFormatMessage), findsOneWidget);
    expect(find.text(SignUpStrings.emailInvalidFormatMessage), findsNothing);
    final field = tester.widget<TextField>(find.byType(TextField).at(3));
    final border = field.decoration!.focusedBorder! as OutlineInputBorder;
    expect(border.borderSide.color, AppColors.primary);
  });

  testWidgets('password requirements and strength update while typing', (
    tester,
  ) async {
    final controllers = List.generate(5, (_) => TextEditingController());
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SignUpForm(
              cuitController: controllers[0],
              emailController: controllers[1],
              firstNameController: controllers[2],
              lastNameController: controllers[3],
              passwordController: controllers[4],
            ),
          ),
        ),
      ),
    );

    final passwordField = find.byType(TextFormField).at(4);
    final passwordInput = tester.widget<EditableText>(
      find.descendant(
        of: passwordField,
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordInput.autocorrect, isFalse);
    expect(passwordInput.enableSuggestions, isFalse);
    expect(passwordInput.keyboardType, TextInputType.visiblePassword);
    expect(
      tester.widget<Text>(find.text(SignUpStrings.passwordNumberRequirement)).style?.color,
      AppColors.error,
    );

    await tester.enterText(passwordField, 'A1${'a' * 49}');
    await tester.pump();
    expect(controllers[4].text, hasLength(50));

    await tester.enterText(passwordField, 'A1');
    await tester.pump();

    expect(
      tester.widget<Text>(find.text(SignUpStrings.passwordUppercaseRequirement)).style?.color,
      AppColors.primary,
    );
    expect(
      tester.widget<Text>(find.text(SignUpStrings.passwordNumberRequirement)).style?.color,
      AppColors.primary,
    );
    expect(
      find.text(
        '${SignUpStrings.passwordStrengthLabel}: '
        '${SignUpStrings.passwordStrengthNormal}',
      ),
      findsOneWidget,
    );

    await tester.enterText(passwordField, 'Abcdefg1');
    await tester.pump();

    expect(
      tester.widget<Text>(find.text(SignUpStrings.passwordLengthRequirement)).style?.color,
      AppColors.primary,
    );
    expect(
      find.text(
        '${SignUpStrings.passwordStrengthLabel}: '
        '${SignUpStrings.passwordStrengthStrong}',
      ),
      findsOneWidget,
    );

    await tester.enterText(passwordField, 'Abcdefg1!');
    await tester.pump();

    expect(
      find.text(
        '${SignUpStrings.passwordStrengthLabel}: '
        '${SignUpStrings.passwordStrengthVeryStrong}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('CUIT formats and validates its check digit', (
    tester,
  ) async {
    final controllers = List.generate(5, (_) => TextEditingController());
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SignUpForm(
              cuitController: controllers[0],
              emailController: controllers[1],
              firstNameController: controllers[2],
              lastNameController: controllers[3],
              passwordController: controllers[4],
            ),
          ),
        ),
      ),
    );

    final cuitField = find.byType(TextFormField).at(2);
    expect(find.text(SignUpStrings.cuitIncompleteMessage), findsOneWidget);

    await tester.enterText(cuitField, '2012345678');
    await tester.pump();

    expect(controllers[0].text, '20-12345678');
    expect(find.text(SignUpStrings.cuitIncompleteMessage), findsOneWidget);

    await tester.enterText(cuitField, '${controllers[0].text}3');
    await tester.pump();

    expect(controllers[0].text, '20-12345678-3');
    expect(
      find.text(SignUpStrings.cuitInvalidCheckDigitMessage),
      findsOneWidget,
    );

    await tester.enterText(cuitField, '20-12345678-');
    await tester.pump();

    expect(controllers[0].text, '20-12345678');
    expect(find.text(SignUpStrings.cuitIncompleteMessage), findsOneWidget);

    await tester.enterText(cuitField, '${controllers[0].text}6');
    await tester.pump();

    expect(controllers[0].text, '20-12345678-6');
    expect(find.text(SignUpStrings.cuitValidFormatMessage), findsOneWidget);
  });

  testWidgets('form reports valid only when every field is valid', (
    tester,
  ) async {
    final controllers = [
      TextEditingController(text: '20-12345678-6'),
      TextEditingController(text: 'usuario@dominio.com'),
      TextEditingController(text: 'Ana'),
      TextEditingController(text: 'Pérez'),
      TextEditingController(),
    ];
    final validityChanges = <bool>[];
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SignUpForm(
              cuitController: controllers[0],
              emailController: controllers[1],
              firstNameController: controllers[2],
              lastNameController: controllers[3],
              passwordController: controllers[4],
              onValidityChanged: validityChanges.add,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(4), 'Password1');
    await tester.pump();
    expect(validityChanges.last, isTrue);

    await tester.enterText(
      find.byType(TextFormField).at(2),
      '20-12345678-3',
    );
    await tester.pump();
    expect(validityChanges.last, isFalse);

    await tester.enterText(
      find.byType(TextFormField).at(2),
      '20-12345678-6',
    );
    await tester.pump();
    expect(validityChanges.last, isTrue);

    await tester.enterText(find.byType(TextFormField).at(3), 'correo-invalido');
    await tester.pump();
    expect(validityChanges.last, isFalse);

    await tester.enterText(
      find.byType(TextFormField).at(3),
      'usuario@dominio.com',
    );
    await tester.pump();
    expect(validityChanges.last, isTrue);

    await tester.enterText(find.byType(TextFormField).first, 'Ana1');
    await tester.pump();
    expect(validityChanges.last, isTrue);
  });
}

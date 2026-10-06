import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/fields/app_dropdown_form_field.dart';

void main() {
  testWidgets('opens its options and preserves the initial selection', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 320,
              child: AppDropdownFormField<String>(
                hintText: 'Seleccioná una raza',
                initialValue: 'Hereford',
                options: [
                  AppDropdownOption(value: 'Angus', label: 'Aberdeen Angus'),
                  AppDropdownOption(value: 'Hereford', label: 'Hereford'),
                  AppDropdownOption(value: 'Braford', label: 'Braford'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hereford'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    final firstOption = find.text('Aberdeen Angus').hitTestable();
    expect(firstOption, findsOneWidget);
  });

  testWidgets('can be rendered inside an alert dialog', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(
                  content: AppDropdownFormField<String>(
                    hintText: 'Seleccioná una opción',
                    options: [
                      AppDropdownOption(value: 'one', label: 'Opción uno'),
                    ],
                  ),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AppDropdownFormField<String>), findsOneWidget);
  });
}

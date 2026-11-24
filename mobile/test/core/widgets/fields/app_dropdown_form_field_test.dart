import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/fields/app_dropdown_form_field.dart';

void main() {
  testWidgets('the animated menu opens under the field even with the last option selected', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 320,
              child: AppDropdownFormField<String>(
                hintText: 'Seleccioná una opción',
                animateMenu: true,
                initialValue: 'last',
                options: [
                  AppDropdownOption(value: 'first', label: 'Primera'),
                  AppDropdownOption(value: 'last', label: 'Última'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final anchor = find.byType(MenuAnchor);
    final fieldBottom = tester.getBottomLeft(anchor).dy;
    await tester.tap(anchor);
    await tester.pump();
    expect(tester.widget<MenuAnchor>(anchor).animated, isTrue);
    await tester.pumpAndSettle();

    final firstOption = find.widgetWithText(MenuItemButton, 'Primera').hitTestable();
    expect(firstOption, findsOneWidget);
    expect(tester.getTopLeft(firstOption).dy, greaterThanOrEqualTo(fieldBottom));
    expect(
      find.descendant(of: find.widgetWithText(MenuItemButton, 'Última'), matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });

  testWidgets('opens its options below the field regardless of the selection', (tester) async {
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

    final dropdown = find.byType(DropdownMenu<String>);
    final fieldBottom = tester.getBottomLeft(dropdown).dy;

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    final firstOption = find.widgetWithText(MenuItemButton, 'Aberdeen Angus').hitTestable();
    expect(firstOption, findsOneWidget);
    expect(tester.getTopLeft(firstOption).dy, greaterThanOrEqualTo(fieldBottom));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/add_operating_expense_category_dialog.dart';

void main() {
  testWidgets('muestra un error y mantiene abierto el dialogo si el nombre esta vacio', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AddOperatingExpenseCategoryDialog(),
        ),
      ),
    );

    await tester.tap(find.text(OperatingExpenseStrings.add));
    await tester.pump();

    expect(find.text(OperatingExpenseStrings.requiredCategoryName), findsOneWidget);
    expect(find.byType(AddOperatingExpenseCategoryDialog), findsOneWidget);
  });

  testWidgets('devuelve el nombre recortado cuando la entrada es valida', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<String>(
                context: context,
                builder: (_) => const AddOperatingExpenseCategoryDialog(),
              );
            },
            child: const Text(OperatingExpenseStrings.addCategory),
          ),
        ),
      ),
    );
    await tester.tap(find.text(OperatingExpenseStrings.addCategory));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '  Vacunas  ');

    await tester.tap(find.text(OperatingExpenseStrings.add));
    await tester.pumpAndSettle();

    expect(result, 'Vacunas');
  });
}

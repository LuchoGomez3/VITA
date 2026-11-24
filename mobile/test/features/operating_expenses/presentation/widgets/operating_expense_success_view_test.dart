import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_success_view.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('vuelve a la instancia previa de Home despues del alta', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push(AppRoutes.expenseRegister),
              child: const Text('Abrir egreso'),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.expenseRegister,
          builder: (context, state) => Scaffold(
            body: OperatingExpenseSubmissionView(
              expense: _expense,
              establishmentName: 'Campo Sur',
              onAddAnotherExpense: () {},
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Abrir egreso'));
    await tester.pumpAndSettle();

    final backHomeButton = find.text(OperatingExpenseStrings.backHome);
    await tester.scrollUntilVisible(
      backHomeButton,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(backHomeButton);
    await tester.pumpAndSettle();

    expect(find.text('Abrir egreso'), findsOneWidget);
  });
}

final _expense = OperatingExpense(
  id: 'expense-id',
  establishmentId: 'establishment-id',
  amountCents: 150000,
  type: OperatingExpenseType.productionCost,
  category: 'Alimentacion',
  supply: 'Balanceado',
  date: DateTime(2026, 11, 23),
  createdAt: DateTime(2026, 11, 23),
  updatedAt: DateTime(2026, 11, 23),
  syncStatus: OperatingExpenseSyncStatus.pending,
);

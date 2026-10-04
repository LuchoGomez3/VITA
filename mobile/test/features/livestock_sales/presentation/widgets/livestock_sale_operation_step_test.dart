import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_animal_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/add_animal_to_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/confirm_livestock_sale_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/remove_animal_from_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/steps/livestock_sale_operation_step.dart';

void main() {
  testWidgets('al elegir empresa solicita razon social y elimina el apellido', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    await tester.enterText(
      find.byKey(const Key('livestockSaleBuyerLastName')),
      'Pérez',
    );
    await tester.tap(find.text(LivestockSaleStrings.company));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('livestockSaleBusinessName')), findsOneWidget);
    expect(
      find.byKey(const Key('livestockSaleBuyerLastName')),
      findsNothing,
    );
    expect(bloc.state.form.isCompany, isTrue);
    expect(bloc.state.form.buyerLastName, isEmpty);
  });

  testWidgets('calcula por kilo sin modificar el precio ingresado', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    final perKilogram = find.text(LivestockSaleStrings.perKilogramSale);
    await tester.scrollUntilVisible(
      perKilogram,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(perKilogram);
    await tester.pumpAndSettle();
    final weight = find.byKey(const Key('livestockSaleTotalWeight'));
    final price = find.byKey(const Key('livestockSalePricePerKilogram'));
    await tester.scrollUntilVisible(
      weight,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(weight, '10');
    await tester.scrollUntilVisible(
      price,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(price, '1000.123456');
    await tester.pumpAndSettle();

    expect(bloc.state.form.totalWeight, '10');
    expect(bloc.state.form.pricePerKg, '1000.123456');
    expect(find.text(r'$ 10.001,23'), findsOneWidget);
    expect(
      find.text(
        LivestockSaleStrings.amountCalculation('10', '1000.123456'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('filtra y normaliza el numero de DTe mientras se escribe', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    final dteField = find.byKey(const Key('livestockSaleDteNumber'));
    await tester.enterText(dteField, '123456789-a!');
    await tester.pump();

    expect(bloc.state.form.dteNumber, '123456789-A');
    final editableText = tester.widget<EditableText>(
      find.descendant(of: dteField, matching: find.byType(EditableText)),
    );
    expect(editableText.controller.text, '123456789-A');
  });

  testWidgets('muestra saldo parcial y permite elegir tarjeta', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    final total = find.byKey(const Key('livestockSaleBulkTotal'));
    await tester.scrollUntilVisible(
      total,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(total, '10000');
    final partial = find.byKey(
      const ValueKey('livestockSalePaymentCondition-partial'),
    );
    await tester.scrollUntilVisible(
      partial,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(partial);
    await tester.pumpAndSettle();
    final collected = find.byKey(const Key('livestockSaleAmountToCollect'));
    await tester.scrollUntilVisible(
      collected,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(collected, '4000');
    await tester.pumpAndSettle();

    expect(find.text(r'$ 6.000,00'), findsOneWidget);
    final card = find.byKey(
      const ValueKey('livestockSalePaymentMethod-card'),
    );
    await tester.scrollUntilVisible(
      card,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(
      bloc.state.form.paymentCondition,
      LivestockSalePaymentCondition.partial,
    );
    expect(
      bloc.state.form.paymentMethod,
      LivestockSalePaymentMethod.card,
    );
  });
}

LivestockSaleBloc _createBloc() {
  return LivestockSaleBloc(
    establishmentId: 'establishment-id',
    addAnimal: const AddAnimalToLivestockSaleSelectionUseCase(
      repository: _AnimalRepository(),
    ),
    removeAnimal: const RemoveAnimalFromLivestockSaleSelectionUseCase(),
    confirmSale: ConfirmLivestockSaleUseCase(
      repository: const _SaleRepository(),
    ),
    now: () => DateTime(2026, 8, 24),
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.bloc});

  final LivestockSaleBloc bloc;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: BlocProvider.value(
        value: bloc,
        child: const Scaffold(body: LivestockSaleOperationStep()),
      ),
    );
  }
}

class _AnimalRepository implements LivestockSaleAnimalRepository {
  const _AnimalRepository();

  @override
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  ) async {
    return const Result.success(null);
  }
}

class _SaleRepository implements LivestockSaleRepository {
  const _SaleRepository();

  @override
  Future<Result<LivestockSale>> createSale(LivestockSale sale) async {
    return Result.success(sale);
  }
}

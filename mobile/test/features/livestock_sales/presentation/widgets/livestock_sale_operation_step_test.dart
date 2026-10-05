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
  testWidgets('enfoca el primer campo obligatorio incompleto', (tester) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await _openOperationStep(bloc);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    bloc.add(const LivestockSaleEvent.nextStepRequested());
    await tester.pumpAndSettle();

    final nameField = find.byKey(const Key('livestockSaleBuyerName'));
    final editableText = tester.widget<EditableText>(
      find.descendant(of: nameField, matching: find.byType(EditableText)),
    );
    expect(editableText.focusNode.hasFocus, isTrue);
    expect(
      bloc.state.stepError?.message,
      LivestockSaleStrings.missingRequiredFields,
    );
  });

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
    await _scrollToCenter(tester, perKilogram);
    await tester.tap(perKilogram);
    await tester.pumpAndSettle();
    final weight = find.byKey(const Key('livestockSaleTotalWeight'));
    final price = find.byKey(const Key('livestockSalePricePerKilogram'));
    await tester.scrollUntilVisible(
      weight,
      300,
      scrollable: _operationScrollable,
    );
    await tester.enterText(weight, '10');
    await tester.scrollUntilVisible(
      price,
      300,
      scrollable: _operationScrollable,
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

  testWidgets('muestra el error del DTe solo despues de una entrada invalida', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    expect(
      find.text(LivestockSaleStrings.invalidDteNumberFormat),
      findsNothing,
    );

    final dteField = find.byKey(const Key('livestockSaleDteNumber'));
    await tester.enterText(dteField, '12345');
    await tester.tap(find.byKey(const Key('livestockSaleBuyerName')));
    await tester.pump();

    expect(
      find.text(LivestockSaleStrings.invalidDteNumberFormat),
      findsOneWidget,
    );

    await tester.enterText(dteField, '123456789-A');
    await tester.pump();

    expect(
      find.text(LivestockSaleStrings.invalidDteNumberFormat),
      findsNothing,
    );
  });

  testWidgets(
    'persona acepta letras y espacios pero descarta otros caracteres',
    (tester) async {
      final bloc = _createBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(_TestApp(bloc: bloc));

      await tester.enterText(
        find.byKey(const Key('livestockSaleBuyerName')),
        'Ju4a@n Pérez!',
      );
      await tester.enterText(
        find.byKey(const Key('livestockSaleBuyerLastName')),
        'G0ómez del S#ur',
      );
      await tester.pump();

      expect(bloc.state.form.buyerName, 'Juan Pérez');
      expect(bloc.state.form.buyerLastName, 'Gómez del Sur');
    },
  );

  testWidgets('mantiene visible el simbolo pesos sin enfocar los importes', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    final bulkTotal = find.byKey(const Key('livestockSaleBulkTotal'));
    await tester.scrollUntilVisible(
      bulkTotal,
      300,
      scrollable: _operationScrollable,
    );
    expect(
      find.descendant(
        of: bulkTotal,
        matching: find.text(LivestockSaleStrings.currencySymbol),
      ),
      findsOneWidget,
    );

    final perKilogram = find.text(LivestockSaleStrings.perKilogramSale);
    await _scrollToCenter(tester, perKilogram);
    await tester.tap(perKilogram);
    await tester.pumpAndSettle();

    final price = find.byKey(const Key('livestockSalePricePerKilogram'));
    await tester.scrollUntilVisible(
      price,
      300,
      scrollable: _operationScrollable,
    );
    expect(
      find.descendant(
        of: price,
        matching: find.text(LivestockSaleStrings.currencySymbol),
      ),
      findsOneWidget,
    );
  });

  testWidgets('cobro parcial puede seleccionarse aunque el monto este vacio', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    final partial = find.byKey(
      const ValueKey('livestockSalePaymentCondition-partial'),
    );
    await _scrollToCenter(tester, partial);
    await tester.tap(partial);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('livestockSaleAmountToCollect')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('livestockSalePendingBalance')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
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
      scrollable: _operationScrollable,
    );
    await tester.enterText(total, '10000');
    final partial = find.byKey(
      const ValueKey('livestockSalePaymentCondition-partial'),
    );
    await _scrollToCenter(tester, partial);
    await tester.tap(partial);
    await tester.pumpAndSettle();
    final collected = find.byKey(const Key('livestockSaleAmountToCollect'));
    await tester.scrollUntilVisible(
      collected,
      300,
      scrollable: _operationScrollable,
    );
    await tester.enterText(collected, '4000');
    await tester.pumpAndSettle();

    expect(find.text(r'$ 6.000,00'), findsOneWidget);
    final card = find.byKey(
      const ValueKey('livestockSalePaymentMethod-card'),
    );
    await _scrollToCenter(tester, card);
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

final Finder _operationScrollable = find
    .descendant(
      of: find.byKey(const Key('livestockSaleOperationStep')),
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _scrollToCenter(WidgetTester tester, Finder target) async {
  // `scrollUntilVisible` puede detenerse cuando apenas aparece un borde. El
  // segundo paso centra el control para que el toque represente al usuario.
  await tester.scrollUntilVisible(
    target,
    300,
    scrollable: _operationScrollable,
  );
  await Scrollable.ensureVisible(
    tester.element(target),
    alignment: 0.5,
  );
  await tester.pumpAndSettle();
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
    return Result.success(
      LivestockSaleAnimal(
        id: 'animal-id',
        establishmentId: 'establishment-id',
        rfidTagNumber: rfidTagNumber,
        visualTag: '1295',
        categoryName: 'Novillo',
        lotName: 'Lote Norte',
        status: LivestockSaleAnimalStatus.active,
      ),
    );
  }
}

Future<void> _openOperationStep(LivestockSaleBloc bloc) async {
  bloc.add(
    const LivestockSaleEvent.animalAddRequested('982000000001295'),
  );
  await bloc.stream.firstWhere((state) => state.selection.animals.isNotEmpty);
  bloc.add(const LivestockSaleEvent.nextStepRequested());
  await bloc.stream.firstWhere(
    (state) => state.currentStep == LivestockSaleStep.operation,
  );
}

class _SaleRepository implements LivestockSaleRepository {
  const _SaleRepository();

  @override
  Future<Result<LivestockSale>> createSale(LivestockSale sale) async {
    return Result.success(sale);
  }
}

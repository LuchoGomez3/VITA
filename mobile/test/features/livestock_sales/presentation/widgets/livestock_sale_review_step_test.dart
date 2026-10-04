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
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/steps/livestock_sale_review_step.dart';

void main() {
  testWidgets('resume empresa y calculo por kilo con el precio ingresado', (
    tester,
  ) async {
    final bloc = await _createReviewBloc(
      animalCount: 2,
      form: _form(
        isCompany: true,
        buyerName: 'Frigorífico Norte SA',
        saleType: LivestockSaleType.perKilogram,
        totalWeight: '10',
        pricePerKg: '1000.123456',
      ),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    expect(find.text('Frigorífico Norte SA'), findsOneWidget);
    expect(find.text(LivestockSaleStrings.company), findsOneWidget);
    expect(find.text(LivestockSaleStrings.headCount(2)), findsOneWidget);

    final total = find.byKey(const Key('livestockSaleReviewTotal'));
    await tester.scrollUntilVisible(
      total,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(r'$1000,123456/kg'), findsOneWidget);
    expect(find.text(r'$ 10.001,23'), findsWidgets);
  });

  testWidgets('muestra cobro parcial, tarjeta y saldo restante', (
    tester,
  ) async {
    final bloc = await _createReviewBloc(
      animalCount: 1,
      form: _form(
        paymentCondition: LivestockSalePaymentCondition.partial,
        paymentMethod: LivestockSalePaymentMethod.card,
        amountToCollect: '4000',
      ),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    final pending = find.byKey(
      const Key('livestockSaleReviewPendingBalance'),
    );
    await tester.scrollUntilVisible(
      pending,
      400,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(LivestockSaleStrings.partialPaymentSummary), findsOneWidget);
    expect(find.text(LivestockSaleStrings.card), findsOneWidget);
    expect(find.text(r'$ 4.000,00'), findsOneWidget);
    expect(find.text(r'$ 6.000,00'), findsOneWidget);
  });

  testWidgets('muestra diez animales y permite desplegar los restantes', (
    tester,
  ) async {
    final bloc = await _createReviewBloc(
      animalCount: 12,
      form: _form(),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    expect(
      find.byKey(const ValueKey('livestockSaleReviewAnimal-animal-9')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('livestockSaleReviewAnimal-animal-10')),
      findsNothing,
    );

    final toggle = find.byKey(const Key('livestockSaleToggleAnimals'));
    tester.widget<TextButton>(toggle).onPressed!();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('livestockSaleReviewAnimal-animal-10')),
      findsOneWidget,
    );
    expect(find.text(LivestockSaleStrings.showFewerAnimals), findsOneWidget);
  });

  testWidgets('el cobro total no presenta saldo pendiente', (tester) async {
    final bloc = await _createReviewBloc(
      animalCount: 1,
      form: _form(),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    final collected = find.byKey(
      const Key('livestockSaleReviewCollectedNow'),
    );
    await tester.scrollUntilVisible(
      collected,
      400,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const Key('livestockSaleReviewPendingBalance')),
      findsNothing,
    );
    expect(find.text(LivestockSaleStrings.totalPaymentSummary), findsOneWidget);
  });

  testWidgets('el cobro posterior muestra todo el total pendiente', (
    tester,
  ) async {
    final bloc = await _createReviewBloc(
      animalCount: 1,
      form: _form(
        paymentCondition: LivestockSalePaymentCondition.pending,
      ),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    final pending = find.byKey(
      const Key('livestockSaleReviewPendingBalance'),
    );
    await tester.scrollUntilVisible(
      pending,
      400,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(LivestockSaleStrings.pendingPaymentSummary), findsOneWidget);
    expect(find.text(LivestockSaleStrings.totalToCollect), findsOneWidget);
    expect(find.text(r'$ 10.000,00'), findsWidgets);
    expect(find.text(LivestockSaleStrings.paymentMethod), findsNothing);
  });
}

Future<LivestockSaleBloc> _createReviewBloc({
  required int animalCount,
  required LivestockSaleFormDraft form,
}) async {
  final bloc = LivestockSaleBloc(
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

  for (var index = 0; index < animalCount; index++) {
    bloc.add(
      LivestockSaleEvent.animalAddRequested(_rfidForIndex(index)),
    );
    await bloc.stream.firstWhere(
      (state) => state.selection.animals.length == index + 1,
    );
  }
  bloc.add(LivestockSaleEvent.formChanged(form));
  await bloc.stream.firstWhere((state) => state.form == form);
  return bloc;
}

LivestockSaleFormDraft _form({
  bool isCompany = false,
  String buyerName = 'Juan',
  LivestockSaleType saleType = LivestockSaleType.bulk,
  String totalWeight = '',
  String pricePerKg = '',
  LivestockSalePaymentCondition paymentCondition = LivestockSalePaymentCondition.total,
  LivestockSalePaymentMethod paymentMethod = LivestockSalePaymentMethod.cash,
  String amountToCollect = '',
}) {
  return LivestockSaleFormDraft(
    establishmentId: 'establishment-id',
    operationDate: DateTime(2026, 8, 24),
    buyerType: LivestockSaleBuyerType.slaughterhouse,
    buyerName: buyerName,
    isCompany: isCompany,
    buyerLastName: isCompany ? '' : 'Pérez',
    dteNumber: '001234567-9',
    saleType: saleType,
    bulkTotalAmount: saleType == LivestockSaleType.bulk ? '10000' : '',
    totalWeight: totalWeight,
    pricePerKg: pricePerKg,
    paymentCondition: paymentCondition,
    paymentMethod: paymentMethod,
    amountToCollect: amountToCollect,
    paymentDate: DateTime(2026, 8, 24),
    observations: '',
    paymentObservations: '',
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
        child: const Scaffold(body: LivestockSaleReviewStep()),
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
    final index = int.parse(rfidTagNumber.substring(rfidTagNumber.length - 4));
    return Result.success(
      LivestockSaleAnimal(
        id: 'animal-$index',
        establishmentId: 'establishment-id',
        rfidTagNumber: rfidTagNumber,
        visualTag: '${1200 + index}',
        categoryName: index.isEven ? 'Novillo' : 'Vaquillona',
        lotName: 'Lote Norte',
        status: LivestockSaleAnimalStatus.active,
      ),
    );
  }
}

class _SaleRepository implements LivestockSaleRepository {
  const _SaleRepository();

  @override
  Future<Result<LivestockSale>> createSale(LivestockSale sale) async {
    return Result.success(sale);
  }
}

String _rfidForIndex(int index) {
  return '98200000000${index.toString().padLeft(4, '0')}';
}

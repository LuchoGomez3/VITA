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
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/steps/livestock_sale_animal_selection_step.dart';

void main() {
  testWidgets('muestra el estado vacio y los textos centralizados', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));

    expect(
      find.text(LivestockSaleStrings.animalSelectionTitle),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('livestockSaleEmptySelection')),
      findsOneWidget,
    );
    expect(
      find.text(LivestockSaleStrings.selectedAnimalCount(0)),
      findsOneWidget,
    );
  });

  testWidgets('agrega desde SQLite, limpia el campo y permite quitar', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(_TestApp(bloc: bloc));

    await tester.enterText(
      find.byKey(const Key('livestockSaleRfidInput')),
      _rfid,
    );
    final addButton = find.byKey(
      const Key('livestockSaleAddAnimalButton'),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(bloc.state.selection.animals, hasLength(1));
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected-sale-animal-animal-id')),
      findsOneWidget,
    );
    expect(find.text('Novillo'), findsOneWidget);
    expect(find.text('Lote Norte'), findsOneWidget);
    expect(find.text(LivestockSaleStrings.animalRfid(_rfid)), findsOneWidget);
    expect(
      find.byKey(const Key('livestockSaleEmptySelection')),
      findsNothing,
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      isEmpty,
    );

    final removeButton = find.byTooltip(
      LivestockSaleStrings.removeAnimal,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(removeButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected-sale-animal-animal-id')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('livestockSaleEmptySelection')),
      findsOneWidget,
    );
  });

  testWidgets('agrega la caravana devuelta por el lector RFID', (
    tester,
  ) async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(
      _TestApp(
        bloc: bloc,
        onRfidScanRequested: () async => _rfid,
      ),
    );

    final scanButton = find.byKey(
      const Key('livestockSaleRfidScanButton'),
    );
    await tester.ensureVisible(scanButton);
    await tester.tap(scanButton);
    await tester.pumpAndSettle();

    expect(bloc.state.selection.animals, hasLength(1));
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('selected-sale-animal-animal-id')),
      findsOneWidget,
    );
    expect(find.text(LivestockSaleStrings.animalRfid(_rfid)), findsOneWidget);
  });
}

const _rfid = '982000000001295';

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
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.bloc,
    this.onRfidScanRequested = _emptyRfidScan,
  });

  final LivestockSaleBloc bloc;
  final Future<String?> Function() onRfidScanRequested;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: BlocProvider.value(
        value: bloc,
        child: Scaffold(
          body: LivestockSaleAnimalSelectionStep(
            onRfidScanRequested: onRfidScanRequested,
          ),
        ),
      ),
    );
  }
}

Future<String?> _emptyRfidScan() async => null;

class _AnimalRepository implements LivestockSaleAnimalRepository {
  const _AnimalRepository();

  @override
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  ) async {
    return const Result.success(
      LivestockSaleAnimal(
        id: 'animal-id',
        establishmentId: 'establishment-id',
        rfidTagNumber: _rfid,
        visualTag: '1295',
        categoryName: 'Novillo',
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

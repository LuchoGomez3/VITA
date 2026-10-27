import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_event_history.dart';

void main() {
  testWidgets('muestra una venta local en el historial del animal', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimalEventHistory(animalDetail: _animalWithSale),
          ),
        ),
      ),
    );

    expect(find.text(AnimalDetailStrings.saleEventTitle), findsOneWidget);
    expect(
      find.text(AnimalDetailStrings.pendingSaleEventDescription),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.attach_money), findsOneWidget);
  });
}

final _animalWithSale = AnimalDetail(
  id: 'animal-id',
  rfidTagNumber: '123123123123126',
  visualTag: '3126',
  sex: AnimalSex.female,
  breed: 'Angus',
  birthDate: DateTime(2025, 3, 14),
  categoryId: 'category-id',
  categoryName: 'Vaquillona',
  lotId: 'lot-id',
  lotName: 'Lote norte',
  establishmentId: 'establishment-id',
  currentWeight: 0,
  weighingMethod: AnimalWeighingMethod.manual,
  weighingDate: DateTime(2025, 3, 14),
  syncStatus: AnimalSyncStatus.synchronized,
  updatedAt: DateTime(2026, 10, 27),
  weightHistory: const [],
  saleHistory: [
    AnimalSaleRecord(
      id: 'sale-id',
      operationDate: DateTime(2026, 10, 27),
      syncStatus: AnimalSaleSyncStatus.pending,
    ),
  ],
);

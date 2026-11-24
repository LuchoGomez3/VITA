import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_movement_dialog.dart';

void main() {
  testWidgets('el diálogo actualiza el forraje al elegir otro lote de destino', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LotMovementDialog(
            animals: const [],
            originResourceCode: 'pasto_natural',
            destinations: [_lot('norte', 'Norte', 'alfalfa'), _lot('sur', 'Sur', null)],
          ),
        ),
      ),
    );
    expect(find.text('Pasto natural'), findsNothing);

    await tester.tap(find.byType(AppDropdownFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Norte'));
    await tester.pumpAndSettle();
    expect(find.text('Pasto natural'), findsOneWidget);
    expect(find.text('Alfalfa'), findsOneWidget);

    await tester.tap(find.byType(AppDropdownFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sur'));
    await tester.pumpAndSettle();
    expect(find.text('Alfalfa'), findsNothing);
    expect(find.text('Sin especificar'), findsOneWidget);
    expect(find.text(FieldStrings.moveAnimalsCta), findsOneWidget);
  });
}

Lot _lot(String id, String name, String? code) => Lot(
  id: id,
  establishmentId: 'campo',
  name: name,
  boundary: const LotBoundary(),
  surfaceTenths: 10,
  hasWater: true,
  forageResourceCode: code,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

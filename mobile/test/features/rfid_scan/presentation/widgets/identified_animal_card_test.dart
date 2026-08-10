import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/widgets/identified_animal_card.dart';

void main() {
  testWidgets('shows an explicit value when category and lot are unavailable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IdentifiedAnimalCard(
            animal: IdentifiedAnimal(
              id: 'animal-id',
              rfidTagNumber: '123456789012345',
              visualTag: '1234',
              sex: IdentifiedAnimalSex.female,
              breed: 'Aberdeen Angus',
              categoryName: '',
              lotName: '',
              updatedAt: DateTime(2026),
            ),
          ),
        ),
      ),
    );

    expect(find.text(RfidScanStrings.unavailableValue), findsNWidgets(2));
  });
}

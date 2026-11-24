import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/animal_list_entry.dart';
import 'package:frontend_mayoral/features/livestock/presentation/widgets/animal_list_tile.dart';

void main() {
  testWidgets('la insignia queda a la derecha sin cambiar la altura de la tarjeta', (tester) async {
    const animal = AnimalListEntry(
      id: 'animal',
      establishmentId: 'field',
      visualTag: '2026 105',
      rfidTagNumber: '888777666555000',
      breed: 'Aberdeen Angus',
      categoryName: 'Ternero',
      lotName: 'Los Sauces',
      lastWeightKg: 15,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: Column(
                children: [
                  AnimalListTile(animal: animal, onTap: () {}),
                  AnimalListTile(
                    animal: animal.copyWith(productiveStatus: AnimalProductiveStatus.sold),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final tiles = find.byType(AnimalListTile);
    expect(tester.getSize(tiles.first).height, tester.getSize(tiles.last).height);
    final label = tester.getRect(find.text('Vendido'));
    final title = tester.getRect(find.text('Aberdeen Angus · Ternero').last);
    expect(label.left, greaterThan(title.left));
    expect(label.center.dy, closeTo(title.center.dy, 1));
  });
}

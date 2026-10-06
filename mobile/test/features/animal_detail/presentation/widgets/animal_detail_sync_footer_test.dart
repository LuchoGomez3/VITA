import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_sync_footer.dart';

void main() {
  testWidgets('shows one generic rejection message and retries', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalDetailSyncFooter(
            animalDetail: _rejectedAnimal,
            onRetry: () => retries += 1,
          ),
        ),
      ),
    );

    expect(find.text(AnimalDetailStrings.rejectedSyncTitle), findsOneWidget);
    expect(find.text(AnimalDetailStrings.rejectedSyncMessage), findsOneWidget);
    expect(find.text('future_backend_code'), findsNothing);

    await tester.tap(find.text(AnimalDetailStrings.retrySync));

    expect(retries, 1);
  });
}

final _rejectedAnimal = AnimalDetail(
  id: 'animal-id',
  rfidTagNumber: '982000412991416',
  visualTag: '003 1295',
  sex: AnimalSex.female,
  breed: 'Aberdeen Angus',
  birthDate: DateTime(2025, 3, 14),
  categoryId: 'category-id',
  categoryName: 'Ternera',
  lotId: 'lot-id',
  lotName: 'La Cumbre',
  establishmentId: 'establishment-id',
  currentWeight: 32.5,
  weighingMethod: AnimalWeighingMethod.manual,
  weighingDate: DateTime(2025, 3, 14),
  syncStatus: AnimalSyncStatus.rejected,
  updatedAt: DateTime(2025, 3, 14),
  weightHistory: const [],
  syncErrorCode: 'future_backend_code',
);

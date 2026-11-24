import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/animal_observations.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_observations_section.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_general_tab.dart';

void main() {
  testWidgets('la pestaña General muestra el estado productivo con texto', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalGeneralTab(animal: _soldAnimal, onRetrySync: () {}),
        ),
      ),
    );

    expect(
      find.text(AnimalDetailStrings.productiveStatusSold),
      findsOneWidget,
    );
  });

  testWidgets('la hoja de observaciones permite cancelar o guardar con el teclado abierto', (tester) async {
    tester.view.physicalSize = const Size(340, 660);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final repository = _ObservationsRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalObservationsSection(animal: _soldAnimal, actions: AnimalObservations(repository)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final add = find.widgetWithText(TextButton, AnimalDetailStrings.addObservationAction);
    final save = find.widgetWithText(FilledButton, 'Guardar');
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Borrador');
    await tester.pump();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repository.notes, isEmpty);

    await tester.tap(add);
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.enterText(find.byType(TextField), 'Nota guardada');
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(save).dy, lessThanOrEqualTo(360));
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repository.notes, ['Nota guardada']);
  });
}

class _ObservationsRepository implements AnimalObservationRepository {
  final notes = <String>[];

  @override
  Stream<List<AnimalObservation>> watch(String establishmentId, String animalId) => Stream.value([]);

  @override
  Future<void> add(String establishmentId, String animalId, String text) async => notes.add(text);
}

final _soldAnimal = AnimalDetail(
  id: 'animal-id',
  rfidTagNumber: '982000412991416',
  visualTag: '003 1295',
  sex: AnimalSex.female,
  breed: 'Angus',
  birthDate: DateTime.utc(2025),
  categoryId: 'category-id',
  categoryName: 'Vaca',
  lotId: 'lot-id',
  lotName: 'Lote norte',
  establishmentId: 'establishment-id',
  currentWeight: 300,
  weighingMethod: AnimalWeighingMethod.manual,
  weighingDate: DateTime.utc(2026, 10),
  syncStatus: AnimalSyncStatus.synchronized,
  productiveStatus: AnimalProductiveStatus.sold,
  updatedAt: DateTime.utc(2026, 10),
  weightHistory: const [],
);

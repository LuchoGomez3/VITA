import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_actions.dart';

void main() {
  testWidgets('offers pregnancy editing only for females', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimalDetailActions(sex: AnimalSex.male)),
      ),
    );
    expect(find.text(AnimalDetailStrings.changePregnancyAction), findsNothing);
    expect(find.text(AnimalDetailStrings.enterWeightAction), findsOneWidget);
    expect(find.text(AnimalDetailStrings.changeCategoryAction), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimalDetailActions(sex: AnimalSex.female)),
      ),
    );
    expect(find.text(AnimalDetailStrings.changePregnancyAction), findsOneWidget);
  });

  testWidgets('offers undo only after confirming the death preview', (tester) async {
    // Arrange: solo presentation, sin repositorios ni casos de uso conectados.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimalDetailActions(sex: AnimalSex.female)),
      ),
    );

    // Act: cancelar no muestra una baja ni la opción de deshacer.
    await tester.tap(find.text(AnimalDetailStrings.deathAction));
    await tester.pumpAndSettle();
    expect(find.text(AnimalDetailStrings.deathConfirmationTitle), findsOneWidget);
    await tester.tap(find.text(AnimalDetailStrings.cancelAction));
    await tester.pumpAndSettle();
    expect(find.text(AnimalDetailStrings.undoAction), findsNothing);

    await tester.tap(find.text(AnimalDetailStrings.deathAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AnimalDetailStrings.confirmAction));
    await tester.pumpAndSettle();

    // Assert: confirmar solo ofrece una vista previa reversible en la interfaz.
    expect(find.text(AnimalDetailStrings.deathPreviewMessage), findsOneWidget);
    expect(find.text(AnimalDetailStrings.undoAction), findsOneWidget);
    await tester.tap(find.text(AnimalDetailStrings.undoAction));
    await tester.pumpAndSettle();
    expect(find.text(AnimalDetailStrings.deathPreviewMessage), findsNothing);
  });
}

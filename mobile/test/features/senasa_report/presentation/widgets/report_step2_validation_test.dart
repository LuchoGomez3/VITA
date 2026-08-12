import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step2_validation.dart';

void main() {
  testWidgets('shows the number of animals that will be exported', (tester) async {
    await tester.pumpWidget(
      _validationWidget(
        const SenasaValidationResult(exportableAnimals: 12),
      ),
    );

    expect(find.text(SenasaStrings.step2AnimalsLabel), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('shows every invalid animal by tag and missing fields', (tester) async {
    await tester.pumpWidget(
      _validationWidget(
        const SenasaValidationResult(
          exportableAnimals: 0,
          issues: [
            SenasaRecordIssue(
              animalId: 'animal-1',
              tag: '123',
              missingFields: ['nro_caravana_rfid', 'raza'],
            ),
            SenasaRecordIssue(
              animalId: 'animal-2',
              missingFields: ['fecha_nacimiento'],
            ),
          ],
        ),
      ),
    );

    expect(find.text('${SenasaStrings.tagLabel}: 123'), findsOneWidget);
    expect(
      find.text('${SenasaStrings.tagLabel}: ${SenasaStrings.animalWithoutTag}'),
      findsOneWidget,
    );
    expect(find.textContaining('raza con código SENASA'), findsOneWidget);
    expect(find.textContaining('fecha de nacimiento'), findsOneWidget);
  });

  testWidgets('uses the singular label for one invalid animal', (tester) async {
    await tester.pumpWidget(
      _validationWidget(
        const SenasaValidationResult(
          exportableAnimals: 0,
          issues: [
            SenasaRecordIssue(
              animalId: 'animal-1',
              tag: '123',
              missingFields: ['raza'],
            ),
          ],
        ),
      ),
    );

    final heading = tester.widget<Text>(find.text(SenasaStrings.incompleteAnimals(1)));
    expect(heading.textAlign, TextAlign.center);
  });
}

Widget _validationWidget(SenasaValidationResult result) {
  return MaterialApp(
    home: Scaffold(
      body: ReportStep2Validation(
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 2),
        validation: ResultState.data(result),
        onRetry: () {},
      ),
    ),
  );
}

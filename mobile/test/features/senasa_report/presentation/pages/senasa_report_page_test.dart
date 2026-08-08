import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/validate_senasa_records_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';

void main() {
  testWidgets('does not continue without an establishment', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SenasaReportPage(
          getEstablishments: GetSenasaEstablishmentsUseCase(_FakeRepository()),
          generateReport: GenerateSenasaReportUseCase(_FakeRepository()),
          validateRecords: ValidateSenasaRecordsUseCase(_FakeRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acta de vacunación'), findsNothing);
    expect(find.text('Tipo de evento'), findsNothing);
    expect(find.text('PDF'), findsNothing);

    await tester.tap(find.text(SenasaStrings.btnContinue));
    await tester.pumpAndSettle();

    expect(find.text(SenasaStrings.establishmentRequired), findsOneWidget);
    expect(find.text(SenasaStrings.step1Title), findsOneWidget);
    expect(find.text(SenasaStrings.step2Title), findsNothing);
  });
}

class _FakeRepository implements SenasaReportRepository {
  @override
  Future<List<SenasaExportHistoryItem>> getGeneratedReports(
    String establishmentId,
  ) async => const [];

  @override
  Future<GeneratedSenasaReport> downloadGeneratedReport(String exportId) {
    throw UnimplementedError();
  }

  @override
  Future<GeneratedSenasaReport> generateReport(SenasaReportRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<List<SenasaEstablishment>> getEstablishments() async => const [
    SenasaEstablishment(id: 'establishment-id', name: 'Estancia de prueba'),
  ];

  @override
  Future<SenasaValidationResult> validateRecords(SenasaReportValidationRequest request) async {
    return const SenasaValidationResult(exportableAnimals: 0);
  }
}

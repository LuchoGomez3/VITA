import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_surface_card.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/download_generated_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_generated_senasa_reports_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_menu_page.dart';

void main() {
  testWidgets('abre el selector compacto sin violar el mínimo táctil', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: SenasaMenuPage(
          getEstablishments: GetSenasaEstablishmentsUseCase(repository),
          getGeneratedReports: GetGeneratedSenasaReportsUseCase(repository),
          downloadGeneratedReport: DownloadGeneratedSenasaReportUseCase(
            repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppSurfaceCard), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Estancia local'), findsWidgets);
  });
}

class _FakeRepository implements SenasaReportRepository {
  @override
  Future<GeneratedSenasaReport> downloadGeneratedReport(String exportId) async {
    return GeneratedSenasaReport(
      bytes: Uint8List(0),
      filename: 'declaracion.txt',
      mediaType: 'text/plain',
      generatedAt: DateTime(2026),
      animalCount: 0,
    );
  }

  @override
  Future<GeneratedSenasaReport> generateReport(SenasaReportRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<List<SenasaExportHistoryItem>> getGeneratedReports(
    String establishmentId,
  ) async => const [];

  @override
  Future<List<SenasaEstablishment>> getEstablishments() async => const [
    SenasaEstablishment(id: 'establishment-id', name: 'Estancia local'),
  ];

  @override
  Future<SenasaValidationResult> validateRecords(
    SenasaReportValidationRequest request,
  ) {
    throw UnimplementedError();
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/validate_senasa_records_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_report_cubit.dart';

void main() {
  group('SenasaReportCubit', () {
    test('does not emit establishments after being closed', () async {
      final repository = _PendingSenasaReportRepository();
      final cubit = _createCubit(repository);

      final load = cubit.loadEstablishments();
      await cubit.close();
      repository.establishments.complete(const []);

      await expectLater(load, completes);
    });

    test('does not emit a generated report after being closed', () async {
      final repository = _PendingSenasaReportRepository();
      final cubit = _createCubit(repository);
      final request = SenasaReportRequest(
        establishmentId: 'establishment-id',
        from: DateTime.utc(2026),
        to: DateTime.utc(2026, 1, 2),
        fileName: '',
        animalCount: 2,
      );

      final generation = cubit.generate(request);
      await cubit.close();
      repository.report.complete(
        GeneratedSenasaReport(
          bytes: Uint8List(0),
          filename: 'report.txt',
          mediaType: 'text/plain',
          generatedAt: DateTime(2026),
          animalCount: 2,
        ),
      );

      await expectLater(generation, completes);
    });
  });
}

SenasaReportCubit _createCubit(SenasaReportRepository repository) {
  return SenasaReportCubit(
    getEstablishments: GetSenasaEstablishmentsUseCase(repository),
    generateReport: GenerateSenasaReportUseCase(repository),
    validateRecords: ValidateSenasaRecordsUseCase(repository),
  );
}

class _PendingSenasaReportRepository implements SenasaReportRepository {
  final establishments = Completer<List<SenasaEstablishment>>();
  final report = Completer<GeneratedSenasaReport>();

  @override
  Future<List<SenasaExportHistoryItem>> getGeneratedReports(
    String establishmentId,
  ) async => const [];

  @override
  Future<GeneratedSenasaReport> downloadGeneratedReport(String exportId) {
    return report.future;
  }

  @override
  Future<List<SenasaEstablishment>> getEstablishments() {
    return establishments.future;
  }

  @override
  Future<GeneratedSenasaReport> generateReport(
    SenasaReportRequest request,
  ) {
    return report.future;
  }

  @override
  Future<SenasaValidationResult> validateRecords(SenasaReportValidationRequest request) async {
    return const SenasaValidationResult(exportableAnimals: 0);
  }
}

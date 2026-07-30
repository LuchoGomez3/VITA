import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
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
        format: 'pdf',
        from: DateTime.utc(2026),
        to: DateTime.utc(2026, 1, 2),
        eventType: 'movement',
        responsibleName: 'Test User',
        responsibleDni: '12345678',
      );

      final generation = cubit.generate(request);
      await cubit.close();
      repository.report.complete(
        GeneratedSenasaReport(
          bytes: Uint8List(0),
          filename: 'report.pdf',
          mediaType: 'application/pdf',
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
  );
}

class _PendingSenasaReportRepository implements SenasaReportRepository {
  final establishments = Completer<List<SenasaEstablishment>>();
  final report = Completer<GeneratedSenasaReport>();

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
}

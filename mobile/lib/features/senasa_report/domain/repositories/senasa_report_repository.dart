import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';

/// Contract for the SENASA report backend integration.
abstract class SenasaReportRepository {
  /// Lists establishments available to the authenticated user.
  Future<List<SenasaEstablishment>> getEstablishments();

  /// Generates and downloads a SENASA report.
  Future<GeneratedSenasaReport> generateReport(SenasaReportRequest request);
}

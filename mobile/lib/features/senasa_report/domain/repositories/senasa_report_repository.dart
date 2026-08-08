import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';

/// Contract for the SENASA report backend integration.
abstract class SenasaReportRepository {
  /// Lista las exportaciones remotas del establecimiento seleccionado.
  Future<List<SenasaExportHistoryItem>> getGeneratedReports(
    String establishmentId,
  );

  /// Lists establishments available to the authenticated user.
  Future<List<SenasaEstablishment>> getEstablishments();

  /// Generates and downloads a SENASA report.
  Future<GeneratedSenasaReport> generateReport(SenasaReportRequest request);

  /// Descarga los bytes originales de una exportación histórica.
  Future<GeneratedSenasaReport> downloadGeneratedReport(String exportId);

  /// Comprueba con el backend que cada registro cumple los requisitos SENASA.
  Future<SenasaValidationResult> validateRecords(SenasaReportValidationRequest request);
}

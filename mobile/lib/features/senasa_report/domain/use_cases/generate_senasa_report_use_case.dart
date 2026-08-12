import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';

/// Generates a report using the backend SENASA endpoint.
class GenerateSenasaReportUseCase {
  /// Creates the use case.
  const GenerateSenasaReportUseCase(this._repository);

  final SenasaReportRepository _repository;

  /// Executes the use case.
  Future<GeneratedSenasaReport> call(SenasaReportRequest request) => _repository.generateReport(request);
}

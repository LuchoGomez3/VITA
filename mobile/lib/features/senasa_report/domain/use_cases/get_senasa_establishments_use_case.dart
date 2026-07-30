import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';

/// Loads establishments available for a SENASA report.
class GetSenasaEstablishmentsUseCase {
  /// Creates the use case.
  const GetSenasaEstablishmentsUseCase(this._repository);

  final SenasaReportRepository _repository;

  /// Executes the use case.
  Future<List<SenasaEstablishment>> call() => _repository.getEstablishments();
}

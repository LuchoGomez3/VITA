import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';

/// Descarga exactamente el archivo conservado por el historial del backend.
class DownloadGeneratedSenasaReportUseCase {
  /// Crea el caso de uso con el contrato de reportes.
  const DownloadGeneratedSenasaReportUseCase(this._repository);

  final SenasaReportRepository _repository;

  /// Obtiene los bytes originales sin regenerar la declaración.
  Future<GeneratedSenasaReport> call(String exportId) {
    return _repository.downloadGeneratedReport(exportId);
  }
}

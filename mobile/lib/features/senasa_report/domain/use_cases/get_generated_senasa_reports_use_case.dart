import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';

/// Obtiene los archivos SENASA que fueron generados y guardados en el dispositivo.
class GetGeneratedSenasaReportsUseCase {
  /// Crea el caso de uso con el repositorio del módulo.
  const GetGeneratedSenasaReportsUseCase(this._repository);

  final SenasaReportRepository _repository;

  /// Devuelve los archivos ordenados desde el más reciente.
  Future<List<SenasaExportHistoryItem>> call(String establishmentId) {
    return _repository.getGeneratedReports(establishmentId);
  }
}

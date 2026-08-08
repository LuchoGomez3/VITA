import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';

/// Valida que los registros seleccionados contengan los datos exigidos por SENASA.
class ValidateSenasaRecordsUseCase {
  /// Crea el caso de uso con el contrato de reportes.
  const ValidateSenasaRecordsUseCase(this._repository);

  final SenasaReportRepository _repository;

  /// Ejecuta en el backend las mismas reglas aplicadas al documento definitivo.
  Future<SenasaValidationResult> call(SenasaReportValidationRequest request) {
    return _repository.validateRecords(request);
  }
}
